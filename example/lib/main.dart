import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:logger_ui/logger_ui.dart';

String _bigLogBlob() {
  final b = StringBuffer(
    'Большой текст (${DateTime.now().toIso8601String()}):\n',
  );
  for (var i = 0; i < 48; i++) {
    b.writeln(
      '[$i] Quis autem vel eum iure reprehenderit qui in ea voluptate velit '
      'esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat.',
    );
  }
  return b.toString();
}

Never _demoThrow() => throw FormatException('невалидный фрагмент', '{"a":');

void _logErrorWithStack(Logger l) {
  try {
    _demoThrow();
  } on FormatException catch (e, st) {
    l.error(
      'Сообщение со стеком: сбой при разборе конфигурации',
      exception: e,
      stackTrace: st,
    );
  }
}

void _startDemoLogGenerator(Logger logger) {
  var n = 0;
  final entries = <(void Function(Logger), Duration)>[
    (
      (l) => l.trace('Трассировка: шаг 3 из пайплайна fetch'),
      const Duration(milliseconds: 350),
    ),
    (
      (l) => l.debug('Отладка: кэш hit ratio 0.82'),
      const Duration(milliseconds: 600),
    ),
    (
      (l) => l.info('Инфо: сессия создана, id=7f3a…'),
      const Duration(milliseconds: 900),
    ),
    (
      (l) => l.warning('Предупреждение: retry #2 к /api/v1/status'),
      const Duration(milliseconds: 1400),
    ),
    ((l) => l.info(_bigLogBlob()), const Duration(milliseconds: 1600)),
    (
      (l) => l.error(
        'Сообщение с ошибкой (без stack trace)',
        error: StateError('ожидался положительный id'),
      ),
      const Duration(milliseconds: 1800),
    ),
    ((l) => _logErrorWithStack(l), const Duration(milliseconds: 2000)),
    (
      (l) => l.error('Ошибка: не удалось распарсить ответ (EOF)'),
      const Duration(milliseconds: 2200),
    ),
    (
      (l) => l.fatal('Критично: потеряно соединение с хранилищем'),
      const Duration(milliseconds: 3000),
    ),
  ];
  void step() {
    final (emit, delay) = entries[n++ % entries.length];
    Timer(delay, () {
      emit(logger);
      step();
    });
  }

  step();
}

void main() {
  final logger = Logger('main');
  runApp(const MyApp());
  _startDemoLogGenerator(logger);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Flutter Demo',
    home: const LogViewerScreen(),
    localizationsDelegates: LoggerLn.localizationsDelegates,
    supportedLocales: LoggerLn.supportedLocales,
    locale: const Locale('en'),
  );
}
