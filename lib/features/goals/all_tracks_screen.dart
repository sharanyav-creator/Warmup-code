import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_tokens.dart';
import '../../data/tracks_catalog.dart';
import '../../data/tracks_repository.dart';
import 'remove_track_popup.dart';

class AllTracksScreen extends StatefulWidget {
  const AllTracksScreen({super.key});

  @override
  State<AllTracksScreen> createState() => _AllTracksScreenState();
}

class _AllTracksScreenState extends State<AllTracksScreen> {
  final _repository = TracksRepository();
  Set<String> _activeIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ids = await _repository.getActiveTrackIds();
    if (!mounted) return;
    setState(() {
      _activeIds = ids.toSet();
      _loading = false;
    });
  }

  Future<void> _add(String id) async {
    await _repository.addTrack(id);
    setState(() => _activeIds = {..._activeIds, id});
  }

  Future<void> _remove(String id, Offset position) async {
    await showRemoveTrackPopup(
      context,
      globalPosition: position,
      onRemove: () async {
        await _repository.removeTrack(id);
        setState(() => _activeIds = {..._activeIds}..remove(id));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingColors.creamBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: SvgPicture.asset('assets/main/tracks_header_icon.svg', width: 24, height: 24),
                  ),
                  const SizedBox(width: 10),
                  Text('All Tracks', style: OnboardingText.headline(color: Colors.black, fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        for (final track in allTracksCatalog)
                          _AllTrackCard(
                            track: track,
                            active: _activeIds.contains(track.id),
                            onAdd: () => _add(track.id),
                            onLongPressStart: _activeIds.contains(track.id)
                                ? (details) => _remove(track.id, details.globalPosition)
                                : null,
                          ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap & Hold on a track to remove it.',
                          textAlign: TextAlign.center,
                          style: OnboardingText.body(color: OnboardingColors.creamSubtext).copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllTrackCard extends StatelessWidget {
  final TrackDef track;
  final bool active;
  final VoidCallback onAdd;
  final GestureLongPressStartCallback? onLongPressStart;

  const _AllTrackCard({
    required this.track,
    required this.active,
    required this.onAdd,
    this.onLongPressStart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: onLongPressStart,
      child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: active ? const Border(left: BorderSide(color: OnboardingColors.burgundy, width: 6)) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.eyebrow,
                  style: OnboardingText.buttonLabel(color: OnboardingColors.eyebrowGray).copyWith(fontSize: 10),
                ),
                const SizedBox(height: 6),
                Text(track.title, style: OnboardingText.headline(color: Colors.black, fontSize: 14)),
                const SizedBox(height: 6),
                Text(
                  track.subtitle,
                  style: OnboardingText.buttonLabel(color: OnboardingColors.orange).copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          if (!active)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onAdd,
              child: SvgPicture.asset('assets/main/add_track_icon.svg', width: 32, height: 32),
            ),
        ],
      ),
      ),
    );
  }
}
