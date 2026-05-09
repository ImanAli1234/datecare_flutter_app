/// ═══════════════════════════════════════════════════════════════════════════════
/// main.dart — Application Entry Point
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// This is the root of the DateCare Flutter app. It does four things:
///   1. Loads environment variables (.env) for Supabase credentials.
///   2. Initializes the Supabase client (Auth + Database).
///   3. Creates the global [UserState] and wraps the tree with [UserStateProvider].
///   4. Sets up [MaterialApp] with the luxury theme and named routes.
///
/// HOW THE APP STARTS:
///   - If a Supabase session exists → MainScaffold (4-tab bottom nav)
///   - If no session → Login Screen
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_routes.dart';
import 'core/state/user_state.dart';
import 'core/state/user_state_provider.dart';

/// Global accessor for the Supabase client — use this anywhere in the app.
/// Example: `supabase.auth.currentUser`, `supabase.from('specimens').select()`
final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file containing SUPABASE_URL and SUPABASE_ANON_KEY
  await dotenv.load(fileName: '.env');

  // Initialize Supabase SDK
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const DateCareApp());
}

/// The root widget. Uses StatefulWidget because it owns the [UserState] instance.
class DateCareApp extends StatefulWidget {
  const DateCareApp({super.key});

  @override
  State<DateCareApp> createState() => _DateCareAppState();
}

class _DateCareAppState extends State<DateCareApp> {
  // This single instance is shared across the entire app via UserStateProvider.
  final _userState = UserState();

  @override
  void dispose() {
    _userState.dispose(); // Clean up the ChangeNotifier
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is already logged in (existing Supabase session)
    final session = supabase.auth.currentSession;
    final initialRoute = session != null ? AppRoutes.mainScaffold : AppRoutes.login;

    return UserStateProvider(
      userState: _userState,
      child: MaterialApp(
        title: 'DateCare Luxury Dashboard',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme, // The "Digital Herbarium" luxury theme
        initialRoute: initialRoute,
        onGenerateRoute: AppRoutes.generateRoute, // Centralized named routing
      ),
    );
  }
}
