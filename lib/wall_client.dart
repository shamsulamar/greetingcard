class WallResponse {
  const WallResponse({required this.status, required this.body});

  final int status;
  final String body;
}

Future<WallResponse> requestUrl(
  String url, {
  String method = 'GET',
  String body = '',
  String token = '',
}) async {
  throw UnsupportedError('Network notes run on web only');
}
