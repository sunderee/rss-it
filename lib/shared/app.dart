import 'package:flutter/material.dart';
import 'package:rss_it/ui/home_screen.dart';

ThemeData _applicationTheme(Brightness brightness) => ThemeData.from(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    seedColor: switch (brightness) {
      Brightness.light => const Color(0xFF007AFF),
      Brightness.dark => const Color(0xFF0A84FF),
    },
  ),
);

final class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _applicationTheme(Brightness.light),
      darkTheme: _applicationTheme(Brightness.dark),
      home: const HomeScreen(),
    );
  }
}
