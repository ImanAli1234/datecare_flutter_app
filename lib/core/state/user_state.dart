import 'package:flutter/foundation.dart';

/// Global user state for the DateCare application.
///
/// Holds the user's display name and email, and provides methods to update
/// them. Extends [ChangeNotifier] so widgets can rebuild when the user
/// profile changes (e.g., the "Welcome back, [Name]" greeting).
///
/// This state is now backed by Supabase — profile changes are persisted
/// via the ProfileRepository called from the screens. UserState remains
/// the local in-memory representation that drives widget rebuilds.
class UserState extends ChangeNotifier {
  String _displayName;
  String _email;

  /// Maximum allowed characters for the display name.
  static const int maxNameLength = 30;

  UserState({
    String displayName = 'Curator',
    String email = 'curator@estate.com',
  })  : _displayName = displayName,
        _email = email;

  // ── Getters ────────────────────────────────────────────────────────────

  String get displayName => _displayName;
  String get email => _email;

  /// Returns the first character of the display name (for avatar).
  String get initial =>
      _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'C';

  // ── Mutations ──────────────────────────────────────────────────────────

  /// Updates the display name. Enforces the 30-character limit.
  /// Returns `true` on success, `false` if validation fails.
  ///
  /// Note: This only updates the local state. The screen calling this
  /// should also call ProfileRepository.updateDisplayName() to persist.
  bool updateDisplayName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > maxNameLength) return false;
    _displayName = trimmed;
    notifyListeners();
    return true;
  }

  /// Updates the user's email in local state.
  bool updateEmail(String newEmail) {
    final trimmed = newEmail.trim();
    if (trimmed.isEmpty) return false;
    _email = trimmed;
    notifyListeners();
    return true;
  }

  /// Resets the user state to defaults (used on sign-out).
  void reset() {
    _displayName = 'Curator';
    _email = 'curator@estate.com';
    notifyListeners();
  }

  /// Validates password strength without saving.
  /// Returns an error message or `null` if valid.
  static String? validatePasswordStrength(String password) {
    if (password.isEmpty) return null; // Don't show error on empty
    if (password.length < 8) return 'Too weak — use at least 8 characters';
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Add at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Add at least one number';
    }
    return null;
  }
}
