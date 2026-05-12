import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:logger_ui/src/l10n/logger_ln.dart';
import 'package:logger_ui/src/log_viewer_formatting.dart';

const levelChoices = <LogLevel>[
  .trace,
  .debug,
  .info,
  .warning,
  .error,
  .fatal,
];

class FilterSheet extends StatefulWidget {
  const FilterSheet({
    super.key,
    required this.searchCtrl,
    required this.searchQuery,
    required this.minLevel,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onLevelSelected,
  });

  final TextEditingController searchCtrl;
  final String searchQuery;
  final LogLevel minLevel;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<LogLevel> onLevelSelected;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late LogLevel _minLevel = widget.minLevel;
  late String _searchQuery = widget.searchQuery;

  void _onClearSearch() {
    widget.onClearSearch();
    setState(() => _searchQuery = '');
  }

  void _onSearchChanged(String v) {
    widget.onSearchChanged(v);
    setState(() => _searchQuery = v.trim().toLowerCase());
  }

  void _onChipSelected(LogLevel lvl) {
    widget.onLevelSelected(lvl);
    setState(() => _minLevel = lvl);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = LoggerLn.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: .only(
        left: 16,
        right: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: [
          Text(l10n.filterSheetTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(
            controller: widget.searchCtrl,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: l10n.clearSearchTooltip,
                      onPressed: _onClearSearch,
                    ),
              border: const OutlineInputBorder(),
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 20),
          Text(l10n.minLevelLabel, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final lvl in levelChoices)
                ChoiceChip(
                  label: Text(lvl.name),
                  selected: _minLevel == lvl,
                  selectedColor: levelColor(lvl, cs).withValues(alpha: 0.2),
                  onSelected: (_) => _onChipSelected(lvl),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
