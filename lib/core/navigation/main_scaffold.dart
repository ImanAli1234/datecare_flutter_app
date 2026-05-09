/// ═══════════════════════════════════════════════════════════════════════════════
/// main_scaffold.dart — The Main App Shell (Bottom Navigation)
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// This is the "home" screen after login. It contains:
///   - A custom luxury bottom navigation bar (pill-shaped active tab)
///   - 4 tabs: Harvest Calendar, Disease Guide, Market Prices, Journal
///
/// HOW TAB SWITCHING WORKS:
///   - [_selectedIndex] tracks which tab is active (0-3)
///   - [_screens] holds all 4 tab screen widgets
///   - Tapping a nav item calls [_onItemTapped] which triggers setState()
///   - The body shows `_screens[_selectedIndex]`
///
/// IMPORTANT: The bottom nav is entirely custom-built (not BottomNavigationBar).
/// It uses animated containers with pill-shaped highlights for the active tab.
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../features/harvest_calendar/screens/harvest_calendar_screen.dart';
import '../../features/disease_guide/screens/disease_guide_screen.dart';
import '../../features/market_prices/screens/market_prices_screen.dart';
import '../../features/farm_notes/screens/farm_notes_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  /// Currently selected tab index (0 = Harvest, 1 = Disease, 2 = Market, 3 = Journal)
  int _selectedIndex = 0;

  /// The 4 main tab screens. Order must match the nav items below.
  final List<Widget> _screens = [
    const HarvestCalendarScreen(),
    const DiseaseGuideScreen(),
    const MarketPricesScreen(),
    const FarmNotesScreen(),
  ];

  /// Called when the user taps a bottom nav item.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Show the selected tab's screen
      bottomNavigationBar: _buildLuxuryBottomNav(),
    );
  }

  /// Builds the custom luxury bottom navigation bar.
  /// Features: rounded top corners, subtle shadow, pill-shaped active indicator.
  Widget _buildLuxuryBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F6), // Slightly off-white nav background
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 40,
            offset: const Offset(0, -8),
          ),
        ],
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
      ),
      padding: const EdgeInsets.only(bottom: 16, top: 12, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildNavItem(0, 'Harvest', Icons.calendar_month),
          _buildNavItem(1, 'Disease', Icons.bug_report),
          _buildNavItem(2, 'Market', Icons.store),
          _buildNavItem(3, 'Journal', Icons.menu_book),
        ],
      ),
    );
  }

  /// Builds a single navigation item.
  /// Active items get a pill-shaped terracotta background with white text/icon.
  /// Inactive items show muted brown icons.
  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque, // Makes the full area tappable
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200), // Smooth transition
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
            : const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7F4333) : Colors.transparent,
          borderRadius: isSelected ? BorderRadius.circular(40) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF7F4333).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF8D6E63),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: isSelected ? Colors.white : const Color(0xFF8D6E63),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
