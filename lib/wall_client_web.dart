import 'dart:convert';
import 'dart:js_interop';

import 'wall_client.dart' hide requestUrl;

export 'wall_client.dart' show WallResponse;

@JS('greetingWallRequest')
external JSPromise<JSString> _greetingWallRequest(
  JSString url,
  JSString method,
  JSString body,
  JSString token,
);

Future<WallResponse> requestUrl(
  String url, {
  String method = 'GET',
  String body = '',
  String token = '',
}) async {
  final raw =
      (await _greetingWallRequest(
        url.toJS,
        method.toJS,
        body.toJS,
        token.toJS,
      ).toDart).toDart;
  final decoded = jsonDecode(raw);
  if (decoded is! Map) {
    throw StateError('Wall request did not return a status');
  }
  final status = decoded['s'];
  final text = decoded['b']?.toString() ?? '';
  if (status is! num) {
    throw StateError('Wall request did not return a status');
  }
  return WallResponse(status: status.toInt(), body: text);
}
