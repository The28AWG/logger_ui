// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'logger_ln.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class LoggerLnRu extends LoggerLn {
  LoggerLnRu([String locale = 'ru']) : super(locale);

  @override
  String get appBarTitle => 'Логи';

  @override
  String pendingDropped(int count) {
    return 'очередь −$count';
  }

  @override
  String get filterTooltip => 'Фильтр';

  @override
  String get sectionMessage => 'Сообщение';

  @override
  String get sectionContext => 'Контекст';

  @override
  String get sectionError => 'Error';

  @override
  String get sectionException => 'Исключение';

  @override
  String get sectionStackTrace => 'Стек вызовов';

  @override
  String get filterSheetTitle => 'Фильтр';

  @override
  String get searchHint => 'Поиск в сообщении, имени, теге, контексте…';

  @override
  String get clearSearchTooltip => 'Сбросить';

  @override
  String get minLevelLabel => 'Минимальный уровень';
}
