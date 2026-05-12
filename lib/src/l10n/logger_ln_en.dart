// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'logger_ln.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LoggerLnEn extends LoggerLn {
  LoggerLnEn([String locale = 'en']) : super(locale);

  @override
  String get appBarTitle => 'Logs';

  @override
  String pendingDropped(int count) {
    return 'queue −$count';
  }

  @override
  String get filterTooltip => 'Filter';

  @override
  String get sectionMessage => 'Message';

  @override
  String get sectionContext => 'Context';

  @override
  String get sectionError => 'Error';

  @override
  String get sectionException => 'Exception';

  @override
  String get sectionStackTrace => 'Stack trace';

  @override
  String get filterSheetTitle => 'Filter';

  @override
  String get searchHint => 'Search in message, name, tag, context…';

  @override
  String get clearSearchTooltip => 'Clear';

  @override
  String get minLevelLabel => 'Minimum level';
}
