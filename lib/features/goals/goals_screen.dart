import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_tokens.dart';
import '../../data/tracks_catalog.dart';
import '../../data/tracks_repository.dart';
import '../warmup_flow/prep_start_screen.dart';
import '../warmup_flow/warmup_flow_context.dart';
import 'all_tracks_screen.dart';
import 'remove_track_popup.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _repository = TracksRepository();
  final _random = Random();
  List<TrackDef> _yourTracks = [];
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
      _yourTracks = ids.map(trackById).toList();
      _loading = false;
    });
  }

  void _startTrackPractice(TrackDef track) {
    final prompt = track.prompts[_random.nextInt(track.prompts.length)];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PrepStartScreen(
          flowContext: WarmupFlowContext(
            trackLabel: track.trackLabel,
            promptPool: track.prompts,
            promptText: prompt,
          ),
        ),
      ),
    );
  }

  Future<void> _exploreMoreTracks() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AllTracksScreen()),
    );
    _load();
  }

  Future<void> _removeTrack(TrackDef track, Offset position) async {
    await showRemoveTrackPopup(
      context,
      globalPosition: position,
      onRemove: () async {
        await _repository.removeTrack(track.id);
        _load();
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
              child: Text('Your Tracks', style: OnboardingText.headline(color: Colors.black, fontSize: 18)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        for (final track in _yourTracks)
                          _TrackCard(
                            track: track,
                            onPlay: () => _startTrackPractice(track),
                            onLongPressStart: (details) => _removeTrack(track, details.globalPosition),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: OnboardingColors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            onPressed: _exploreMoreTracks,
                            child: Text('Explore more Tracks', style: OnboardingText.buttonLabel(color: Colors.white)),
                          ),
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

class _TrackCard extends StatelessWidget {
  final TrackDef track;
  final VoidCallback onPlay;
  final GestureLongPressStartCallback onLongPressStart;

  const _TrackCard({required this.track, required this.onPlay, required this.onLongPressStart});

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
        border: const Border(left: BorderSide(color: OnboardingColors.burgundy, width: 6)),
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
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onPlay,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: OnboardingColors.burgundy, borderRadius: BorderRadius.circular(10)),
              child: SvgPicture.asset('assets/main/track_play_icon.svg', width: 24, height: 24),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
