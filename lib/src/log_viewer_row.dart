import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:logger_ui/src/log_viewer_formatting.dart';

class LogRow extends StatelessWidget {
  const LogRow({required this.record, required this.onTap});

  final LogRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lc = levelColor(record.logLevel, cs);
    final hasExtra =
        record.exception != null ||
        record.error != null ||
        record.stackTrace != null ||
        (record.context != null && record.context!.isNotEmpty);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const .symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              crossAxisAlignment: .center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: .alphaBlend(lc.withValues(alpha: 0.16), cs.surface),
                    borderRadius: .circular(4),
                    border: Border.all(color: lc.withValues(alpha: 0.38)),
                  ),
                  child: Padding(
                    padding: const .symmetric(horizontal: 6, vertical: 3),
                    child: Text(
                      fmtTime(record.time),
                      style: TextStyle(
                        fontSize: 11,
                        color: lc,
                        fontWeight: .w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${record.logLevel.name} · ${record.name}${record.tag != null ? ' #${record.tag}' : ''}',
                    style: TextStyle(
                      fontSize: 11,
                      color: lc,
                      fontWeight: .w600,
                    ),
                    maxLines: 2,
                    overflow: .ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              record.message ?? '',
              maxLines: 3,
              overflow: .ellipsis,
              style: TextStyle(fontSize: 13, color: cs.onSurface),
            ),
            if (hasExtra)
              Padding(
                padding: const .only(top: 2),
                child: Icon(Icons.more_horiz, size: 16, color: cs.outline),
              ),
          ],
        ),
      ),
    );
  }
}
