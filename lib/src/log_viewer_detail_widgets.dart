import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:logger_ui/src/l10n/logger_ln.dart';
import 'package:logger_ui/src/log_viewer_formatting.dart';

class LogRecordDetail extends StatelessWidget {
  const LogRecordDetail({required this.record});

  final LogRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final lc = levelColor(record.logLevel, cs);
    final l10n = LoggerLn.of(context);
    final msg = record.message;
    final ctxMap = record.context;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          crossAxisAlignment: .center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: .alphaBlend(lc.withValues(alpha: 0.16), cs.surface),
                borderRadius: .circular(6),
                border: Border.all(color: lc.withValues(alpha: 0.38)),
              ),
              child: Padding(
                padding: const .symmetric(horizontal: 8, vertical: 5),
                child: Text(
                  fmtTime(record.time),
                  style: TextStyle(
                    fontSize: 12,
                    color: lc,
                    fontWeight: .w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: .alphaBlend(lc.withValues(alpha: 0.22), cs.surface),
                borderRadius: .circular(6),
                border: Border.all(color: lc.withValues(alpha: 0.45)),
              ),
              child: Padding(
                padding: const .symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  record.logLevel.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.6,
                    color: lc,
                    fontWeight: .w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          record.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: .w600,
            color: cs.onSurface,
          ),
        ),
        if (record.tag != null && record.tag!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Chip(
            visualDensity: .compact,
            padding: .zero,
            labelPadding: const .symmetric(horizontal: 8),
            avatar: Icon(Icons.label_outline, size: 16, color: cs.primary),
            label: Text(
              record.tag!,
              style: theme.textTheme.labelLarge?.copyWith(color: cs.primary),
            ),
            side: BorderSide(color: cs.outlineVariant),
            backgroundColor: cs.primaryContainer.withValues(alpha: 0.35),
          ),
        ],
        if (msg != null && msg.isNotEmpty) ...[
          const SizedBox(height: 16),
          _DetailSectionLabel(text: l10n.sectionMessage, colorScheme: cs),
          const SizedBox(height: 6),
          SelectableText(
            msg,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.45,
              color: cs.onSurface,
            ),
          ),
        ],
        if (ctxMap != null && ctxMap.isNotEmpty) ...[
          const SizedBox(height: 16),
          _DetailSectionLabel(text: l10n.sectionContext, colorScheme: cs),
          const SizedBox(height: 8),
          _ContextTable(map: ctxMap, theme: theme, colorScheme: cs),
        ],
        if (record.error != null) ...[
          const SizedBox(height: 16),
          _DetailSectionLabel(text: l10n.sectionError, colorScheme: cs),
          const SizedBox(height: 6),
          _TintedDetailBlock(
            color: cs.error,
            colorScheme: cs,
            child: SelectableText(
              record.error.toString(),
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.4,
                color: cs.onErrorContainer,
              ),
            ),
          ),
        ],
        if (record.exception != null) ...[
          const SizedBox(height: 16),
          _DetailSectionLabel(text: l10n.sectionException, colorScheme: cs),
          const SizedBox(height: 6),
          _TintedDetailBlock(
            color: cs.tertiary,
            colorScheme: cs,
            child: SelectableText(
              record.exception.toString(),
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.4,
                color: cs.onTertiaryContainer,
              ),
            ),
          ),
        ],
        if (record.stackTrace != null) ...[
          const SizedBox(height: 16),
          _DetailSectionLabel(text: l10n.sectionStackTrace, colorScheme: cs),
          const SizedBox(height: 6),
          _TintedDetailBlock(
            color: cs.outline,
            colorScheme: cs,
            child: SelectableText(
              record.stackTrace.toString(),
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                height: 1.35,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DetailSectionLabel extends StatelessWidget {
  const _DetailSectionLabel({required this.text, required this.colorScheme});

  final String text;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      letterSpacing: 0.8,
      fontWeight: .w700,
      color: colorScheme.outline,
    ),
  );
}

class _TintedDetailBlock extends StatelessWidget {
  const _TintedDetailBlock({
    required this.color,
    required this.colorScheme,
    required this.child,
  });

  final Color color;
  final ColorScheme colorScheme;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: .infinity,
    decoration: BoxDecoration(
      color: .alphaBlend(color.withValues(alpha: 0.12), colorScheme.surface),
      borderRadius: .circular(8),
      border: Border.all(color: color.withValues(alpha: 0.28)),
    ),
    padding: const .all(12),
    child: child,
  );
}

class _ContextTable extends StatelessWidget {
  const _ContextTable({
    required this.map,
    required this.theme,
    required this.colorScheme,
  });

  final Map<String, Object?> map;
  final ThemeData theme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final keys = map.keys.toList()..sort();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: .circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const .symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            for (var i = 0; i < keys.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 12,
                  endIndent: 12,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              Padding(
                padding: const .symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  crossAxisAlignment: .start,
                  children: [
                    SizedBox(
                      width: 108,
                      child: Text(
                        keys[i],
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: .w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SelectableText(
                        contextValueString(map[keys[i]]),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          height: 1.35,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
