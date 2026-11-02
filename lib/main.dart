import 'package:flutter/material.dart';

import 'pages/card_page.dart';
import 'pages/compose_page.dart';
import 'pages/sent_page.dart';

void main() {
  runApp(const GreetingCardApp());
}

class GreetingCardApp extends StatelessWidget {
  const GreetingCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFFB4485B);
    return MaterialApp(
      title: 'Greeting Card',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6EFE6),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '/');
        final payload = uri.queryParameters['d'];
        final page = switch (uri.path) {
          '/card' => CardPage(payload: payload),
          '/sent' => SentPage(payload: payload),
          _ => const ComposePage(),
        };
        return MaterialPageRoute<void>(
          builder: (_) => page,
          settings: settings,
        );
      },
    );
  }
}
