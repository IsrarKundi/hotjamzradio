import 'package:flutter/material.dart';
import 'dart:math' as math;

class AudioWaveAnimation extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final double height;
  final int barCount;

  const AudioWaveAnimation({
    super.key,
    required this.isPlaying,
    this.color = Colors.white,
    this.height = 80,
    this.barCount = 5,
  });

  @override
  State<AudioWaveAnimation> createState() => _AudioWaveAnimationState();
}

class _AudioWaveAnimationState extends State<AudioWaveAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final List<double> _randomMultipliers = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _controllers = List.generate(
      widget.barCount,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + (index * 80)),
      ),
    );

    // Generate random multipliers for more organic movement
    _randomMultipliers.clear();
    for (var i = 0; i < widget.barCount; i++) {
      _randomMultipliers.add(0.3 + (math.Random().nextDouble() * 0.7));
    }

    _animations = _controllers.asMap().entries.map((entry) {
      final controller = entry.value;
      final multiplier = _randomMultipliers[entry.key];
      return Tween<double>(begin: 0.15, end: multiplier).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOutCubic,
        ),
      );
    }).toList();

    if (widget.isPlaying) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    for (var i = 0; i < _controllers.length; i++) {
      // Stagger the start times for wave effect
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  void _stopAnimations() {
    for (var controller in _controllers) {
      controller.stop();
      controller.animateTo(0.0, duration: const Duration(milliseconds: 300));
    }
  }

  @override
  void didUpdateWidget(AudioWaveAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(widget.barCount, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              final animValue = _animations[index].value;
              final barHeight = widget.isPlaying
                  ? widget.height * animValue
                  : widget.height * 0.15;
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: barHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: widget.isPlaying
                        ? [
                            widget.color.withOpacity(0.6),
                            widget.color,
                            widget.color.withOpacity(0.8),
                          ]
                        : [
                            widget.color.withOpacity(0.3),
                            widget.color.withOpacity(0.3),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// Enhanced Circular Wave with particle effects
class CircularWaveAnimation extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final double size;

  const CircularWaveAnimation({
    super.key,
    required this.isPlaying,
    this.color = Colors.white,
    this.size = 200,
  });

  @override
  State<CircularWaveAnimation> createState() => _CircularWaveAnimationState();
}

class _CircularWaveAnimationState extends State<CircularWaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(CircularWaveAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: CircularWavePainter(
              animationValue: _controller.value,
              color: widget.color,
              isPlaying: widget.isPlaying,
            ),
          );
        },
      ),
    );
  }
}

class CircularWavePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final bool isPlaying;

  CircularWavePainter({
    required this.animationValue,
    required this.color,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    if (!isPlaying) {
      // Draw subtle static circles when not playing
      for (var i = 0; i < 2; i++) {
        final paint = Paint()
          ..color = color.withOpacity(0.15 - (i * 0.05))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(center, maxRadius * (0.6 + (i * 0.15)), paint);
      }
      return;
    }

    // Draw multiple expanding circles with varying properties
    for (var i = 0; i < 4; i++) {
      final progress = (animationValue + (i * 0.25)) % 1.0;
      final radius = maxRadius * progress * 0.9;
      
      // Calculate opacity with smooth fade
      final opacity = (1.0 - progress) * 0.6;
      
      // Calculate stroke width that decreases as wave expands
      final strokeWidth = 3.0 - (progress * 2.0);

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth.clamp(0.5, 3.0);

      canvas.drawCircle(center, radius, paint);
      
      // Add inner glow effect
      if (progress < 0.5) {
        final glowPaint = Paint()
          ..color = color.withOpacity((0.5 - progress) * 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth * 2
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(center, radius, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CircularWavePainter oldDelegate) {
    return animationValue != oldDelegate.animationValue ||
        isPlaying != oldDelegate.isPlaying;
  }
}
 