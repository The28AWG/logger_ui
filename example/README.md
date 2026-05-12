# logger_ui — пример использования

Демонстрационное Flutter-приложение для пакета [`logger_ui`](../README.md).

## Что показывает пример

Приложение запускает генератор тестовых логов, который циклически эмитирует записи разных уровней с переменными задержками:

| Уровень | Пример сообщения |
|---|---|
| `trace` | Трассировка: шаг 3 из пайплайна fetch |
| `debug` | Отладка: кэш hit ratio 0.82 |
| `info` | Инфо: сессия создана, id=7f3a… |
| `warning` | Предупреждение: retry #2 к /api/v1/status |
| `info` | Большой текст (~48 строк Lorem ipsum) |
| `error` | Ошибка с объектом `error` без stack trace |
| `error` | Ошибка с пойманным `FormatException` и stack trace |
| `error` | Ошибка без исключения |
| `fatal` | Критично: потеряно соединение с хранилищем |

## Запуск

```bash
cd example
flutter pub get
flutter run
```

## Структура

```
example/
├── lib/
│   └── main.dart   # точка входа + генератор логов
└── pubspec.yaml    # зависимости (logger и logger_ui — по локальному пути)
```

## Ключевые моменты кода

### Подключение локализации

```dart
MaterialApp(
  localizationsDelegates: LoggerLn.localizationsDelegates,
  supportedLocales: LoggerLn.supportedLocales,
  locale: const Locale('en'), // или 'ru'
  home: const LogViewerScreen(),
);
```

### Использование глобального логгера

```dart
final logger = Logger('main');
logger.trace('...');
logger.debug('...');
logger.info('...');
logger.warning('...');
logger.error('сообщение', error: someError);
logger.error('сообщение', exception: e, stackTrace: st);
logger.fatal('...');
```

`LogViewerScreen` по умолчанию подключается к глобальному `loggerController`, поэтому явно передавать контроллер не нужно.
