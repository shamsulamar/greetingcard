import 'package:flutter/material.dart';

import '../greeting.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key, required this.payload});

  final String? payload;

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    final greeting = Greeting.fromPayload(widget.payload);
    final theme = Theme.of(context);

    if (greeting == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This greeting link is invalid.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('A greeting for you')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    child: _accepted
                        ? _OpenedCard(greeting: greeting)
                        : _SealedCard(
                            greeting: greeting,
                            onAccept: () => setState(() => _accepted = true),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SealedCard extends StatelessWidget {
  const _SealedCard({required this.greeting, required this.onAccept});

  final Greeting greeting;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('sealed'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.mail_outline, size: 56, color: theme.colorScheme.primary),
        const SizedBox(height: 20),
        Text(
          'A greeting is waiting',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(fontFamily: 'serif'),
        ),
        const SizedBox(height: 12),
        Text(
          'From ${greeting.senderEmail}\nTo ${greeting.recipientEmail}',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: onAccept,
          child: const Text('Accept greeting'),
        ),
      ],
    );
  }
}

class _OpenedCard extends StatelessWidget {
  const _OpenedCard({required this.greeting});

  final Greeting greeting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('opened'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Accepted',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          greeting.message,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontFamily: 'serif',
            height: 1.4,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'From ${greeting.senderEmail}',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
