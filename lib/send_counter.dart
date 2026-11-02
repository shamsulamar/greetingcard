import 'dart:convert';

import 'package:http/http.dart' as http;

const _namespace = 'greetingcard';
const _base = 'https://abacus.jasoncameron.dev';

/// Calendar date in Malaysia time (UTC+8), as `yyyy-mm-dd`.
String malaysiaTodayKey() {
  final now = DateTime.now().toUtc().add(const Duration(hours: 8));
  final y = now.year.toString().padLeft(4, '0');
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String malaysiaTodayLabel() {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final now = DateTime.now().toUtc().add(const Duration(hours: 8));
  return '${now.day} ${months[now.month - 1]} ${now.year}';
}

Uri _counterUri(String action, String day) {
  return Uri.parse('$_base/$action/$_namespace/sent-$day');
}

int _readValue(http.Response response) {
  if (response.statusCode == 404) {
    return 0;
  }
  if (response.statusCode != 200) {
    throw StateError('Counter returned ${response.statusCode}');
  }
  final body = jsonDecode(response.body);
  if (body is Map<String, dynamic>) {
    final value = body['value'];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
  }
  return 0;
}

Future<int> todaysGreetingCount() async {
  final response = await http.get(_counterUri('get', malaysiaTodayKey()));
  return _readValue(response);
}

Future<void> recordGreetingSent() async {
  final response = await http.get(_counterUri('hit', malaysiaTodayKey()));
  _readValue(response);
}
