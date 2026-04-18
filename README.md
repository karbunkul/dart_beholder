# Beholder 👁️

Beholder is a powerful, fully customizable logging library for Dart and Flutter, built with a focus on performance, structured data, and clean architecture. Unlike other solutions, Beholder avoids global singletons in favor of a strictly instance-based approach.

## Key Features 💡

### Instance-Based Architecture
No global state. Create independent logger instances for different modules, layers, or environments. This makes testing and isolation effortless.

### Async Lifecycle & State Guards 🔄
Many transports (databases, files, network clients) require asynchronous setup. Beholder manages their `init()` and `dispose()` cycles, protecting your system from using uninitialized resources via **State Guards**.

### Advanced Transport Filtering 🛡️
Fine-tune which data each transport handles with precision:
- **Whitelist (`allowedTypes`)**: Only process specific data types (e.g., only `Request/Response` for a network logger).
- **Blacklist (`ignoredTypes`)**: Skip "noisy" types (e.g., `Heartbeat` or `AnalyticsEvent`).
- **Synchronous Checks**: Filtering happens instantly before any expensive record processing begins.

### Smart Placeholders 🧩
Beholder uses a lazy, high-performance templating system. You can use built-in placeholders or provide custom ones via `ContextPlaceholder`.

**Standard system placeholders (available in every record):**
- `{logName}`: The name of the logger instance.
- `{logLevel}`: Numeric representation of the log level (e.g., `100`).
- `{logLevelName}`: Human-readable level name (e.g., `INFO`).
- `{logTags}`: String representation of the associated tags.
- `{logDateTime}`: Local ISO8601 timestamp.
- `{logDateTimeUtc}`: UTC ISO8601 timestamp.
- `{logData}`: The main data object, formatted using the matching `LogEntryConverter`.
- `{logMessage}`: The optional message string from the `LogEntry`.

All placeholders are resolved **lazily**. For example, `{logData}` will only trigger the converter's `onConvert` function if a transport actually contains this placeholder in its output format.

**Programmatically list all available keys:**
If you are building a custom transport and need to know which keys are available:
```dart
@override
Future<String> log(RecordEntry<Object> record) async {
  final availableKeys = record.placeholder.available(); 
  print('Available placeholders: $availableKeys');
  
  // Use the manager to resolve a specific template
  return record.placeholder.template('[{logLevelName}] {logData}');
}
```

## Performance ⚡
Beholder v0.9.8 is engineered for high-load applications:
- **Lazy Evaluation**: Expensive operations, such as formatting complex objects into strings (`logData`), are only performed when a transport actually requests them.
- **O(1) Converter Lookups**: Finding the right converter for a data type is a constant-time operation thanks to built-in type caching and "warm-up" during initialization.
- **Internal Caching**: Formatted data is computed exactly once per record, even if dispatched to multiple transports.
- **Zero-Block Dispatch**: Utilizes `Future.value` and `unawaited` to ensure logging never blocks your app's main execution flow.

## Quick Start 🚀

### 1. Configure Options
Define your log levels, converters, and transports:

```dart
final class MyOptions extends BeholderOptions<AppTag> {
  @override
  int get logLevel => 0; 

  @override
  List<LogLevel> get levels => [
    LogLevel(
      level: 100,
      name: 'info',
      transports: [
        // Use TransportAdapter for fine-grained control
        TransportAdapter(
          transport: ConsoleTransport(),
          ignoredTypes: {Heartbeat}, // Skip technical noise in console
          onLog: (record) => '[${record.time}] ${record.description}',
        ),
      ],
    ),
  ];
  
  @override
  List<LogEntryConverter> get converters => [
    LogEntryConverter<DateTime>(onConvert: (dt) => dt.toIso8601String()),
    LogEntryConverter<User>(onConvert: (u) => 'User(id: ${u.id})'),
  ];
}
```

### 2. Create Your Logger
```dart
base class MyLogger extends Beholder<AppTag> {
  MyLogger() : super(name: 'App', settings: MyOptions());

  void info(Object data, {List<AppTag>? tags}) => 
      log(entry: LogEntry(data), level: 100, tags: tags);
}
```

### 3. Use It ✅
```dart
void main() async {
  final logger = MyLogger();
  
  // Mandatory initialization for async transports
  await logger.init();

  logger.info('Application started');
  logger.info(Heartbeat(), tags: [AppTag.system]); // Ignored by console transport

  // Graceful shutdown
  await logger.dispose();
}
```

## Installation 📦

Add `beholder` to your `pubspec.yaml`:

```yaml
dependencies:
  beholder: ^0.9.8
```

## License 📄
MIT
