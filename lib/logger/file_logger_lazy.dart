import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

/*
  The BaseLogger abstract class aligns with the Interface Segregation Principle (ISP) by defining
  a single operation, 'log'. This design allows concrete classes to implement only what they need
  for records management, adhering to ISP. Additionally, by defining 'BaseLogger' as an abstraction
  for the 'log' operation, it adheres to the Dependency Inversion Principle (DIP), allowing classes
  to depend on abstractions rather than concrete implementations, promoting flexibility and inversion
  of dependencies.
 */
abstract class BaseLogger {
  @protected
  late Logger _logger;
  @protected
  static const appName = 'singleton_pattern_example_lazy';

  void log(message, [Object? error, StackTrace? stackTrace]) =>
      _logger.info(message, error, stackTrace);
}

/*
  FileLoggerLazy is a 'lazy' Singleton, aligning with the SRP by managing logging to a file.
  Its instantiation is deferred until it's first used, optimizing resource usage. This lazy
  instantiation approach is also in line with the DIP, as it allows for flexibility in the
  timing and method of creation of the logger instance.
 */
class FileLoggerLazy extends BaseLogger {
  // Static instance, initialized when first accessed.
  static FileLoggerLazy? _instance;
  final String _logFileName = 'log_lazy.txt';
  File? _logFile;

  // Private constructor prevents external instantiation.
  FileLoggerLazy._internal() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen(_recordHandler);
    _logger = Logger(BaseLogger.appName);
    print('Lazy Logger Initialized');
  }

  //public constructor
  factory FileLoggerLazy() => _instance ??= FileLoggerLazy._internal();

  // Method to load log file contents, adhering to SRP and OCP.
  Future<void> _loadLogFileContents() async {
    final directory = await getApplicationDocumentsDirectory();
    _logFile = File('${directory.path}/$_logFileName');
  }

  // Handles record management, following SRP.
  void _recordHandler(LogRecord rec) {
    final formattedMessage = '${rec.time}: ${rec.message}';
    _writeToFile(formattedMessage);
  }

  /*
    The _writeToFile method complies with SRP by having the single responsibility of writing
    the log contents to a file. It also adheres to OCP as it's designed in a way that it's
    extensible for future modifications without the need to modify the existing code.
  */
  Future<void> _writeToFile(String message) async {
    await _loadLogFileContents();
    await _logFile!.writeAsString('$message\n', mode: FileMode.append);
  }
}
