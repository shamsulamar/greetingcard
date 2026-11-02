import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../greeting_wall.dart';
import '../send_counter.dart';

const _noteColors = [
  Color(0xFFFFF59D),
  Color(0xFFFFCCBC),
  Color(0xFFC8E6C9),
  Color(0xFFBBDEFB),
  Color(0xFFF8BBD0),
  Color(0xFFFFE0B2),
  Color(0xFFE1BEE7),
  Color(0xFFB2EBF2),
];

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int _count = 0;
  List<PublicNote> _notes = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    if (!kIsWeb) {
      setState(() {
        _count = 0;
        _notes = const [];
        _loading = false;
      });
      return;
    }
    try {
      final notes = await todaysPublicNotes();
      if (!mounted) {
        return;
      }
      setState(() {
        _notes = notes;
        _count = notes.length;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Could not load the wall.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFC4A574),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB08968),
        foregroundColor: Colors.white,
        title: const Text('Greetings today'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _error != null
          ? Center(
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.white),
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Column(
                      children: [
                        Text(
                          malaysiaTodayLabel(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        Text(
                          '$_count',
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontFamily: 'serif',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Greetings sent today',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontFamily: 'serif',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_notes.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No public notes yet.\nSend a greeting to pin one on the wall.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, height: 1.4),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                    sliver: SliverToBoxAdapter(
                      child: Wrap(
                        spacing: 14,
                        runSpacing: 18,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final note in _notes) _StickyNote(note: note),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _StickyNote extends StatelessWidget {
  const _StickyNote({required this.note});

  final PublicNote note;

  @override
  Widget build(BuildContext context) {
    final seed = note.text.hashCode;
    final color = _noteColors[seed.abs() % _noteColors.length];
    final angle = ((seed % 13) - 6) * 0.032;
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 168,
        constraints: const BoxConstraints(minHeight: 140),
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        decoration: BoxDecoration(
          color: color,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 8,
              offset: const Offset(2, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.lerp(color, Colors.black, 0.22),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              note.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 15,
                height: 1.35,
                color: Color(0xFF3E2723),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
