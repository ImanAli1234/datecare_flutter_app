/// ═══════════════════════════════════════════════════════════════════════════════
/// app_routes.dart — Centralized Named Route Definitions
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// All route names are defined as static constants here so they can be
/// referenced type-safely throughout the app (e.g., `AppRoutes.login`).
///
/// The [generateRoute] method acts as a switch-case router. When you add
/// a new screen, just:
///   1. Add a new `static const String` for the route name.
///   2. Add a new `case` in [generateRoute] that returns a MaterialPageRoute.
///
/// NOTE: The bottom-nav tabs (Harvest, Disease, Market, Journal) are NOT
///       individual routes — they're embedded inside [MainScaffold] as tabs.
///       Only screens that need their own "push" navigation get a route here.
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

// Import screens that have named routes
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../navigation/main_scaffold.dart';
import '../../features/farm_notes/screens/new_journal_entry_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

class AppRoutes {
  // ── Route name constants ─────────────────────────────────────────────────
  static const String login = '/login';
  static const String register = '/register';
  static const String mainScaffold = '/main-scaffold'; // The 4-tab home
  static const String newJournalEntry = '/new-journal-entry';
  static const String profile = '/profile';

  /// Maps route names → screen widgets.
  /// Called automatically by MaterialApp when Navigator.pushNamed() is used.
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case mainScaffold:
        return MaterialPageRoute(builder: (_) => const MainScaffold());
      case newJournalEntry:
        return MaterialPageRoute(builder: (_) => const NewJournalEntryScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        // Fallback for unknown routes — helpful during development
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
