import 'dart:js_interop';

@JS('greetingWallRead')
external JSPromise<JSString> _greetingWallRead(JSString url);

@JS('greetingWallWrite')
external JSPromise<JSAny?> _greetingWallWrite(
  JSString url,
  JSString body,
  JSString token,
);

Future<String> readUrl(String url) async {
  return (await _greetingWallRead(url.toJS).toDart).toDart;
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
