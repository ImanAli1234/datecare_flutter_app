/// ═══════════════════════════════════════════════════════════════════════════════
/// specimen_detail_screen.dart — Individual Palm Detail View
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Opened when the user taps a specimen card on the Harvest Calendar.
/// Shows detailed information about a specific date palm:
///   - Variety name (cinematic display text)
///   - Current growth stage with visual timeline
///   - Cultivar profile (origin story, characteristics)
///   - Curator's advice specific to the current stage
///
/// CULTIVAR DATA: Hardcoded profiles for 5 varieties (Medjool, Barhi,
/// Deglet Noor, Ajwa, Zahidi). To add a new variety, add an entry to
/// [_cultivarProfiles] with a 'profile' and 'advice_[stage]' keys.
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../disease_guide/services/disease_parser.dart';

class SpecimenDetailScreen extends StatelessWidget {
  final Map<String, String> specimen;

  const SpecimenDetailScreen({super.key, required this.specimen});

  // Date palm growth stages with typical durations in days from pollination
  static const List<Map<String, dynamic>> _stages = [
    {'name': 'HABABOUK', 'desc': 'Fruit Setting', 'daysFromOrigin': 0, 'duration': 35},
    {'name': 'KIMRI', 'desc': 'Green & Growing', 'daysFromOrigin': 35, 'duration': 70},
    {'name': 'KHALAL', 'desc': 'Full Color', 'daysFromOrigin': 105, 'duration': 35},
    {'name': 'RUTAB', 'desc': 'Softening', 'daysFromOrigin': 140, 'duration': 21},
    {'name': 'TAMR', 'desc': 'Full Ripeness', 'daysFromOrigin': 161, 'duration': 0},
  ];

  static const Map<String, Map<String, String>> _cultivarProfiles = {
    'MEDJOOL': {
      'profile': 'The Medjool, often called the "King of Dates," originated in the Tafilalet region of Morocco. Prized for its large size, deep amber color, and caramel-like sweetness, it remains one of the most sought-after varieties worldwide. Its flesh is thick, soft, and fibrous—a true luxury of the desert.',
      'advice_khalal': 'During Khalal, maintain steady irrigation to encourage uniform coloring. Watch for bird damage as the fruit sweetens.',
      'advice_rutab': 'Reduce irrigation by 40% as the fruit enters Rutab. Excess water at this stage causes splitting and fermentation. Harvest at 60-70% Rutab for premium quality.',
      'advice_tamr': 'Allow fruit to dry naturally on the bunch for Tamr stage. Monitor humidity—high moisture invites fungal growth.',
    },
    'BARHI': {
      'profile': 'The Barhi date, native to Basra, Iraq, is unique for being the only commercially consumed date eaten at the Khalal (yellow) stage. Its crisp, apple-like texture when fresh transforms into a butterscotch sweetness as it ripens. A true connoisseur\'s choice.',
      'advice_khalal': 'Barhi is harvested at Khalal for fresh consumption. Ensure palms receive full sunlight for proper yellow coloring. Handle with extreme care—Barhi skin is delicate.',
      'advice_rutab': 'If allowing Rutab, the fruit turns translucent amber with an intensely sweet, syrupy flavor. Reduce irrigation and protect bunches from rain.',
      'advice_tamr': 'Barhi Tamr is uncommon but valued for its caramelized flavor. Dry slowly in shade to preserve texture.',
    },
    'DEGLET NOOR': {
      'profile': 'Known as the "Date of Light" for its translucent, honey-gold flesh, Deglet Noor hails from the oases of Algeria and Tunisia. It is semi-dry with a subtle, nutty sweetness and a firm, elegant texture. The workhorse of the global date industry.',
      'advice_khalal': 'Deglet Noor requires dry heat during Khalal. Excessive humidity will cause the skin to crack. Ensure good airflow between bunches.',
      'advice_rutab': 'This variety progresses slowly through Rutab. Maintain minimal irrigation and let the desert sun do its work.',
      'advice_tamr': 'Harvest at full Tamr for optimal storage. Deglet Noor stores exceptionally well due to its lower moisture content.',
    },
    'AJWA': {
      'profile': 'The Ajwa date, cultivated in the holy city of Medina, Saudi Arabia, holds deep spiritual significance in Islamic tradition. Dark, almost black in color with fine wrinkled skin, it offers a prune-like sweetness balanced by subtle bitterness. Extremely rare and highly valued.',
      'advice_khalal': 'Ajwa demands careful pollination timing for optimal fruit set. During Khalal, guard against dust storms that can damage developing fruit.',
      'advice_rutab': 'The dark color intensifies during Rutab. Reduce watering and protect from extreme afternoon heat which can cause sunburn on fruit.',
      'advice_tamr': 'Harvest at full Tamr. Ajwa\'s medicinal properties are believed to peak at full maturity.',
    },
    'ZAHIDI': {
      'profile': 'The Zahidi is one of the oldest known date varieties, cultivated for thousands of years across Iraq and Iran. Its golden-yellow color and mild, buttery flavor make it versatile for both fresh eating and cooking. A hardy palm that tolerates salt and drought.',
      'advice_khalal': 'Zahidi is drought-tolerant but benefits from consistent deep watering during Khalal. The firm texture makes it resistant to handling damage.',
      'advice_rutab': 'Allow natural progression to Rutab. Zahidi transitions slowly, developing a deeper golden color and syrupy sweetness.',
      'advice_tamr': 'Zahidi Tamr is excellent for date syrup and cooking. Harvest when fully dried on the bunch.',
    },
  };

  int _getCurrentStageIndex(DateTime originDate) {
    final daysSinceOrigin = DateTime.now().difference(originDate).inDays;
    for (int i = _stages.length - 1; i >= 0; i--) {
      if (daysSinceOrigin >= _stages[i]['daysFromOrigin']) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final variety = specimen['variety'] ?? 'MEDJOOL';
    final originDate = DateTime.tryParse(specimen['originDate'] ?? '') ?? DateTime.now();
    final plot = specimen['plot'] ?? 'Unspecified';
    final currentStageIdx = _getCurrentStageIndex(originDate);
    final currentStage = _stages[currentStageIdx];

    final profile = _cultivarProfiles[variety] ?? _cultivarProfiles['MEDJOOL']!;
    final stageKey = currentStage['name'].toString().toLowerCase();
    final advice = profile['advice_$stageKey'] ?? profile['advice_khalal'] ?? 'Continue monitoring your specimen with care.';
    
    final activeDisease = specimen['activeDisease'];
    final treatmentStartDateStr = specimen['treatmentStartDate'];
    final treatmentStartDate = treatmentStartDateStr != null ? DateTime.tryParse(treatmentStartDateStr) : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
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
                  Text(
                    'DATECARE',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      letterSpacing: 3.0,
                      fontSize: 18,
                    ),
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryContainer,
                    child: const Icon(Icons.person, color: AppColors.onPrimary, size: 18),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Variety name — cinematic display
                    Text(
                      variety,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 48,
                        letterSpacing: 2.0,
                        color: AppColors.primary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current Stage: ${currentStage['desc']}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primaryContainer,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Plot: $plot',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // — PROGRESSION TIMELINE —
                    Text(
                      'Progression Timeline',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTimeline(context, originDate, currentStageIdx),
                    const SizedBox(height: 48),

                    if (activeDisease != null && treatmentStartDate != null) ...[
                      // — TREATMENT PLAN —
                      Text(
                        'Active Treatment Plan',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.red.shade900,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'TREATING: ${activeDisease.toUpperCase()}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          letterSpacing: 2.0,
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<List<DiseaseSpecimen>>(
                        future: DiseaseParser.loadFromAsset(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData) return const SizedBox.shrink();
                          
                          final diseaseSpecimen = snapshot.data!.firstWhere(
                            (d) => d.name == activeDisease,
                            orElse: () => snapshot.data!.first, // fallback
                          );
                          
                          return _buildTreatmentCalendar(context, diseaseSpecimen, treatmentStartDate);
                        },
                      ),
                      const SizedBox(height: 48),
                    ],

                    // — CULTIVAR PROFILE —
                    Text(
                      'Cultivar Profile',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
                      ),
                      child: Text(
                        profile['profile']!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurface,
                          height: 1.7,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // — CURATOR'S ADVICE —
                    Text(
                      'Curator\'s Advice',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'For the ${currentStage['name']} stage',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 2.0,
                        color: AppColors.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.onSurface.withValues(alpha: 0.06),
                            blurRadius: 32,
                            offset: const Offset(0, 4),
                          ),
                        ],
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
                            child: const Icon(Icons.tips_and_updates, color: AppColors.primaryContainer, size: 22),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              advice,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurface,
                                height: 1.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, DateTime originDate, int currentStageIdx) {
    return Column(
      children: List.generate(_stages.length, (i) {
        final stage = _stages[i];
        final isPast = i < currentStageIdx;
        final isCurrent = i == currentStageIdx;
        final isFuture = i > currentStageIdx;

        final predictedDate = originDate.add(Duration(days: stage['daysFromOrigin'] as int));
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final dateLabel = '${predictedDate.day} ${months[predictedDate.month - 1]}';

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: timeline rail
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  // Circle
                  Container(
                    width: isCurrent ? 20 : 14,
                    height: isCurrent ? 20 : 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isPast
                          ? AppColors.primaryContainer
                          : (isCurrent ? AppColors.primary : AppColors.surfaceVariant),
                      border: isCurrent
                          ? Border.all(color: AppColors.primary, width: 3)
                          : null,
                    ),
                    child: isPast
                        ? const Icon(Icons.check, color: AppColors.onPrimary, size: 10)
                        : null,
                  ),
                  // Line
                  if (i < _stages.length - 1)
                    Container(
                      width: 2,
                      height: 60,
                      color: isPast ? AppColors.primaryContainer : AppColors.outlineVariant.withValues(alpha: 0.3),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Right: content
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppColors.surfaceContainerLow
                      : (isFuture ? AppColors.background : AppColors.background),
                  borderRadius: BorderRadius.circular(12),
                  border: isCurrent
                      ? Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15))
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stage['name'],
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: isFuture ? AppColors.outlineVariant : AppColors.primary,
                            letterSpacing: 1.5,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stage['desc'],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isFuture ? AppColors.outlineVariant : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      dateLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isFuture ? AppColors.outlineVariant : AppColors.primaryContainer,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w600,
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

  Widget _buildTreatmentCalendar(BuildContext context, DiseaseSpecimen disease, DateTime startDate) {
    final now = DateTime.now();
    final daysElapsed = now.difference(startDate).inDays;
    final totalDays = disease.treatmentDurationDays;
    
    // We create a mini calendar grid representing the treatment days
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day ${daysElapsed.clamp(0, totalDays)} of $totalDays',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.red.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.healing, color: Colors.red.shade900),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (daysElapsed / totalDays).clamp(0.0, 1.0),
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade700),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 24),
          // Mini Calendar Grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(totalDays, (index) {
              final dayNum = index + 1;
              final isPast = dayNum <= daysElapsed;
              final isToday = dayNum == daysElapsed + 1;
              
              Color bgColor = AppColors.surfaceContainerLow;
              Color textColor = AppColors.onSurfaceVariant;
              Color borderColor = Colors.transparent;
              
              if (isPast) {
                bgColor = Colors.red.shade50;
                textColor = Colors.red.shade900;
              } else if (isToday) {
                bgColor = Colors.red.shade700;
                textColor = Colors.white;
                borderColor = Colors.red.shade900;
              }
              
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    '$dayNum',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: isToday || isPast ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
