import 'dart:js_interop';

import 'package:web/web.dart';

@JS('greetingWallWrite')
external JSPromise<JSAny?> _greetingWallWrite(
  JSString url,
  JSString body,
  JSString token,
);

Future<String> readUrl(String url) async {
  final response = await window.fetch(url.toJS).toDart;
  if (response.status < 200 || response.status >= 300) {
    throw StateError('GET ${response.status}');
  }
  return (await response.text().toDart).toDart;
}

Future<int> writeUrl(
  String url,
  String body, {
  String token = '',
}) async {
  final any = await _greetingWallWrite(url.toJS, body.toJS, token.toJS).toDart;
  if (any == null) {
    throw StateError('Wall write did not return a status');
  }
  final value = any.dartify();
  if (value is num) {
    return value.toInt();
  }
  throw StateError('Wall write did not return a status');
}
