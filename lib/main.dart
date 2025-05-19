import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rss_it/common/app.dart';
import 'package:rss_it/common/di.dart';
import 'package:simplest_logger/simplest_logger.dart';

void main() => runZoned(() async {
  // Initialize Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Setup logger
  SimplestLogger.setLevel(SimplestLoggerLevel.all);
  SimplestLogger.useColors(Platform.isAndroid);

  // Initialize dependencies
  await initializeDependencies();

  // Run app
  runApp(const App());
});
