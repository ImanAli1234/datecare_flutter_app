/// ═══════════════════════════════════════════════════════════════════════════════
/// farm_notes_screen.dart — Tab 4: Farm Journal
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Displays a feed of farm journal entries fetched from Supabase.
/// 
/// FEATURES:
///   - Pull-to-refresh to reload entries
///   - FAB to create new entries
///   - Tap an entry to edit it
///   - Swipe left on an entry to delete it
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/journal_repository.dart';
import '../../../core/models/journal_entry_model.dart';
import 'new_journal_entry_screen.dart';

class FarmNotesScreen extends StatefulWidget {
  const FarmNotesScreen({super.key});

  @override
  State<FarmNotesScreen> createState() => _FarmNotesScreenState();
}

class _FarmNotesScreenState extends State<FarmNotesScreen> {
  final _journalRepo = JournalRepository();
  List<JournalEntryModel> _entries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final entries = await _journalRepo.fetchAll();
      if (mounted) setState(() { _entries = entries; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  // ── Create new entry ──────────────────────────────────────────────────

  Future<void> _openNewEntry() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewJournalEntryScreen()),
    );
    if (result == true && mounted) _loadEntries();
  }

  // ── Edit existing entry ───────────────────────────────────────────────

  Future<void> _editEntry(JournalEntryModel entry, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewJournalEntryScreen(existingEntry: entry),
      ),
    );
    if (result == true && mounted) _loadEntries();
  }

  // ── Delete entry ──────────────────────────────────────────────────────

  Future<bool> _confirmDelete(JournalEntryModel entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Entry?', style: TextStyle(color: AppColors.primary)),
        content: Text(
          'Remove "${entry.title}" from your journal? This cannot be undone.',
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCEL', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return confirm == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              bottom: 60, left: -40,
              child: Icon(Icons.menu_book, size: 180, color: AppColors.outlineVariant.withValues(alpha: 0.08)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.eco, color: AppColors.primary, size: 20),
                      Text('DATECARE', style: Theme.of(context).textTheme.headlineSmall?.copyWith(letterSpacing: 3.0, fontSize: 18)),
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primaryContainer,
                        child: Icon(Icons.person, color: AppColors.onPrimary, size: 18),
                      ),
                    ],
                  ),
                ),
                // Section label
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book, color: AppColors.onSurfaceVariant, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'FARM JOURNAL — THE GROVE',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 2.0, color: AppColors.onSurfaceVariant, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Content area
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState()
                      : _error != null
                          ? _buildErrorState()
                          : _entries.isEmpty
                              ? _buildEmptyState()
                              : RefreshIndicator(
                                  onRefresh: _loadEntries,
                                  color: AppColors.primary,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    itemCount: _entries.length,
                                    itemBuilder: (context, index) {
                                      final entry = _entries[index];
                                      return _buildJournalCard(context, entry, index);
                                    },
                                  ),
                                ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton.extended(
          onPressed: _openNewEntry,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
          icon: const Icon(Icons.edit, size: 18),
          label: Text('NEW ENTRY', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onPrimary, letterSpacing: 2.0, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary.withValues(alpha: 0.6)))),
        const SizedBox(height: 16),
        Text('Loading journal...', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
      ]),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.cloud_off, size: 48, color: AppColors.outlineVariant.withValues(alpha: 0.4)),
        const SizedBox(height: 16),
        Text('Could not load journal entries.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 8),
        TextButton(onPressed: _loadEntries, child: Text('Tap to retry', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.menu_book, size: 64, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        const SizedBox(height: 16),
        Text('Your journal is empty.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text('Tap "NEW ENTRY" to record your first observation.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.outlineVariant)),
      ]),
    );
  }

  /// Each journal card is swipeable to delete and tappable to edit.
  Widget _buildJournalCard(BuildContext context, JournalEntryModel entry, int index) {
    return Dismissible(
      key: Key(entry.id ?? index.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.only(right: 28),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
      ),
      confirmDismiss: (_) => _confirmDelete(entry),
      onDismissed: (_) async {
        final removed = _entries.removeAt(index);
        setState(() {});
        try {
          await _journalRepo.delete(removed.id!);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry removed.')));
        } catch (e) {
          setState(() => _entries.insert(index, removed));
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
        }
      },
      child: GestureDetector(
        onTap: () => _editEntry(entry, index),
        child: Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
            boxShadow: [BoxShadow(color: AppColors.onSurface.withValues(alpha: 0.06), blurRadius: 32, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.formattedDate, style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 2.5, color: AppColors.primaryContainer, fontSize: 10, fontWeight: FontWeight.bold)),
                  Icon(Icons.edit_outlined, color: AppColors.outlineVariant.withValues(alpha: 0.4), size: 16),
                ],
              ),
              const SizedBox(height: 16),
              Text(entry.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
              const SizedBox(height: 16),
              Text(
                entry.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant, height: 1.6),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text('Tap to edit · Swipe to delete', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.outlineVariant.withValues(alpha: 0.5), fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}
