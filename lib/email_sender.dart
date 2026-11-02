import 'dart:convert';

import 'package:http/http.dart' as http;

import 'emailjs_config.dart';
import 'greeting.dart';

class EmailNotConfiguredException implements Exception {
  const EmailNotConfiguredException();
}

class EmailSendException implements Exception {
  const EmailSendException(this.details);

  final String details;

  @override
  String toString() => details;
}

Future<void> sendGreetingEmail({
  required Greeting greeting,
  required String cardUrl,
}) async {
  if (!EmailJsConfig.isConfigured) {
    throw const EmailNotConfiguredException();
  }

  final response = await http.post(
    Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
    headers: const {'Content-Type': 'application/json'},
    body: jsonEncode({
      'service_id': EmailJsConfig.serviceId,
      'template_id': EmailJsConfig.templateId,
      'user_id': EmailJsConfig.publicKey,
      'template_params': {
        'recipient_email': greeting.recipientEmail,
        'sender_email': greeting.senderEmail,
        'message': greeting.message,
        'card_url': cardUrl,
      },
    }),
  );

  if (response.statusCode != 200) {
    final body = response.body.trim();
    throw EmailSendException(
      body.isEmpty ? 'Email service returned ${response.statusCode}' : body,
    );
  }
}
