import 'package:flutter/material.dart';
import 'package:rss_it/ui/home_screen.dart';

ThemeData _applicationTheme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: switch (brightness) {
      Brightness.light => const Color(0xFF007AFF),
      Brightness.dark => const Color(0xFF0A84FF),
    },
    brightness: brightness,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: brightness,
  );

  return base.copyWith(
    appBarTheme: base.appBarTheme.copyWith(
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: base.cardTheme.copyWith(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    dropdownMenuTheme: base.dropdownMenuTheme.copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
    ),
  );
}

final class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RSSit',
      debugShowCheckedModeBanner: false,
      theme: _applicationTheme(Brightness.light),
      darkTheme: _applicationTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
