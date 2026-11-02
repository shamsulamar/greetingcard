import 'dart:convert';

class Greeting {
  const Greeting({
    required this.message,
    required this.senderEmail,
    required this.recipientEmail,
  });

  final String message;
  final String senderEmail;
  final String recipientEmail;

  String toPayload() {
    final json = jsonEncode({
      'm': message,
      's': senderEmail,
      'r': recipientEmail,
    });
    return base64Url.encode(utf8.encode(json)).replaceAll('=', '');
  }

  static Greeting? fromPayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      return null;
    }
    try {
      var normalized = payload;
      final pad = normalized.length % 4;
      if (pad != 0) {
        normalized += '=' * (4 - pad);
      }
      final json = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(json) as Map<String, dynamic>;
      return Greeting(
        message: map['m'] as String? ?? '',
        senderEmail: map['s'] as String? ?? '',
        recipientEmail: map['r'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }
}

String siteLandingUrl() {
  final uri = Uri.base;
  final origin =
      '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
  var path = uri.path;
  final hashIndex = path.indexOf('#');
  if (hashIndex >= 0) {
    path = path.substring(0, hashIndex);
  }
  if (path.isEmpty) {
    path = '/';
  }
  return '$origin$path';
}

String cardShareUrl(String payload) {
  final landing = siteLandingUrl();
  final base = landing.endsWith('/') ? landing : '$landing/';
  return '$base#/card?d=$payload';
}
