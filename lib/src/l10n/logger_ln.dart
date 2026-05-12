// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'logger_ln_en.dart';
import 'logger_ln_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of LoggerLn
/// returned by `LoggerLn.of(context)`.
///
/// Applications need to include `LoggerLn.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/logger_ln.dart';
///
/// return MaterialApp(
///   localizationsDelegates: LoggerLn.localizationsDelegates,
///   supportedLocales: LoggerLn.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the LoggerLn.supportedLocales
/// property.
abstract class LoggerLn {
  LoggerLn(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static LoggerLn of(BuildContext context) {
    return Localizations.of<LoggerLn>(context, LoggerLn)!;
  }

  static const LocalizationsDelegate<LoggerLn> delegate = _LoggerLnDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// Title of the log viewer screen
  ///
  /// In ru, this message translates to:
  /// **'Логи'**
  String get appBarTitle;

  /// Label shown when pending log records were dropped
  ///
  /// In ru, this message translates to:
  /// **'очередь −{count}'**
  String pendingDropped(int count);

  /// Tooltip for the filter action button in the app bar
  ///
  /// In ru, this message translates to:
  /// **'Фильтр'**
  String get filterTooltip;

  /// Section label for log message in detail view
  ///
  /// In ru, this message translates to:
  /// **'Сообщение'**
  String get sectionMessage;

  /// Section label for context map in detail view
  ///
  /// In ru, this message translates to:
  /// **'Контекст'**
  String get sectionContext;

  /// Section label for error in detail view
  ///
  /// In ru, this message translates to:
  /// **'Error'**
  String get sectionError;

  /// Section label for exception in detail view
  ///
  /// In ru, this message translates to:
  /// **'Исключение'**
  String get sectionException;

  /// Section label for stack trace in detail view
  ///
  /// In ru, this message translates to:
  /// **'Стек вызовов'**
  String get sectionStackTrace;

  /// Title of the filter bottom sheet
  ///
  /// In ru, this message translates to:
  /// **'Фильтр'**
  String get filterSheetTitle;

  /// Hint text for the search field in filter sheet
  ///
  /// In ru, this message translates to:
  /// **'Поиск в сообщении, имени, теге, контексте…'**
  String get searchHint;

  /// Tooltip for the clear search button
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get clearSearchTooltip;

  /// Label above the log level chips in filter sheet
  ///
  /// In ru, this message translates to:
  /// **'Минимальный уровень'**
  String get minLevelLabel;
}

class _LoggerLnDelegate extends LocalizationsDelegate<LoggerLn> {
  const _LoggerLnDelegate();

  @override
  Future<LoggerLn> load(Locale locale) {
    return SynchronousFuture<LoggerLn>(lookupLoggerLn(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_LoggerLnDelegate old) => false;
}

LoggerLn lookupLoggerLn(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return LoggerLnEn();
    case 'ru':
      return LoggerLnRu();
  }

  throw FlutterError(
    'LoggerLn.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
