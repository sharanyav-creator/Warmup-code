import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum MascotMode { idle, shuffling }

class _MascotStep {
  final String frame;
  final Duration hold;

  const _MascotStep(this.frame, this.hold);
}

// The chits build up out of the bowl gradually, pause on a "thinking"
// beat, spill up again, then land on a triumphant "found it" exclaim.
const _shuffleSequence = [
  _MascotStep('warm_idle.svg', Duration(milliseconds: 450)),
  _MascotStep('warm_chits_peek.svg', Duration(milliseconds: 550)),
  _MascotStep('warm_chits_rise.svg', Duration(milliseconds: 550)),
  _MascotStep('warm_chits_spill.svg', Duration(milliseconds: 600)),
  _MascotStep('warm_question.svg', Duration(milliseconds: 650)),
  _MascotStep('warm_chits_spill.svg', Duration(milliseconds: 450)),
  _MascotStep('warm_exclaim.svg', Duration(milliseconds: 700)),
];

/// Warm, the app's bowl-of-topics mascot. Blinks occasionally when idle,
/// plays a slow "chits rising out of the bowl" sequence while shuffling,
/// and gives a happy bounce + exclaim when tapped.
class WarmMascot extends StatefulWidget {
  final MascotMode mode;
  final double width;

  /// Whether tapping Warm triggers its own bounce/exclaim reaction. Set to
  /// false when embedding Warm inside another tappable area (e.g. a card
  /// whose tap already does something else) so taps aren't intercepted.
  final bool interactive;

  /// Whether Warm blinks/animates on its own while idle. Set to false to
  /// show a single frozen frame (e.g. a small icon inside a busy card).
  final bool animate;

  const WarmMascot({
    super.key,
    this.mode = MascotMode.idle,
    this.width = 132,
    this.interactive = true,
    this.animate = true,
  });

  /// Total time the shuffling sequence takes for one full pass, for callers
  /// that want to time a transition to land right as it completes.
  static Duration get shuffleSequenceDuration =>
      _shuffleSequence.fold(Duration.zero, (sum, step) => sum + step.hold);

  @override
  State<WarmMascot> createState() => _WarmMascotState();
}

class _WarmMascotState extends State<WarmMascot> with SingleTickerProviderStateMixin {
  static const Map<String, double> _aspectRatios = {
    'warm_idle.svg': 112 / 142,
    'warm_blink_a.svg': 112 / 142,
    'warm_blink_b.svg': 112 / 142,
    'warm_chits_peek.svg': 118 / 146,
    'warm_chits_rise.svg': 133 / 146,
    'warm_chits_spill.svg': 157 / 146,
    'warm_question.svg': 134 / 142,
    'warm_exclaim.svg': 127 / 142,
  };

  final Random _random = Random();
  Timer? _timer;
  int _shuffleIndex = 0;
  String _frame = 'warm_idle.svg';

  late final AnimationController _tapController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 340),
  );
  late final Animation<double> _tapScale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.86).chain(CurveTween(curve: Curves.easeOut)), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 0.86, end: 1.1).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
    TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 30),
  ]).animate(_tapController);

  @override
  void initState() {
    super.initState();
    _restartLoop();
  }

  @override
  void didUpdateWidget(covariant WarmMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      _timer?.cancel();
      _shuffleIndex = 0;
      _restartLoop();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tapController.dispose();
    super.dispose();
  }

  void _restartLoop() {
    if (widget.mode == MascotMode.shuffling) {
      _shuffleIndex = 0;
      setState(() => _frame = _shuffleSequence[0].frame);
      _scheduleNextShuffleStep();
    } else {
      setState(() => _frame = 'warm_idle.svg');
      if (widget.animate) _scheduleBlink();
    }
  }

  void _scheduleNextShuffleStep() {
    final step = _shuffleSequence[_shuffleIndex];
    _timer = Timer(step.hold, () {
      if (!mounted) return;
      setState(() {
        _shuffleIndex = (_shuffleIndex + 1) % _shuffleSequence.length;
        _frame = _shuffleSequence[_shuffleIndex].frame;
      });
      _scheduleNextShuffleStep();
    });
  }

  void _scheduleBlink() {
    _timer = Timer(Duration(milliseconds: 2200 + _random.nextInt(2200)), () async {
      if (!mounted || widget.mode != MascotMode.idle) return;
      setState(() => _frame = _random.nextBool() ? 'warm_blink_a.svg' : 'warm_blink_b.svg');
      await Future.delayed(const Duration(milliseconds: 160));
      if (!mounted || widget.mode != MascotMode.idle) return;
      setState(() => _frame = 'warm_idle.svg');
      _scheduleBlink();
    });
  }

  Future<void> _onTap() async {
    _tapController.forward(from: 0);
    if (widget.mode != MascotMode.idle) return;
    _timer?.cancel();
    setState(() => _frame = 'warm_exclaim.svg');
    await Future.delayed(const Duration(milliseconds: 550));
    if (!mounted || widget.mode != MascotMode.idle) return;
    setState(() => _frame = 'warm_idle.svg');
    _scheduleBlink();
  }

  @override
  Widget build(BuildContext context) {
    final aspect = _aspectRatios[_frame] ?? (112 / 142);

    final animatedIcon = AnimatedBuilder(
      animation: _tapScale,
      builder: (context, child) => Transform.scale(scale: _tapScale.value, child: child),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(animation), child: child),
        ),
        child: SvgPicture.asset(
          'assets/mascot/$_frame',
          key: ValueKey(_frame),
          width: widget.width,
          height: widget.width * aspect,
        ),
      ),
    );

    if (!widget.interactive) return animatedIcon;
    return GestureDetector(onTap: _onTap, child: animatedIcon);
  }
}
