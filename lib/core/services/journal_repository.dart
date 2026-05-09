/// ═══════════════════════════════════════════════════════════════════════════════
/// journal_repository.dart — Farm Journal CRUD Service
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Handles all database operations for the `journal_entries` table.
/// Used by FarmNotesScreen and NewJournalEntryScreen.
///
/// Methods:
///   - fetchAll() → List of all journal entries for the current user
///   - add(entry) → Inserts a new entry and returns it with its new ID
///   - delete(id) → Removes a journal entry by ID
/// ═══════════════════════════════════════════════════════════════════════════════

import '../models/journal_entry_model.dart';
import '../../main.dart'; // for the `supabase` global

class JournalRepository {
  static const String _table = 'journal_entries';

  /// Fetches all journal entries for the current authenticated user.
  /// Returns them sorted by creation date (newest first).
  Future<List<JournalEntryModel>> fetchAll() async {
    try {
      final response = await supabase
          .from(_table)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => JournalEntryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw 'Failed to load journal entries: $e';
    }
  }

  /// Inserts a new journal entry into the database.
  /// Returns the newly created entry with its server-generated ID and timestamp.
  Future<JournalEntryModel> add(JournalEntryModel entry) async {
    try {
      final data = entry.toJson();
      data['user_id'] = supabase.auth.currentUser!.id;

      final response = await supabase
          .from(_table)
          .insert(data)
          .select()
          .single();

      return JournalEntryModel.fromJson(response);
    } catch (e) {
      throw 'Failed to save journal entry: $e';
    }
  }

  /// Updates an existing journal entry.
  /// Returns the updated entry.
  Future<JournalEntryModel> update(JournalEntryModel entry) async {
    try {
      final response = await supabase
          .from(_table)
          .update(entry.toJson())
          .eq('id', entry.id!)
          .select()
          .single();

      return JournalEntryModel.fromJson(response);
    } catch (e) {
      throw 'Failed to update journal entry: $e';
    }
  }

  /// Deletes a journal entry by its ID.
  Future<void> delete(String id) async {
    try {
      await supabase.from(_table).delete().eq('id', id);
    } catch (e) {
      throw 'Failed to delete journal entry: $e';
    }
  }
}
