import 'dart:math';

import 'package:flutter/material.dart';

class SpinnerAnimation extends StatefulWidget {
  final double size;
  final Color? color;
  final int dotCount;

  const SpinnerAnimation({
    super.key,
    this.size = 40,
    this.color,
    this.dotCount = 8,
  });

  @override
  State<SpinnerAnimation> createState() => _SpinnerAnimationState();
}

class _SpinnerAnimationState extends State<SpinnerAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _rotation;
  late final AnimationController _expand;

  late final Animation<double> _rotationAngle;
  late final Animation<double> _expandValue;

  @override
  void initState() {
    super.initState();

    _rotation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _rotationAngle = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _rotation, curve: Curves.linear));

    _expand = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _expandValue = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_expand);

    _rotation.repeat();
    _expand.repeat();
  }

  @override
  void dispose() {
    _rotation.dispose();
    _expand.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    final dotSize = widget.size * 0.15;
    final maxRadius = widget.size / 2 - dotSize / 2;

    return _SpinnerBuilder(
      listenable: Listenable.merge([_rotation, _expand]),
      builder: (context) {
        final radius = maxRadius * _expandValue.value;

        return Transform.rotate(
          angle: _rotationAngle.value,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: List.generate(widget.dotCount, (i) {
                final angle = (2 * pi / widget.dotCount) * i;
                final dx = radius * cos(angle);
                final dy = radius * sin(angle);

                return Transform.translate(
                  offset: Offset(dx, dy),
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

class _SpinnerBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context) builder;

  const _SpinnerBuilder({required super.listenable, required this.builder});

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }
}
