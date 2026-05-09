/// ═══════════════════════════════════════════════════════════════════════════════
/// specimen_repository.dart — Palm Specimen CRUD Service
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Handles all database operations for the `specimens` table.
/// Used by HarvestCalendarScreen and SpecimenLogScreen.
///
/// All queries are automatically scoped to the current user via Supabase RLS
/// (Row Level Security), so you never need to manually filter by user_id
/// on SELECT — Supabase handles it.
///
/// Methods:
///   - fetchAll() → List of all specimens for the current user
///   - add(specimen) → Inserts a new specimen and returns it with its new ID
///   - delete(id) → Removes a specimen by ID
/// ═══════════════════════════════════════════════════════════════════════════════

import '../models/specimen_model.dart';
import '../../main.dart'; // for the `supabase` global

class SpecimenRepository {
  static const String _table = 'specimens';

  /// Fetches all specimens for the current authenticated user.
  /// Returns them sorted by creation date (newest first).
  Future<List<SpecimenModel>> fetchAll() async {
    try {
      final response = await supabase
          .from(_table)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => SpecimenModel.fromJson(json))
          .toList();
    } catch (e) {
      throw 'Failed to load specimens: $e';
    }
  }

  /// Inserts a new specimen into the database.
  /// The user_id is set automatically by Supabase RLS using auth.uid().
  /// Returns the newly created specimen with its server-generated ID.
  Future<SpecimenModel> add(SpecimenModel specimen) async {
    try {
      final data = specimen.toJson();
      data['user_id'] = supabase.auth.currentUser!.id;

      final response = await supabase
          .from(_table)
          .insert(data)
          .select()
          .single();

      return SpecimenModel.fromJson(response);
    } catch (e) {
      throw 'Failed to save specimen: $e';
    }
  }

  /// Updates an existing specimen in the database.
  /// Returns the updated specimen.
  Future<SpecimenModel> update(SpecimenModel specimen) async {
    try {
      final response = await supabase
          .from(_table)
          .update(specimen.toJson())
          .eq('id', specimen.id!)
          .select()
          .single();

      return SpecimenModel.fromJson(response);
    } catch (e) {
      throw 'Failed to update specimen: $e';
    }
  }

  /// Deletes a specimen by its ID.
  Future<void> delete(String id) async {
    try {
      await supabase.from(_table).delete().eq('id', id);
    } catch (e) {
      throw 'Failed to delete specimen: $e';
    }
  }
}
