import 'package:logger/logger.dart';

// Global logger instance with pretty printer for colorful, readable logs
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1, // Number of stacktrace lines to show
    errorMethodCount: 8, // Number of stacktrace lines for errors
    lineLength: 100, // Width of each log line
    colors: true, // Colorful log output
    printEmojis: true, // Emojis for each log type
    printTime: false, // Don't print timestamp
  ),
);
