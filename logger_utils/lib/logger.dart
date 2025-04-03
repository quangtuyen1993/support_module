import 'package:talker_flutter/talker_flutter.dart';

final logger = Logger.instance;

class Logger {
  final Talker _talker;
  Logger._internal(this._talker);
  static Logger init() {
    final talker = TalkerFlutter.init();
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
