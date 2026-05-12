# logger_ui

Flutter-виджеты для просмотра потока [`LogRecord`](https://github.com/The28AWG/logger) из пакета `logger`.

## Возможности

- **`LogViewerScreen`** — полноэкранный `Scaffold` со списком записей логов в реальном времени.
- Батчинг входящего потока: события копятся в очередь и сбрасываются в UI пачками за один кадр, не блокируя поток.
- Ограничение памяти: хранится не более `maxEntries` последних записей (по умолчанию 20 000).
- Защита от взрыва очереди: если между кадрами скопилось больше `maxPendingBetweenFrames` записей, лишние отбрасываются (счётчик в AppBar).
- Фильтрация по уровню (`trace` / `debug` / `info` / `warning` / `error` / `fatal`) через боттом-шит.
- Текстовый поиск по сообщению, имени логгера, тегу, ошибке и полям контекста.
- Автопрокрутка к новым записям; бейдж «↓ N» при ручной прокрутке вверх.
- Детальный просмотр записи (боттом-шит с `SelectionArea`).
- Локализация: `en`, `ru` (легко расширяется).

## Установка

```yaml
dependencies:
  logger_ui:
    git:
      url: https://github.com/The28AWG/logger_ui.git
```

Добавьте делегаты локализации в `MaterialApp`:

```dart
import 'package:logger_ui/logger_ui.dart';

MaterialApp(
  localizationsDelegates: LoggerLn.localizationsDelegates,
  supportedLocales: LoggerLn.supportedLocales,
  home: const LogViewerScreen(),
);
```

## Использование

### Минимальный пример

```dart
import 'package:flutter/material.dart';
import 'package:logger_ui/logger_ui.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    localizationsDelegates: LoggerLn.localizationsDelegates,
    supportedLocales: LoggerLn.supportedLocales,
    home: const LogViewerScreen(),
  );
}
```

### Параметры `LogViewerScreen`

| Параметр | Тип | По умолчанию | Описание |
|---|---|---|---|
| `controller` | `LoggerController?` | глобальный `loggerController` | Контроллер логгера |
| `maxEntries` | `int` | `20000` | Максимум записей в памяти |
| `maxPendingBetweenFrames` | `int` | `8000` | Лимит очереди между кадрами |
| `maxRecordsPerFrame` | `int` | `2500` | Максимум записей, переносимых в модель за один кадр |

### Свой контроллер

```dart
final myController = LoggerController();
final logger = Logger('app', controller: myController);

LogViewerScreen(controller: myController)
```

## Структура пакета

```
lib/
├── logger_ui.dart                  # публичный экспорт
└── src/
    ├── log_viewer_screen.dart       # основной экран
    ├── log_viewer_row.dart          # строка списка
    ├── log_viewer_detail_widgets.dart # детальный просмотр
    ├── log_viewer_filter_sheet.dart # боттом-шит фильтров
    ├── log_viewer_formatting.dart   # форматирование времени и цветов
    └── l10n/                        # локализация
```

## Требования

- Flutter `>=1.17.0`
- Dart `^3.11.5`
- Пакет [`logger`](https://github.com/The28AWG/logger)

## Лицензия

[BSD 3-Clause](LICENSE)
