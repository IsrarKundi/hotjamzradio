import 'package:flutter/material.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavToggle extends StatelessWidget {
  final int currentIndex;
  final Function(int) onIndexChanged;

  const BottomNavToggle({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF95062D),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            child: CustomSlidingSegmentedControl<int>(
              initialValue: currentIndex,
              isStretch: true,
              children: {
                0: _buildNavItem(
                  icon: FontAwesomeIcons.house,
                  label: 'Home',
                  index: 0,
                ),
                1: _buildNavItem(
                  icon: FontAwesomeIcons.youtube,
                  label: 'YouTube',
                  index: 1,
                ),
                2: _buildNavItem(
                  icon: FontAwesomeIcons.radio,
                  label: 'LIVE RADIO',
                  index: 2,
                ),
                3: _buildNavItem(
                  icon: FontAwesomeIcons.spotify,
                  label: 'Spotify',
                  index: 3,
                ),
                4: _buildNavItem(
                  icon: FontAwesomeIcons.apple,
                  label: 'Apple Music',
                  index: 4,
                ),
              },
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              thumbDecoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              onValueChanged: (v) {
                onIndexChanged(v);
              },
              innerPadding: const EdgeInsets.all(0),
              height: 60,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = currentIndex == index;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FaIcon(
          icon,
          size: 20,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
