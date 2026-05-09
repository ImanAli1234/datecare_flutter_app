/// ═══════════════════════════════════════════════════════════════════════════════
/// harvest_calendar_screen.dart — Tab 1: Harvest Calendar (Home Page)
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// The default landing tab after login. Displays a list of date palm "specimens"
/// that the user has logged, along with their growth stage progress and estimated
/// harvest date.
///
/// FEATURES:
///   - Fetches specimens from Supabase on first load
///   - Pull-to-refresh to reload data
///   - FAB opens SpecimenLogScreen to add new specimens
///   - Tap a specimen card to view details
///   - Long-press a specimen card for edit/delete options
///   - Swipe left on a specimen card to delete it
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/state/user_state_provider.dart';
import '../../../core/services/specimen_repository.dart';
import '../../../core/models/specimen_model.dart';
import 'specimen_log_screen.dart';
import 'specimen_detail_screen.dart';

class HarvestCalendarScreen extends StatefulWidget {
  const HarvestCalendarScreen({super.key});

  @override
  State<HarvestCalendarScreen> createState() => _HarvestCalendarScreenState();
}

class _HarvestCalendarScreenState extends State<HarvestCalendarScreen> {
  final _specimenRepo = SpecimenRepository();
  List<SpecimenModel> _specimens = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSpecimens();
  }

  Future<void> _loadSpecimens() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final specimens = await _specimenRepo.fetchAll();
      if (mounted) setState(() { _specimens = specimens; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  int _getCurrentStageIndex(DateTime originDate) {
    final daysSinceOrigin = DateTime.now().difference(originDate).inDays;
    const stageDays = [0, 35, 105, 140, 161];
    for (int i = stageDays.length - 1; i >= 0; i--) {
      if (daysSinceOrigin >= stageDays[i]) return i;
    }
    return 0;
  }

  String _getStageName(int index) {
    const names = ['HABABOUK', 'KIMRI', 'KHALAL', 'RUTAB', 'TAMR'];
    return names[index.clamp(0, names.length - 1)];
  }

  double _getProgress(int stageIndex) => ((stageIndex + 1) / 5).clamp(0.0, 1.0);

  int _getDaysToHarvest(DateTime originDate) {
    final harvestDate = originDate.add(const Duration(days: 161));
    final remaining = harvestDate.difference(DateTime.now()).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  // ── Add new specimen ──────────────────────────────────────────────────

  Future<void> _openSpecimenLog() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (_) => const SpecimenLogScreen()),
    );
    if (result != null && mounted) {
      final specimen = SpecimenModel.fromLegacyMap(result);
      setState(() => _isLoading = true);
      try {
        final saved = await _specimenRepo.add(specimen);
        setState(() { _specimens.insert(0, saved); _isLoading = false; });
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save specimen: $e')),
          );
        }
      }
    }
  }

  // ── Edit existing specimen ────────────────────────────────────────────

  Future<void> _editSpecimen(SpecimenModel specimen, int index) async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => SpecimenLogScreen(existingSpecimen: specimen),
      ),
    );
    if (result != null && mounted) {
      final updated = SpecimenModel(
        id: specimen.id,
        userId: specimen.userId,
        variety: result['variety'] ?? specimen.variety,
        originDate: DateTime.tryParse(result['originDate'] ?? '') ?? specimen.originDate,
        plotLocation: result['plot'] ?? specimen.plotLocation,
        vitalityNote: result['vitality'] ?? specimen.vitalityNote,
        createdAt: specimen.createdAt,
      );
      try {
        final saved = await _specimenRepo.update(updated);
        setState(() => _specimens[index] = saved);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Specimen updated.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update: $e')),
          );
        }
      }
    }
  }

  // ── Delete specimen ───────────────────────────────────────────────────

  Future<void> _deleteSpecimen(SpecimenModel specimen, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remove Specimen?', style: TextStyle(color: AppColors.primary)),
        content: Text(
          'Delete "${specimen.variety}" from your collection? This cannot be undone.',
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
    if (confirm == true && mounted) {
      try {
        await _specimenRepo.delete(specimen.id!);
        setState(() => _specimens.removeAt(index));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Specimen removed.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }

  void _openSpecimenDetail(SpecimenModel specimen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpecimenDetailScreen(specimen: specimen.toLegacyMap()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -60, right: -60,
              child: Icon(Icons.eco, size: 240, color: AppColors.outlineVariant.withValues(alpha: 0.12)),
            ),
            Positioned(
              bottom: 40, left: -40,
              child: Icon(Icons.grass, size: 180, color: AppColors.outlineVariant.withValues(alpha: 0.08)),
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
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primaryContainer,
                          child: Icon(Icons.person, color: AppColors.onPrimary, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Welcome greeting
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Builder(builder: (context) {
                    final userName = UserStateProvider.of(context).displayName;
                    return Text(
                      'Welcome back, $userName',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                // Content area
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState()
                      : _error != null
                          ? _buildErrorState()
                          : _specimens.isEmpty
                              ? _buildEmptyState()
                              : RefreshIndicator(
                                  onRefresh: _loadSpecimens,
                                  color: AppColors.primary,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    itemCount: _specimens.length,
                                    itemBuilder: (context, index) {
                                      return _buildSpecimenCard(context, _specimens[index], index);
                                    },
                                  ),
                                ),
                ),
              ],
            ),
          ],
        ),
      ),
      // Glassmorphic FAB
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _openSpecimenLog,
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(padding: EdgeInsets.all(18), child: Icon(Icons.add, color: AppColors.onPrimary, size: 28)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary.withValues(alpha: 0.6)))),
        const SizedBox(height: 16),
        Text('Loading specimens...', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
      ]),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.cloud_off, size: 48, color: AppColors.outlineVariant.withValues(alpha: 0.4)),
        const SizedBox(height: 16),
        Text('Could not load specimens.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 8),
        TextButton(onPressed: _loadSpecimens, child: Text('Tap to retry', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.eco, size: 64, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        const SizedBox(height: 16),
        Text('No specimens logged yet.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text('Tap + to log your first palm.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.outlineVariant)),
      ]),
    );
  }

  Widget _buildSpecimenCard(BuildContext context, SpecimenModel specimen, int index) {
    final variety = specimen.variety;
    final originDate = specimen.originDate;
    final plot = specimen.plotLocation;
    final stageIdx = _getCurrentStageIndex(originDate);
    final stageName = _getStageName(stageIdx);
    final progress = _getProgress(stageIdx);
    final daysLeft = _getDaysToHarvest(originDate);

    return Dismissible(
      key: Key(specimen.id ?? index.toString()),
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
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.background,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Remove Specimen?', style: TextStyle(color: AppColors.primary)),
            content: Text('Delete "$variety" from your collection?', style: TextStyle(color: AppColors.onSurfaceVariant)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('CANCEL', style: TextStyle(color: AppColors.onSurfaceVariant))),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('DELETE', style: TextStyle(color: Colors.red))),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        final removed = _specimens.removeAt(index);
        setState(() {});
        try {
          await _specimenRepo.delete(removed.id!);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Specimen removed.')));
        } catch (e) {
          // Restore on failure
          setState(() => _specimens.insert(index, removed));
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
        }
      },
      child: GestureDetector(
        onTap: () => _openSpecimenDetail(specimen),
        onLongPress: () => _showSpecimenOptions(specimen, index),
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
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(stageName, style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 2.5, color: AppColors.primaryContainer, fontSize: 10, fontWeight: FontWeight.bold)),
                Icon(Icons.chevron_right, color: AppColors.outlineVariant.withValues(alpha: 0.5), size: 20),
              ]),
              const SizedBox(height: 12),
              Text(variety, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 36, letterSpacing: 1.5, color: AppColors.primary)),
              if (plot.isNotEmpty && plot != 'Unspecified') ...[
                const SizedBox(height: 6),
                Text(plot, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
              ],
              const SizedBox(height: 24),
              // Progress Bar
              Container(
                height: 6, width: double.infinity,
                decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(3)),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft, widthFactor: progress,
                  child: Container(decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(3))),
                ),
              ),
              const SizedBox(height: 20),
              RichText(text: TextSpan(
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
                children: [
                  const TextSpan(text: 'Est. Harvest: '),
                  TextSpan(text: daysLeft == 0 ? 'Ready' : '$daysLeft Days', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              )),
              // Hint text
              const SizedBox(height: 8),
              Text('Long-press for options', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.outlineVariant.withValues(alpha: 0.5), fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows edit/delete options on long press.
  void _showSpecimenOptions(SpecimenModel specimen, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outlineVariant.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(specimen.variety, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.primaryContainer),
              title: const Text('Edit Specimen'),
              onTap: () { Navigator.pop(ctx); _editSpecimen(specimen, index); },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Specimen', style: TextStyle(color: Colors.red)),
              onTap: () { Navigator.pop(ctx); _deleteSpecimen(specimen, index); },
            ),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }
}
