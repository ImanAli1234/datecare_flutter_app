/// ═══════════════════════════════════════════════════════════════════════════════
/// new_journal_entry_screen.dart — Create or Edit a Farm Journal Entry
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// MODES:
///   - Create: Empty fields, button says "COMMIT TO LOG"
///   - Edit: Pre-filled fields, button says "UPDATE ENTRY"
///
/// Pass an existing entry via `existingEntry` parameter to enter edit mode.
/// Returns `true` on success so the feed screen can refresh.
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/journal_repository.dart';
import '../../../core/models/journal_entry_model.dart';

class NewJournalEntryScreen extends StatefulWidget {
  /// If provided, the form opens in edit mode with pre-filled data.
  final JournalEntryModel? existingEntry;

  const NewJournalEntryScreen({super.key, this.existingEntry});

  @override
  State<NewJournalEntryScreen> createState() => _NewJournalEntryScreenState();
}

class _NewJournalEntryScreenState extends State<NewJournalEntryScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _journalRepo = JournalRepository();

  bool _isSaving = false;

  bool get _isEditMode => widget.existingEntry != null;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields if editing
    if (_isEditMode) {
      _titleController.text = widget.existingEntry!.title;
      _bodyController.text = widget.existingEntry!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _handleCommit() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty && body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something before committing.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (_isEditMode) {
        // Update existing entry
        final updated = JournalEntryModel(
          id: widget.existingEntry!.id,
          userId: widget.existingEntry!.userId,
          title: title.isNotEmpty ? title : 'Untitled Entry',
          content: body,
          createdAt: widget.existingEntry!.createdAt,
        );
        await _journalRepo.update(updated);
      } else {
        // Create new entry
        final entry = JournalEntryModel(
          title: title.isNotEmpty ? title : 'Untitled Entry',
          content: body,
        );
        await _journalRepo.add(entry);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              bottom: -20, right: -40,
              child: Icon(Icons.local_florist, size: 200, color: AppColors.outlineVariant.withValues(alpha: 0.08)),
            ),
            Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: AppColors.primary, size: 22),
                      ),
                      Text('DATECARE', style: Theme.of(context).textTheme.headlineSmall?.copyWith(letterSpacing: 3.0, fontSize: 18)),
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primaryContainer,
                        child: Icon(Icons.person, color: AppColors.onPrimary, size: 18),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Section label
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book, color: AppColors.onSurfaceVariant, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        _isEditMode ? 'EDIT JOURNAL ENTRY — THE GROVE' : 'NEW JOURNAL ENTRY — THE GROVE',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 2.0, color: AppColors.onSurfaceVariant, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Content area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title input
                        TextField(
                          controller: _titleController,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppColors.primary.withValues(alpha: 0.6),
                            fontSize: 32,
                          ),
                          decoration: InputDecoration(
                            hintText: 'A New Observation...',
                            hintStyle: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppColors.outlineVariant.withValues(alpha: 0.6),
                              fontSize: 32,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 24),
                        // Body input
                        TextField(
                          controller: _bodyController,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            height: 1.7,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Record your thoughts, the weather, and the subtle shifts in the environment today...',
                            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.outlineVariant.withValues(alpha: 0.5),
                              height: 1.7,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          maxLines: null,
                          minLines: 8,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom action bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      // Gallery button (future: image attachment)
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.image, color: AppColors.onSurfaceVariant, size: 22),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Commit/Update button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _handleCommit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: AppColors.onPrimary,
                            disabledBackgroundColor: AppColors.secondary.withValues(alpha: 0.6),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _isEditMode ? 'UPDATE ENTRY' : 'COMMIT TO LOG',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onPrimary, letterSpacing: 2.0, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(_isEditMode ? Icons.check : Icons.arrow_forward, size: 16, color: AppColors.onPrimary),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
