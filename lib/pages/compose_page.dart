import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../email_sender.dart';
import '../emailjs_config.dart';
import '../greeting.dart';
import '../greeting_wall.dart';

class ComposePage extends StatefulWidget {
  const ComposePage({super.key});

  @override
  State<ComposePage> createState() => _ComposePageState();
}

class _ComposePageState extends State<ComposePage> {
  final _formKey = GlobalKey<FormState>();
  final _message = TextEditingController();
  final _senderEmail = TextEditingController();
  final _recipientEmail = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _message.dispose();
    _senderEmail.dispose();
    _recipientEmail.dispose();
    super.dispose();
  }

  String? _emailValidator(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email';
    }
    return null;
  }

  Future<void> _send() async {
    if (_sending || !_formKey.currentState!.validate()) {
      return;
    }

    final greeting = Greeting(
      message: _message.text.trim(),
      senderEmail: _senderEmail.text.trim(),
      recipientEmail: _recipientEmail.text.trim(),
    );
    final payload = greeting.toPayload();
    final cardUrl = cardShareUrl(payload);

    setState(() => _sending = true);
    var emailed = false;
    var wallSaved = false;
    try {
      if (kIsWeb && EmailJsConfig.isConfigured) {
        final emailFuture = sendGreetingEmail(
          greeting: greeting,
          cardUrl: cardUrl,
        );
        final wallFuture = publishPublicNote(greeting.message);
        await emailFuture;
        emailed = true;
        try {
          await wallFuture;
          wallSaved = true;
        } catch (_) {
          wallSaved = false;
        }
      }
      if (!mounted) {
        return;
      }
      await Navigator.of(context).pushNamed(
        '/sent?d=$payload&e=${emailed ? '1' : '0'}&w=${wallSaved ? '1' : '0'}',
      );
    } on EmailSendException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send email: ${error.details}')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not send email. Try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
              children: [
                Text(
                  'Greeting Card',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontFamily: 'serif',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Write a greeting, enter your email and the recipient email, then send it.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 28),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _message,
                            minLines: 4,
                            maxLines: 8,
                            enabled: !_sending,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: 'Greeting message',
                              alignLabelWithHint: true,
                              hintText: 'Write something kind…',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please write a greeting';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _senderEmail,
                            enabled: !_sending,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            decoration: const InputDecoration(
                              labelText: 'Your email',
                            ),
                            validator: _emailValidator,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _recipientEmail,
                            enabled: !_sending,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            decoration: const InputDecoration(
                              labelText: 'Recipient email',
                              helperText:
                                  'The person who should receive this greeting',
                            ),
                            validator: _emailValidator,
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: _sending ? null : _send,
                            child: _sending
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Send greeting'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/stats');
                  },
                  child: const Text('Greetings sent today'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
