import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NoInternetScreen extends StatelessWidget {
  final VoidCallback onRefresh;

  const NoInternetScreen({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Using a placeholder icon if the image is not yet available, 
                // but the code supports the image asset as requested.
                Image.asset(
                  'assets/images/internet.png',
                  width: 250,
                  height: 250,
                  errorBuilder: (context, error, stackTrace) {
                    return const FaIcon(
                      FontAwesomeIcons.wifi,
                      size: 100,
                      color: Color(0xFF95062D),
                    );
                  },
                ),
                const SizedBox(height: 30),
                const Text(
                  'No Internet Connection',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Please check your internet connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 150,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: onRefresh,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF95062D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Refresh',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
