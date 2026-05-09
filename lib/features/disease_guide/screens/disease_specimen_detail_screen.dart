import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../services/disease_parser.dart';
import '../../../core/services/specimen_repository.dart';
import '../../../core/models/specimen_model.dart';

class DiseaseSpecimenDetailScreen extends StatefulWidget {
  final DiseaseSpecimen specimen;

  const DiseaseSpecimenDetailScreen({super.key, required this.specimen});

  @override
  State<DiseaseSpecimenDetailScreen> createState() => _DiseaseSpecimenDetailScreenState();
}

class _DiseaseSpecimenDetailScreenState extends State<DiseaseSpecimenDetailScreen> {
  final _specimenRepo = SpecimenRepository();
  bool _isAssigning = false;

  Future<void> _showAssignmentModal() async {
    setState(() => _isAssigning = true);
    
    try {
      final specimens = await _specimenRepo.fetchAll();
      if (!mounted) return;
      setState(() => _isAssigning = false);

      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.background,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (ctx) {
          return SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Assign Treatment',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a palm to start the ${widget.specimen.treatmentDurationDays}-day protocol for ${widget.specimen.name}.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (specimens.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          "No specimens logged yet.",
                          style: TextStyle(color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: specimens.length,
                        itemBuilder: (context, index) {
                          final palm = specimens[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primaryContainer,
                              child: Icon(Icons.grass, color: AppColors.onPrimary),
                            ),
                            title: Text(palm.variety, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                            subtitle: Text(palm.plotLocation, style: TextStyle(color: AppColors.onSurfaceVariant)),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.surfaceVariant,
                                foregroundColor: AppColors.primary,
                                elevation: 0,
                              ),
                              child: const Text('ASSIGN'),
                              onPressed: () async {
                                Navigator.pop(ctx);
                                await _assignDiseaseToSpecimen(palm);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isAssigning = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading specimens: $e')));
      }
    }
  }

  Future<void> _assignDiseaseToSpecimen(SpecimenModel palm) async {
    final updated = SpecimenModel(
      id: palm.id,
      userId: palm.userId,
      variety: palm.variety,
      originDate: palm.originDate,
      plotLocation: palm.plotLocation,
      vitalityNote: palm.vitalityNote,
      createdAt: palm.createdAt,
      activeDisease: widget.specimen.name,
      treatmentStartDate: DateTime.now(),
    );

    try {
      await _specimenRepo.update(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.specimen.name} treatment assigned to ${palm.variety}!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error assigning treatment: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── HERO HEADER ──
          SliverAppBar(
            expandedHeight: 320.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            iconTheme: const IconThemeData(color: AppColors.primary),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 48, bottom: 16),
              title: Text(
                widget.specimen.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      shadows: [Shadow(color: AppColors.background, blurRadius: 10)],
                    ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    right: -60,
                    top: 20,
                    child: Icon(
                      Icons.local_florist,
                      size: 280,
                      color: AppColors.outlineVariant.withValues(alpha: 0.1),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primaryContainer.withValues(alpha: 0.1),
                          AppColors.background,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24, bottom: 60,
                    child: Text(
                      widget.specimen.scientificName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // ── CONTENT ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // SECTION I: IDENTITY
                  Text(
                    'What is it?',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.onSurface.withValues(alpha: 0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.specimen.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface,
                        height: 1.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // SECTION II: DIAGNOSIS
                  Text(
                    'Why did it occur?',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...widget.specimen.causes.map((cause) => _buildCauseCard(context, cause)),
                  const SizedBox(height: 40),

                  // SECTION III: REMEDY
                  Text(
                    'Restoration Protocol',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.specimen.treatmentDurationDays} Day Treatment Plan',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.5,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildProtocolTimeline(context),
                  const SizedBox(height: 120), // padding for floating button
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isAssigning ? null : _showAssignmentModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
            ),
            child: _isAssigning 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.onPrimary, strokeWidth: 2))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.vaccines, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'ASSIGN TREATMENT TO PLANT',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildCauseCard(BuildContext context, DiseaseCase cause) {
    IconData icon = Icons.warning_amber;
    final titleLower = cause.title.toLowerCase();
    if (titleLower.contains('humidity') || titleLower.contains('moisture')) icon = Icons.water_drop;
    else if (titleLower.contains('pruning')) icon = Icons.content_cut;
    else if (titleLower.contains('wound') || titleLower.contains('tissue')) icon = Icons.healing;
    else if (titleLower.contains('soil') || titleLower.contains('salinity')) icon = Icons.terrain;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryContainer, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cause.title.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 1.0,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cause.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolTimeline(BuildContext context) {
    return Column(
      children: List.generate(widget.specimen.protocol.length, (i) {
        final step = widget.specimen.protocol[i];
        final isLast = i == widget.specimen.protocol.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        step.number,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 64,
                      color: AppColors.primaryContainer.withValues(alpha: 0.4),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        letterSpacing: 1.0,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
