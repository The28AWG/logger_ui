import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:logger_ui/src/log_viewer_detail_widgets.dart';

String fmtTime(DateTime t) {
  final h = t.hour.toString().padLeft(2, '0');
  final m = t.minute.toString().padLeft(2, '0');
  final s = t.second.toString().padLeft(2, '0');
  final ms = t.millisecond.toString().padLeft(3, '0');
  return '$h:$m:$s.$ms';
}

Color levelColor(LogLevel l, ColorScheme cs) {
  if (identical(l, LogLevel.trace) || identical(l, LogLevel.debug)) {
    return cs.outline;
  }
  if (identical(l, LogLevel.info)) {
    return cs.primary;
  }
  if (identical(l, LogLevel.warning)) {
    return cs.tertiary;
  }
  if (identical(l, LogLevel.error) || identical(l, LogLevel.fatal)) {
    return cs.error;
  }
  return cs.onSurface;
}

String contextValueString(Object? v) {
  if (v == null) return 'null';
  return v.toString();
}

void openDetail(BuildContext context, LogRecord r) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.45,
        minChildSize: 0.2,
        maxChildSize: 0.92,
        builder: (_, scroll) {
          final sheetW = MediaQuery.sizeOf(ctx).width;
          return SizedBox(
            width: sheetW,
            child: SingleChildScrollView(
              controller: scroll,
              padding: const .all(16),
              child: SizedBox(
                width: .infinity,
                child: SelectionArea(child: LogRecordDetail(record: r)),
              ),
            ),
          );
        },
      ),
    );
