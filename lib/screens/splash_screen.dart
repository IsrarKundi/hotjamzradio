import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    try {
      // Wait for initialization before navigating
      // Increased from 3 to 4 seconds to ensure all services are ready
      await Future.delayed(const Duration(seconds: 4));

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (e) {
      debugPrint('❌ SplashScreen navigation error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load app: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFe21718),
        body: Center(
          child: _hasError
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Oops!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _hasError = false;
                        });
                        _initializeAndNavigate();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFe21718),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.radio, size: 160, color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      'HOT JAMZ\nRADIO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 54,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
