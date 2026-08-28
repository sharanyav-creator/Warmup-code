import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum MascotMode { idle, shuffling }

/// Warm, the app's bowl-of-topics mascot. Blinks occasionally when idle,
/// cycles through a "digging for a topic" animation while shuffling, and
/// gives a happy bounce + exclaim when tapped.
class WarmMascot extends StatefulWidget {
  final MascotMode mode;
  final double width;

  /// Whether tapping Warm triggers its own bounce/exclaim reaction. Set to
  /// false when embedding Warm inside another tappable area (e.g. a card
  /// whose tap already does something else) so taps aren't intercepted.
  final bool interactive;

  const WarmMascot({
    super.key,
    this.mode = MascotMode.idle,
    this.width = 132,
    this.interactive = true,
  });

  @override
  State<WarmMascot> createState() => _WarmMascotState();
}

class _WarmMascotState extends State<WarmMascot> with SingleTickerProviderStateMixin {
  static const _shuffleFrames = [
    'warm_chits.svg',
    'warm_question.svg',
    'warm_chits.svg',
    'warm_exclaim.svg',
  ];
  static const _idleAspect = 112 / 142;
  static const _tallAspect = 127 / 142;

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
      setState(() => _frame = _shuffleFrames[0]);
      _timer = Timer.periodic(const Duration(milliseconds: 420), (_) {
        if (!mounted) return;
        setState(() {
          _shuffleIndex = (_shuffleIndex + 1) % _shuffleFrames.length;
          _frame = _shuffleFrames[_shuffleIndex];
        });
      });
    } else {
      setState(() => _frame = 'warm_idle.svg');
      _scheduleBlink();
    }
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
    final aspect = (_frame == 'warm_exclaim.svg' || _frame == 'warm_question.svg') ? _tallAspect : _idleAspect;

    final animatedIcon = AnimatedBuilder(
      animation: _tapScale,
      builder: (context, child) => Transform.scale(scale: _tapScale.value, child: child),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
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
