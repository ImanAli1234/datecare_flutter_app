/// ═══════════════════════════════════════════════════════════════════════════════
/// profile_repository.dart — User Profile Service
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Handles reading and updating the user's profile in the `profiles` table,
/// and password changes via Supabase Auth.
///
/// Methods:
///   - fetchProfile() → Gets the current user's profile
///   - updateDisplayName(name) → Updates the display_name column
///   - updatePassword(newPassword) → Changes password via Supabase Auth
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../../main.dart'; // for the `supabase` global

class ProfileRepository {
  static const String _table = 'profiles';

  /// Fetches the profile for the currently authenticated user.
  /// Returns null if no profile exists (shouldn't happen if sign-up worked).
  Future<ProfileModel?> fetchProfile() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await supabase
          .from(_table)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return ProfileModel.fromJson(response);
    } catch (e) {
      throw 'Failed to load profile: $e';
    }
  }

  /// Updates the display name in the `profiles` table.
  Future<void> updateDisplayName(String displayName) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw 'Not authenticated';

      await supabase.from(_table).update({
        'display_name': displayName.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      throw 'Failed to update profile: $e';
    }
  }

  /// Changes the user's password via Supabase Auth.
  /// Throws a user-friendly error message on failure.
  Future<void> updatePassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('weak password') ||
          e.message.toLowerCase().contains('password should be')) {
        throw 'Password is too weak. Use at least 6 characters.';
      }
      throw e.message;
    } catch (e) {
      throw 'Failed to update password: $e';
    }
  }
}
