import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../controllers/radio_player_controller.dart';
import '../widgets/audio_wave_animation.dart';
import 'dart:math' as math;

class RadioPlayerScreen extends StatefulWidget {
  const RadioPlayerScreen({super.key});

  @override
  State<RadioPlayerScreen> createState() => _RadioPlayerScreenState();
}

class _RadioPlayerScreenState extends State<RadioPlayerScreen>
    with TickerProviderStateMixin {
  late RadioPlayerController _controller;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _controller = RadioPlayerController();
    _controller.initialize();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _controller.addListener(() {
      if (_controller.isPlaying) {
        if (!_rotationController.isAnimating) {
          _rotationController.repeat();
        }
      } else {
        _rotationController.stop();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF95062D),
              Color(0xFF5D0419),
              Color(0xFF2D020D),
            ],
          ),
        ),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, child) {
              return Stack(
                children: [
                  Column(
                    children: [
                      // Top Bar
                      Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.keyboard_arrow_left,
                              color: Colors.white70,
                              size: 30,
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: -0.2, end: 0),
                        if (_controller.isPlaying)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                  ),
                                )
                                    .animate(
                                      onPlay: (controller) =>
                                          controller.repeat(),
                                    )
                                    .fadeIn(duration: 500.ms)
                                    .then()
                                    .fadeOut(duration: 500.ms),
                                const SizedBox(width: 6),
                                const Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 200.ms)
                              .slideX(begin: 0.2, end: 0),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Spinning Album Art
                  AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationController.value * 2 * math.pi,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/app_icon2.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(duration: 600.ms, curve: Curves.easeOut),

                  const SizedBox(height: 40),

                  // Station Name
                  const Text(
                    'LIVE365 HIP-HOP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 3,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 200.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 26),

                  // Waveform
                  SizedBox(
                    height: 60,
                    child: _controller.isBuffering
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white70,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : AudioWaveAnimation(
                            isPlaying: _controller.isPlaying,
                            color: _controller.isPlaying
                                ? Colors.white70
                                : Colors.white30,
                            height: 60,
                            barCount: 7,
                          ),
                  ),

                  const Spacer(),

                  // Play/Pause Button
                  GestureDetector(
                    onTap: _controller.playerState == PlayerState.loading
                        ? null
                        : () => _controller.togglePlayPause(),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Icon(
                        _controller.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 40,
                        color: const Color(0xFF0a0506),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 400.ms)
                      .scale(duration: 600.ms, curve: Curves.easeOut),

                  const SizedBox(height: 50),

                  // Volume Control
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: GlassmorphicContainer(
                      width: double.infinity,
                      height: 60,
                      borderRadius: 20,
                      blur: 10,
                      alignment: Alignment.center,
                      border: 1,
                      linearGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.03),
                        ],
                      ),
                      borderGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Icon(
                              _controller.volume == 0
                                  ? Icons.volume_off_rounded
                                  : _controller.volume < 0.5
                                      ? Icons.volume_down_rounded
                                      : Icons.volume_up_rounded,
                              color: Colors.white70,
                              size: 22,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: SliderTheme(
                                data: SliderThemeData(
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor:
                                      Colors.white.withOpacity(0.2),
                                  thumbColor: Colors.white,
                                  overlayColor: Colors.white.withOpacity(0.1),
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6,
                                  ),
                                  trackHeight: 3,
                                ),
                                child: Slider(
                                  value: _controller.volume,
                                  min: 0.0,
                                  max: 1.0,
                                  onChanged: (value) =>
                                      _controller.setVolume(value),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${(_controller.volume * 100).round()}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 600.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 40),

                  // Error Message
                  if (_controller.playerState == PlayerState.error)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        _controller.errorMessage ?? 'Connection failed',
                        style: TextStyle(
                          color: Colors.red.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                // Full-Screen Loading Overlay
                if (_controller.playerState == PlayerState.loading)
                  Container(
                    color: const Color(0xFF2D020D).withOpacity(0.95),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            'Connecting to Live Radio',
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .scale(begin: const Offset(0.8, 0.8)),
                    ),
                  ),
                ],              );
            },
          ),
        ),
      ),
    );
  }
}
