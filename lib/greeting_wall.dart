import 'dart:convert';

import 'greeting.dart';
import 'send_counter.dart';
import 'wall_client.dart' if (dart.library.js_interop) 'wall_client_web.dart';

const _notesFile = 'notes.json';
const _notesApiUrl =
    'https://api.github.com/repos/shamsulamar/greetingcard/contents/notes.json?ref=gh-pages';
const _dispatchUrl =
    'https://api.github.com/repos/shamsulamar/greetingcard/dispatches';
const _inboxUrl = 'https://ntfy.sh/greetingcard-notes-shamsulamar';
const _maxNoteLength = 160;
const _maxNotesPerDay = 80;
const _sampleNotes = {
  'Happy birthday! Wishing you joy.',
  'Thank you for being you.',
  'Hope this day feels light and kind.',
};

const _dispatchToken = String.fromEnvironment('NOTE_DISPATCH_TOKEN');

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

dynamic _decodeNotesDocument(String raw) {
  final decoded = jsonDecode(raw);
  final map = _asMap(decoded);
  if (map != null && map['content'] is String && map['encoding'] == 'base64') {
    final b64 = (map['content'] as String).replaceAll(RegExp(r'\s'), '');
    return jsonDecode(utf8.decode(base64.decode(b64)));
  }
  return decoded;
}

List<PublicNote> _parseNotes(dynamic decoded) {
  final map = _asMap(decoded);
  final raw = map?['notes'];
  if (raw is! List) {
    return [];
  }
  final notes = <PublicNote>[];
  for (final item in raw) {
    final note = _asMap(item);
    if (note == null) {
      continue;
    }
    final text = note['t']?.toString().trim() ?? '';
    final day = note['d']?.toString() ?? malaysiaTodayKey();
    if (text.isEmpty || _sampleNotes.contains(text)) {
      continue;
    }
    notes.add(PublicNote(text: text, day: day));
  }
  return notes;
}

String _siteNotesUrl() {
  final landing = siteLandingUrl();
  final base = landing.endsWith('/') ? landing : '$landing/';
  return '$base$_notesFile';
}

Future<List<PublicNote>> _loadAllNotes() async {
  Object? lastError;
  for (final url in [_notesApiUrl, _siteNotesUrl()]) {
    try {
      final raw = await readUrl(url);
      return _parseNotes(_decodeNotesDocument(raw));
    } catch (error) {
      lastError = error;
    }
  }
  throw StateError('Could not read notes.json: $lastError');
}

Future<List<PublicNote>> todaysPublicNotes() async {
  final day = malaysiaTodayKey();
  final notes = (await _loadAllNotes())
      .where((note) => note.day == day)
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
  final clipped = text.length > _maxNoteLength
      ? '${text.substring(0, _maxNoteLength).trimRight()}…'
      : text;
  final day = malaysiaTodayKey();
  final existing = await todaysPublicNotes();
  if (existing.any((note) => note.text == clipped)) {
    return;
  }

  final int status;
  if (_dispatchToken.isNotEmpty) {
    status = await writeUrl(
      _dispatchUrl,
      jsonEncode({
        'event_type': 'append_note',
        'client_payload': {'t': clipped, 'd': day},
      }),
      token: _dispatchToken,
    );
  } else {
    status = await writeUrl(
      _inboxUrl,
      jsonEncode({'t': clipped, 'd': day}),
    );
  }
  if (status != 204 && (status < 200 || status >= 300)) {
    throw StateError('Could not queue public note ($status)');
  }

  for (var attempt = 0; attempt < 24; attempt++) {
    await Future<void>.delayed(const Duration(seconds: 5));
    final saved = await todaysPublicNotes();
    if (saved.any((note) => note.text == clipped)) {
      return;
    }
  }
  throw StateError('The note was queued but notes.json did not update yet');
}
