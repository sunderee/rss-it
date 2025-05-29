import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rss_it/shared/app.dart';
import 'package:rss_it/shared/di.dart';
import 'package:simplest_logger/simplest_logger.dart';

void main() => runZoned(() async {
  WidgetsFlutterBinding.ensureInitialized();

  SimplestLogger.setLevel(SimplestLoggerLevel.all);
  SimplestLogger.useColors(Platform.isAndroid);
  await initializeDependencies();

  runApp(const App());
});
