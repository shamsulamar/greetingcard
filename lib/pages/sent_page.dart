import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../greeting.dart';

class SentPage extends StatelessWidget {
  const SentPage({super.key, required this.payload});

  final String? payload;

  @override
  Widget build(BuildContext context) {
    final greeting = Greeting.fromPayload(payload);
    final theme = Theme.of(context);

    if (greeting == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No greeting was found.')),
      );
    }

    final shareUrl = cardShareUrl(greeting.toPayload());

    return Scaffold(
      appBar: AppBar(title: const Text('Ready to share')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
              children: [
                Text(
                  'Demo only: email is not sent from GitHub Pages.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Share this link with ${greeting.recipientEmail}. They can open it and accept the greeting.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                SelectableText(shareUrl, style: theme.textTheme.bodySmall),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: shareUrl));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Card link copied')),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy card link'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/card?d=${greeting.toPayload()}');
                  },
                  child: const Text('Preview recipient view'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
