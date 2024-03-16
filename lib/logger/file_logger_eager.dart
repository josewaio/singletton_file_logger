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
  static const appName = 'singleton_pattern_example_eager';

  void log(message, [Object? error, StackTrace? stackTrace]) =>
      _logger.info(message, error, stackTrace);
}

/*
  FileLoggerEager is an 'eager' Singleton, meaning its single instance is created at class loading time.
  This approach ensures a single instance throughout the application, in line with the Singleton pattern.
  The primary responsibility of FileLoggerEager is to manage logging to a file, aligning with the
  Single Responsibility Principle (SRP).
 */
class FileLoggerEager extends BaseLogger {
  // Static and final instance, created at class loading time.
  static final FileLoggerEager _instance = FileLoggerEager._internal();
  final String _logFileName = "log_eager.txt";
  File? _logFile;

  // Private constructor prevents external instantiation.
  FileLoggerEager._internal() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen(_recordHandler);
    _logger = Logger(BaseLogger.appName);
    print('Eager Logger Initialized');
    _initializeLogFile();
  }

  // Factory constructor returns the single instance.
  factory FileLoggerEager() {
    return _instance;
  }

  // Initializes log file.
  Future<void> _initializeLogFile() async {
    final directory = await getApplicationDocumentsDirectory();
    _logFile = File('${directory.path}/$_logFileName');
  }

  // Handles record management, following SRP.
  void _recordHandler(LogRecord rec) {
    final formattedMessage = '${rec.time}: ${rec.message}';
    _writeToFile(formattedMessage);
  }

  // Writes log contents to a file, complying with SRP and OCP.
  Future<void> _writeToFile(String message) async {
    await _logFile!.writeAsString('$message\n', mode: FileMode.append);
  }
}
