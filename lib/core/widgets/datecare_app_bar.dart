/// ═══════════════════════════════════════════════════════════════════════════════
/// datecare_app_bar.dart — Global App Bar Widget
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// A shared app bar used on the Login and Register screens (legacy screens).
/// It displays the DateCare logo on the left and the "DATECARE" text centered.
///
/// NOTE: The newer screens (Harvest, Disease, Market, Journal, Profile) use
/// their own custom app bar row built inline — they do NOT use this widget.
/// This is only used by the auth screens. You could consolidate them later.
///
/// Implements [PreferredSizeWidget] so it can be passed to `Scaffold(appBar:)`.
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class DatecareAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DatecareAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Stack is used to layer the logo (left-aligned) and title (centered)
      title: Stack(
        alignment: Alignment.center,
        children: [
          // Logo — positioned to the left
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Image.asset(
                'assets/images/Document121.png', // The DateCare logo
                width: 64,
                height: 64,
              ),
            ),
          ),
          // Centered title text
          Text(
            'DATECARE',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              letterSpacing: 2.0, // Wide tracking for luxury feel
            ),
          ),
        ],
      ),
      elevation: 0,
      // Subtle divider line at the bottom of the app bar
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1.0);
}
