/// EmailJS credentials for sending greetings.
///
/// Create them at https://dashboard.emailjs.com then paste the values here
/// (or pass --dart-define=EMAILJS_SERVICE_ID=... and the matching keys).
class EmailJsConfig {
  static const serviceId = String.fromEnvironment(
    'EMAILJS_SERVICE_ID',
    defaultValue: 'service_5rruymj',
  );

  static const templateId = String.fromEnvironment(
    'EMAILJS_TEMPLATE_ID',
    defaultValue: 'template_tvek7et',
  );

  static const publicKey = String.fromEnvironment(
    'EMAILJS_PUBLIC_KEY',
    defaultValue: 'ur-01tiaGWOXm33rE',
  );

  static bool get isConfigured =>
      serviceId.isNotEmpty && templateId.isNotEmpty && publicKey.isNotEmpty;
}
