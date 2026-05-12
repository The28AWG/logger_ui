import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:logger_ui/src/l10n/logger_ln.dart';
import 'package:logger_ui/src/log_viewer_filter_sheet.dart';
import 'package:logger_ui/src/log_viewer_formatting.dart';
import 'package:logger_ui/src/log_viewer_row.dart';

/// Экран списка логов: приём из [LoggerController.loggerStream] с батчингом и лимитом памяти.
///
/// Поток не блокируется: события копятся в очередь; в каждом кадре забирается не больше
/// [maxRecordsPerFrame] записей, пока очередь не опустеет (цепочка post-frame callbacks).
/// Если очередь между кадрами раздулась сильнее [maxPendingBetweenFrames], старые
/// ещё не показанные записи отбрасываются (счётчик в шапке).
class LogViewerScreen extends StatefulWidget {
  const LogViewerScreen({
    super.key,
    this.controller,
    this.maxEntries = 20000,
    this.maxPendingBetweenFrames = 8000,
    this.maxRecordsPerFrame = 2500,
  });

  /// По умолчанию — глобальный [loggerController].
  final LoggerController? controller;

  /// Сколько последних записей держим в списке (старое выкидывается одним срезом).
  final int maxEntries;

  /// Верхний предел очереди «ждут кадра»; при переполнении удаляем с головы.
  final int maxPendingBetweenFrames;

  /// Сколько записей максимум переносим из очереди в модель за один кадр.
  final int maxRecordsPerFrame;

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  LoggerController get _ctrl => widget.controller ?? loggerController;

  final ScrollController _scrollController = ScrollController();

  /// Уже отдано в ListView (хвост истории).
  final List<LogRecord> _records = [];

  /// Записи с учётом фильтров (уровень + строка поиска).
  final List<LogRecord> _visible = [];

  /// Очередь до ближайшего дренажа в кадр.
  final List<LogRecord> _pending = [];

  final TextEditingController _searchCtrl = TextEditingController();

  StreamSubscription<LogRecord>? _sub;

  bool _flushScheduled = false;

  /// Пользователь у низа списка — автопрокрутка на новые.
  var _stickToBottom = true;

  var _pendingDropped = 0;

  var _newWhileScrolledUp = 0;

  /// Минимальный уровень: показываются записи с [LogRecord.logLevel] не ниже.
  LogLevel _minLevel = .trace;

  /// Нормализованная подстрока поиска (уже [String.trim] и lower case).
  var _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _seedHistory();
    _syncVisible();
    _sub = _ctrl.loggerStream.listen(_onRecord, cancelOnError: false);
  }

  void _seedHistory() {
    final h = _ctrl.loggerHistory;
    if (h.isEmpty) return;
    final start = h.length > widget.maxEntries
        ? h.length - widget.maxEntries
        : 0;
    _records.addAll(h.sublist(start));
  }

  void _syncVisible() {
    _visible.clear();
    final q = _searchQuery;
    final minL = _minLevel.level;
    for (var i = 0; i < _records.length; i++) {
      final r = _records[i];
      if (r.logLevel.level < minL) continue;
      if (q.isNotEmpty && !_recordMatchesQuery(r, q)) continue;
      _visible.add(r);
    }
  }

  static bool _recordMatchesQuery(LogRecord r, String q) {
    if ((r.message ?? '').toLowerCase().contains(q)) return true;
    if (r.name.toLowerCase().contains(q)) return true;
    final tag = r.tag;
    if (tag != null && tag.toLowerCase().contains(q)) return true;
    final ex = r.exception;
    if (ex != null && ex.toString().toLowerCase().contains(q)) return true;
    final err = r.error;
    if (err != null && err.toString().toLowerCase().contains(q)) return true;
    final ctx = r.context;
    if (ctx == null) return false;
    for (final e in ctx.entries) {
      if (e.key.toLowerCase().contains(q)) return true;
      final v = e.value;
      if (v != null && v.toString().toLowerCase().contains(q)) return true;
    }
    return false;
  }

  void _clearSearch() {
    _searchCtrl.clear();
    if (_searchQuery.isEmpty) return;
    setState(() {
      _searchQuery = '';
      _syncVisible();
    });
  }

  void _onFilterSearchChanged(String raw) {
    final next = raw.trim().toLowerCase();
    if (next == _searchQuery) return;
    setState(() {
      _searchQuery = next;
      _syncVisible();
    });
  }

  void _onFilterLevelSelected(LogLevel l) {
    setState(() {
      _minLevel = l;
      _syncVisible();
    });
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => FilterSheet(
        searchCtrl: _searchCtrl,
        searchQuery: _searchQuery,
        minLevel: _minLevel,
        onSearchChanged: _onFilterSearchChanged,
        onClearSearch: _clearSearch,
        onLevelSelected: _onFilterLevelSelected,
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _sub?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final p = _scrollController.position;
    final nearBottom = p.maxScrollExtent - p.pixels < 72;
    if (nearBottom && !_stickToBottom) {
      setState(() => _newWhileScrolledUp = 0);
    }
    _stickToBottom = nearBottom;
  }

  void _onRecord(LogRecord r) {
    while (_pending.length >= widget.maxPendingBetweenFrames) {
      _pending.removeAt(0);
      _pendingDropped++;
    }
    _pending.add(r);
    _scheduleFlush();
  }

  void _scheduleFlush() {
    if (_flushScheduled) return;
    _flushScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _drainOneFrame());
    // Иначе при idle следующий кадр может не прийти — post-frame так и ждёт
    // до первого ввода/анимации (курсор, hover и т.д.).
    WidgetsBinding.instance.scheduleFrame();
  }

  void _drainOneFrame() {
    _flushScheduled = false;
    if (!mounted) return;

    final cap = widget.maxRecordsPerFrame;
    final n = _pending.length > cap ? cap : _pending.length;
    if (n == 0) return;

    final batch = List<LogRecord>.of(_pending.sublist(0, n));
    _pending.removeRange(0, n);

    if (!_stickToBottom) {
      _newWhileScrolledUp += batch.length;
    }

    _records.addAll(batch);
    if (_records.length > widget.maxEntries) {
      final keep = widget.maxEntries;
      _records.removeRange(0, _records.length - keep);
    }

    _syncVisible();
    // ignore: no-empty-block, empty setState is used to trigger a rebuild
    setState(() {});

    if (_stickToBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    if (_pending.isNotEmpty) {
      _scheduleFlush();
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  void _jumpToBottomAndClearBadge() {
    setState(() => _newWhileScrolledUp = 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stickToBottom = true;
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = LoggerLn.of(context);
    final filtered =
        _searchQuery.isNotEmpty || _minLevel.level > LogLevel.trace.level;
    final countLabel = filtered
        ? '${_visible.length} / ${_records.length}'
        : '${_records.length}';
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appBarTitle),
        actions: [
          if (_pendingDropped > 0)
            Center(
              child: Padding(
                padding: const .only(right: 8),
                child: Text(
                  l10n.pendingDropped(_pendingDropped),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ),
          Text(countLabel, style: theme.textTheme.labelLarge),
          const SizedBox(width: 4),
          IconButton(
            tooltip: l10n.filterTooltip,
            icon: Icon(
              filtered ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: filtered ? theme.colorScheme.primary : null,
            ),
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            padding: const .only(bottom: 72),
            itemCount: _visible.length,
            itemBuilder: (context, i) => LogRow(
              record: _visible[i],
              onTap: () => openDetail(context, _visible[i]),
            ),
          ),
          if (_newWhileScrolledUp > 0)
            Positioned(
              right: 16,
              bottom: 24,
              child: FilledButton.tonal(
                onPressed: _jumpToBottomAndClearBadge,
                child: Text('↓ $_newWhileScrolledUp'),
              ),
            ),
        ],
      ),
    );
  }
}
