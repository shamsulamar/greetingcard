import 'dart:convert';

import 'send_counter.dart';
import 'wall_client.dart' if (dart.library.js_interop) 'wall_client_web.dart';

const _notesContentsUrl =
    'https://api.github.com/repos/shamsulamar/greetingcard/contents/notes.json';
const _maxNoteLength = 160;
const _maxNotesPerDay = 80;
const _writeToken = String.fromEnvironment('NOTE_DISPATCH_TOKEN');

class PublicNote {
  const PublicNote({required this.text, required this.day});

  final String text;
  final String day;
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return null;
}

String _notesGetUrl() {
  return '$_notesContentsUrl?ref=gh-pages&t=${DateTime.now().millisecondsSinceEpoch}';
}

List<Map<String, String>> _noteMaps(dynamic decoded) {
  final map = _asMap(decoded);
  final raw = map?['notes'];
  if (raw is! List) {
    return [];
  }
  final notes = <Map<String, String>>[];
  for (final item in raw) {
    final note = _asMap(item);
    if (note == null) {
      continue;
    }
    final text = note['t']?.toString().trim() ?? '';
    final day = note['d']?.toString() ?? malaysiaTodayKey();
    if (text.isEmpty) {
      continue;
    }
    notes.add({'t': text, 'd': day});
  }
  return notes;
}

dynamic _fileJson(String raw) {
  final decoded = jsonDecode(raw);
  final map = _asMap(decoded);
  if (map != null && map['content'] is String) {
    final b64 = (map['content'] as String).replaceAll(RegExp(r'\s'), '');
    return jsonDecode(utf8.decode(base64.decode(b64)));
  }
  return decoded;
}

Future<({String sha, List<Map<String, String>> notes})> _readNotesFile({
  String token = '',
}) async {
  final response = await requestUrl(_notesGetUrl(), token: token);
  if (response.status < 200 || response.status >= 300) {
    throw StateError('Could not read notes.json (${response.status})');
  }
  final map = _asMap(jsonDecode(response.body));
  if (map == null) {
    throw StateError('notes.json was not a GitHub file');
  }
  return (
    sha: map['sha']?.toString() ?? '',
    notes: _noteMaps(_fileJson(response.body)),
  );
}

Future<List<PublicNote>> todaysPublicNotes() async {
  final day = malaysiaTodayKey();
  final document = await _readNotesFile(token: _writeToken);
  final notes = document.notes
      .where((note) => note['d'] == day)
      .map((note) => PublicNote(text: note['t']!, day: note['d']!))
      .toList();
  if (notes.length > _maxNotesPerDay) {
    return notes.sublist(notes.length - _maxNotesPerDay);
  }
  return notes;
}

Future<void> publishPublicNote(String message) async {
  final text = message.trim();
  if (text.isEmpty) {
    return;
  }
  if (_writeToken.isEmpty) {
    throw StateError('NOTE_DISPATCH_TOKEN is not configured');
  }
  final clipped = text.length > _maxNoteLength
      ? '${text.substring(0, _maxNoteLength).trimRight()}…'
      : text;
  if (RegExp(r'https?://', caseSensitive: false).hasMatch(clipped)) {
    throw StateError('Public notes cannot include links');
  }
  final day = malaysiaTodayKey();

  Object? lastError;
  for (var attempt = 0; attempt < 4; attempt++) {
    try {
      final document = await _readNotesFile(token: _writeToken);
      if (document.notes.any(
        (note) => note['t'] == clipped && note['d'] == day,
      )) {
        return;
      }
      final notes = [...document.notes, {'t': clipped, 'd': day}];
      final sameDay = [
        for (var i = 0; i < notes.length; i++)
          if (notes[i]['d'] == day) i,
      ];
      var kept = notes;
      if (sameDay.length > _maxNotesPerDay) {
        final drop = sameDay
            .sublist(0, sameDay.length - _maxNotesPerDay)
            .toSet();
        kept = [
          for (var i = 0; i < notes.length; i++)
            if (!drop.contains(i)) notes[i],
        ];
      }
      final encoded = base64.encode(
        utf8.encode(
          '${const JsonEncoder.withIndent('  ').convert({'notes': kept})}\n',
        ),
      );
      final saved = await requestUrl(
        _notesContentsUrl,
        method: 'PUT',
        token: _writeToken,
        body: jsonEncode({
          'message': 'Add a public greeting to notes.json.',
          'content': encoded,
          'sha': document.sha,
          'branch': 'gh-pages',
        }),
      );
      if (saved.status == 200 || saved.status == 201) {
        return;
      }
      if (saved.status == 409) {
        lastError = 'notes.json changed, retrying';
        continue;
      }
      throw StateError('Could not save notes.json (${saved.status})');
    } catch (error) {
      lastError = error;
    }
  }
  throw StateError('Could not save notes.json: $lastError');
}
