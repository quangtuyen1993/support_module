import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_http_logger/talker_http_logger.dart';

final logger = Logger.instance;

class Logger {
  final Talker _talker;
  Logger._internal(this._talker);
  static Logger init({Map<String, AnsiPen>? colors}) {
    final talker = TalkerFlutter.init(
      settings: TalkerSettings(
        colors:
            colors ??
            {
              TalkerLogType.httpRequest.key:
                  AnsiPen()..magenta(), // HTTP Request - Magenta
              TalkerLogType.httpResponse.key:
                  AnsiPen()..blue(), // HTTP Response - Blue
              TalkerLogType.error.key: AnsiPen()..red(), // Errors - Red
              TalkerLogType.warning.key:
                  AnsiPen()..yellow(), // Warnings - Yellow
              TalkerLogType.info.key: AnsiPen()..cyan(), // Info - Cyan
              TalkerLogType.debug.key: AnsiPen()..green(), // Debug - Green
              TalkerLogType.verbose.key: AnsiPen()..gray(), // Verbose - Gray
            },
      ),
    );
    return Logger._internal(talker);
  }

  static Logger? _instance;

  static Logger get instance {
    _instance ??= Logger.init();
    return _instance!;
  }

  void debug(dynamic msg, [Object? exception, StackTrace? stackTrace]) {
    instance._talker.debug(msg, exception, stackTrace);
  }

  void info(dynamic msg, [Object? exception, StackTrace? stackTrace]) {
    instance._talker.info(msg, exception, stackTrace);
  }

  void error(dynamic msg, [Object? exception, StackTrace? stackTrace]) {
    instance._talker.error(msg, exception, stackTrace);
  }

  void warning(dynamic msg, [Object? exception, StackTrace? stackTrace]) {
    instance._talker.warning(msg, exception, stackTrace);
  }

  void verbose(dynamic msg, [Object? exception, StackTrace? stackTrace]) {
    instance._talker.verbose(msg, exception, stackTrace);
  }

  void critical(dynamic msg, [Object? exception, StackTrace? stackTrace]) {
    instance._talker.critical(msg, exception, stackTrace);
  }
}

Interceptor loggerInterceptor() {
  return TalkerDioLogger(
    settings: TalkerDioLoggerSettings(
      printResponseData: true,
      printRequestData: false,
      printResponseHeaders: true,
      printRequestHeaders: false,
      requestPen: AnsiPen()..blue(),
      // Green http responses logs in console
      responsePen: AnsiPen()..green(),
      // Error http logs in console
      errorPen: AnsiPen()..red(),
    ),
  );
}

TalkerHttpLogger httpLogger() {
  return TalkerHttpLogger(talker: Logger.instance._talker);
}
