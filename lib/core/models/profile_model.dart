/// ═══════════════════════════════════════════════════════════════════════════════
/// profile_model.dart — Data Model for User Profiles
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Maps to the `profiles` table in Supabase. This table extends the built-in
/// `auth.users` table with app-specific fields like display_name.
///
/// The `profiles` row is created automatically when a user registers, via
/// a Supabase database trigger or by the AuthRepository.
///
/// Fields:
///   - id: UUID primary key, references auth.users(id)
///   - displayName: User's chosen display name (default: 'Curator')
///   - email: Synced from auth — displayed but not editable here
///   - createdAt: Account creation timestamp
///   - updatedAt: Last profile update timestamp
/// ═══════════════════════════════════════════════════════════════════════════════

class ProfileModel {
  final String id;
  final String displayName;
  final String email;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProfileModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a ProfileModel from a Supabase row (JSON map).
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      displayName: json['display_name'] as String? ?? 'Curator',
      email: json['email'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts to a JSON map for Supabase UPDATE.
  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
