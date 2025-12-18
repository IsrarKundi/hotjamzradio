import 'package:flutter/material.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../screens/main_screen.dart'; // Import for SocialPlatform enum

class SocialMediaToggle extends StatelessWidget {
  final SocialPlatform selectedPlatform;
  final Function(SocialPlatform) onPlatformSelected;

  const SocialMediaToggle({
    super.key,
    required this.selectedPlatform,
    required this.onPlatformSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: CustomSlidingSegmentedControl<SocialPlatform>(
        initialValue: selectedPlatform,
        children: {
          SocialPlatform.iheart: _buildIcon(
            context,
            assetInvalid: 'assets/images/iheart.png',
            platform: SocialPlatform.iheart,
          ),
          SocialPlatform.instagram: _buildIcon(
            context,
            iconData: FontAwesomeIcons.instagram,
            platform: SocialPlatform.instagram,
          ),
          SocialPlatform.facebook: _buildIcon(
            context,
            iconData: FontAwesomeIcons.facebook,
            platform: SocialPlatform.facebook,
          ),
          SocialPlatform.twitter: _buildIcon(
            context,
            iconData: FontAwesomeIcons.xTwitter,
            platform: SocialPlatform.twitter,
          ),
        },
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        thumbDecoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        onValueChanged: (v) {
          onPlatformSelected(v);
        },
        // Adjust padding and sizing to match the previous design approx 180 width total
        // 180 / 4 = 45 per item.
        innerPadding: const EdgeInsets.all(2),
        fixedWidth: 40,
      ),
    );
  }

  Widget _buildIcon(
    BuildContext context, {
    String? assetInvalid,
    IconData? iconData,
    required SocialPlatform platform,
  }) {
    final bool isSelected = selectedPlatform == platform;

    if (assetInvalid != null) {
      return Image.asset(assetInvalid, width: 26, height: 26);
    } else {
      return FaIcon(
        iconData,
        size: 18,
        color: isSelected ? Colors.white : Colors.white70,
      );
    }
  }
}
