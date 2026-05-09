/// ═══════════════════════════════════════════════════════════════════════════════
/// auth_repository.dart — Authentication Service
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Wraps Supabase Auth methods with user-friendly error handling.
/// Used by LoginScreen and RegisterScreen.
///
/// Methods:
///   - signIn(email, password) → Signs in and returns the session
///   - signUp(email, password, displayName) → Creates account + profile row
///   - signOut() → Clears the session
///   - currentUser → Returns the logged-in user (or null)
///
/// On successful sign-up, this also creates a row in the `profiles` table
/// so the user has a display name and email stored alongside their auth record.
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart'; // for the `supabase` global

class AuthRepository {
  /// Sign in with email and password.
  /// Returns the [AuthResponse] on success.
  /// Throws a user-friendly [String] message on failure.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw _mapAuthError(e.message);
    } catch (e) {
      throw 'Connection error. Please check your internet and try again.';
    }
  }

  /// Sign up with email, password, and display name.
  /// Creates the auth user AND a matching `profiles` row.
  /// Throws a user-friendly [String] message on failure.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'display_name': displayName.trim()},
      );


      return response;
    } on AuthException catch (e) {
      throw _mapAuthError(e.message);
    } on PostgrestException catch (e) {
      throw 'Account created but profile setup failed: ${e.message}';
    } catch (e) {
      throw 'Connection error. Please check your internet and try again.';
    }
  }

  /// Sign out the current user. Clears all local session data.
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  /// Returns the currently logged-in user, or null if not authenticated.
  User? get currentUser => supabase.auth.currentUser;

  /// Returns true if a user is currently authenticated.
  bool get isAuthenticated => supabase.auth.currentUser != null;

  /// Maps Supabase auth error messages to user-friendly text.
  String _mapAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid_credentials')) {
      return 'Invalid email or password. Please try again.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please verify your email before signing in.';
    }
    if (lower.contains('user already registered') ||
        lower.contains('already been registered')) {
      return 'An account with this email already exists.';
    }
    if (lower.contains('weak password') ||
        lower.contains('password should be')) {
      return 'Password is too weak. Use at least 6 characters.';
    }
    if (lower.contains('rate limit') || lower.contains('too many requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    // Fallback to the original message
    return message;
  }
}
