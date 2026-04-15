# Beholder 👁️

Beholder is a powerful and fully customizable logging library for Dart and Flutter, designed with performance and flexibility in mind. It moves away from global singletons to a clean, instance-based architecture.

## Key Concepts 💡

### Instance-Based
Beholder avoids global state. You create logger instances, allowing you to easily isolate logging logic for different modules of your application.

### Lifecycle Management 🔄
Many transports (databases, files, network clients) require asynchronous preparation. Beholder handles their initialization and disposal automatically.

## Installation 📦

Add `beholder` to your `pubspec.yaml`:

```yaml
dependencies:
  beholder: ^0.9.7
```

## Quick Start 🚀

### 1. Define Your Options
Create a class that describes your logging levels, converters, and transports:

```dart
final class MyOptions extends BeholderOptions<String> {
  @override
  int get logLevel => 0; // Process all logs

  @override
  List<LogLevel> get levels => [
    LogLevel(
      level: 10,
      name: 'info',
      transports: [ConsoleTransport()],
    ),
    LogLevel(
      level: 50,
      name: 'error',
      transports: [ConsoleTransport(), FileTransport(filePath: 'logs.txt')],
    ),
  ];
  
  @override
  List<LogEntryConverter> get converters => [
    // Automatically format DateTime objects in logs
    LogEntryConverter<DateTime>(onConvert: (dt) => dt.toIso8601String()),
  ];
}
```

### 2. Create Your Logger
Inherit from the base `Beholder` class to create a type-safe logger:

```dart
base class MyLogger extends Beholder<String> {
  MyLogger() : super(name: 'Main', settings: MyOptions());

  void info(Object message) => log(entry: LogEntry(message), level: 10);
  void error(Object message, {Object? error, StackTrace? st}) => 
      log(entry: LogEntry(message, error: error, stackTrace: st), level: 50);
}
```

### 3. Usage ✅
**Important:** if your transports require initialization, you must call `init()`.

```dart
void main() async {
  final logger = MyLogger();
  
  // Initialization (asynchronously prepares all transports)
  await logger.init();

  logger.info('Hello, Beholder!');
  logger.error('Something went wrong', error: Exception('Oops'));

  // Shutdown
  await logger.dispose();
}
```

## Initialization Guard 🛡️
If you attempt to log using a logger that contains transports with `needsInit: true` without calling `await logger.init()`, the library will throw a `StateError`. This ensures that important logs are not lost because a file or database wasn't ready.

## Formatting & Adapters 🛠️
You can easily wrap existing transports to change their formatting without creating new classes:

```dart
final customTransport = TransportAdapter(
  transport: ConsoleTransport(),
  onLog: (record) => '[${record.time}] ${record.description}',
);
```

## Performance ⚡
Beholder is optimized for high-load applications:
- **Zero-Allocation Metadata**: System placeholders like level names and timestamps use cached values.
- **Lazy Evaluation**: Complex log values are computed only when actually needed by transports.
- **Efficient Dispatch**: Uses `Future.value` and `unawaited` for non-blocking transport execution.

## License 📄
MIT
