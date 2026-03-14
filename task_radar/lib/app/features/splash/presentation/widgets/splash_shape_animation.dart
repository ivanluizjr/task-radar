import 'dart:math';

import 'package:flutter/material.dart';

class SplashShapeAnimation extends StatefulWidget {
  final Color color;
  final VoidCallback onCompleted;

  const SplashShapeAnimation({
    super.key,
    required this.color,
    required this.onCompleted,
  });

  @override
  State<SplashShapeAnimation> createState() => _SplashShapeAnimationState();
}

class _SplashShapeAnimationState extends State<SplashShapeAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _slideUp;
  late final AnimationController _rotate;
  late final AnimationController _shrink;
  late final AnimationController _circle;
  late final AnimationController _explode;

  late final Animation<double> _slideY;
  late final Animation<double> _growSize;
  late final Animation<double> _rotationAngle;
  late final Animation<double> _shrinkSize;
  late final Animation<double> _shrinkRadius;
  late final Animation<double> _shrinkRotation;
  late final Animation<double> _circleSize;
  late final Animation<double> _circleRadius;
  late final Animation<double> _explodeScale;

  @override
  void initState() {
    super.initState();

    _slideUp = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideY = Tween<double>(
      begin: 300,
      end: 0,
    ).animate(CurvedAnimation(parent: _slideUp, curve: Curves.easeOutCubic));

    _rotate = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _rotationAngle = Tween<double>(
      begin: 0,
      end: pi / 4,
    ).animate(CurvedAnimation(parent: _rotate, curve: Curves.easeInOut));
    _growSize = Tween<double>(
      begin: 60,
      end: 120,
    ).animate(CurvedAnimation(parent: _rotate, curve: Curves.easeInOut));

    _shrink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shrinkSize = Tween<double>(
      begin: 120,
      end: 40,
    ).animate(CurvedAnimation(parent: _shrink, curve: Curves.easeInOut));
    _shrinkRadius = Tween<double>(
      begin: 12,
      end: 8,
    ).animate(CurvedAnimation(parent: _shrink, curve: Curves.easeInOut));
    _shrinkRotation = Tween<double>(
      begin: pi / 4,
      end: 0,
    ).animate(CurvedAnimation(parent: _shrink, curve: Curves.easeInOut));

    _circle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _circleSize = Tween<double>(
      begin: 40,
      end: 20,
    ).animate(CurvedAnimation(parent: _circle, curve: Curves.easeInOut));
    _circleRadius = Tween<double>(
      begin: 8,
      end: 10,
    ).animate(CurvedAnimation(parent: _circle, curve: Curves.easeInOut));

    _explode = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _explodeScale = Tween<double>(
      begin: 1,
      end: 80,
    ).animate(CurvedAnimation(parent: _explode, curve: Curves.easeIn));

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _slideUp.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _rotate.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _shrink.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _circle.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _explode.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) widget.onCompleted();
  }

  @override
  void dispose() {
    _slideUp.dispose();
    _rotate.dispose();
    _shrink.dispose();
    _circle.dispose();
    _explode.dispose();
    super.dispose();
  }

  int get _phase {
    if (!_slideUp.isCompleted) return 0;
    if (!_rotate.isCompleted) return 1;
    if (!_shrink.isCompleted) return 2;
    if (!_circle.isCompleted) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      listenable: Listenable.merge([
        _slideUp,
        _rotate,
        _shrink,
        _circle,
        _explode,
      ]),
      builder: (context, _) {
        final phase = _phase;

        final size = switch (phase) {
          0 => 60.0,
          1 => _growSize.value,
          2 => _shrinkSize.value,
          _ => _circleSize.value,
        };

        final rotation = phase == 0
            ? 0.0
            : phase == 1
            ? _rotationAngle.value
            : phase == 2
            ? _shrinkRotation.value
            : 0.0;

        final radius = phase <= 1
            ? 12.0
            : phase == 2
            ? _shrinkRadius.value
            : _circleRadius.value;

        final scale = phase == 4 ? _explodeScale.value : 1.0;
        final offsetY = phase == 0 ? _slideY.value : 0.0;

        return Center(
          child: Transform.translate(
            offset: Offset(0, offsetY),
            child: Transform.rotate(
              angle: rotation,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(radius),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
