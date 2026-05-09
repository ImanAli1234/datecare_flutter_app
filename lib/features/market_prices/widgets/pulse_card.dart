import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../services/market_simulator.dart';
import 'sparkline_painter.dart';

/// A "Pulse Card" displaying a date variety's live price, sparkline, and status.
///
/// Uses the Vanilla Custard + Ghost Border card pattern from the Digital Herbarium
/// design system. Only the price number and sparkline rebuild on data changes.
class PulseCard extends StatelessWidget {
  final DateVarietyPrice variety;

  const PulseCard({super.key, required this.variety});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUp = variety.isUp;
    final trendColor = isUp ? AppColors.bullishGreen : AppColors.bearishRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.vanillaCustard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ghostBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row: Name + LIVE dot ────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                variety.name.toUpperCase(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  letterSpacing: 2.0,
                  fontSize: 15,
                ),
              ),
              _LiveDot(),
            ],
          ),
          const SizedBox(height: 16),

          // ── Price row: Current price + Change badge ─────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Animated price number
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  '${variety.currentPrice.toStringAsFixed(3)} OMR',
                  key: ValueKey<double>(variety.currentPrice),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Trend badge
              _TrendBadge(
                isUp: isUp,
                changePercent: variety.changePercent,
                trendColor: trendColor,
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Base price reference
          Text(
            'Base: ${variety.basePrice.toStringAsFixed(3)} OMR/kg',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 16),

          // ── Sparkline ──────────────────────────────────────────────────
          SizedBox(
            height: 60,
            width: double.infinity,
            child: CustomPaint(
              painter: SparklinePainter(
                data: variety.priceHistory,
                lineColor: AppColors.saddleTerracotta,
                strokeWidth: 2.0,
              ),
            ),
          ),

          const SizedBox(height: 8),
          // Total change from base
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${variety.priceHistory.length} ticks',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
              Text(
                'From base: ${variety.totalChangePercent >= 0 ? '+' : ''}${variety.totalChangePercent.toStringAsFixed(2)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: variety.totalChangePercent >= 0
                      ? AppColors.bullishGreen
                      : AppColors.bearishRed,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A small pulsing "LIVE" indicator dot.
class _LiveDot extends StatefulWidget {
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacityAnim = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnim.value,
              child: Opacity(
                opacity: _opacityAnim.value,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.deepEspresso,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 6),
        Text(
          'LIVE',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppColors.deepEspresso.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

/// A small pill-shaped badge showing the price trend direction and percentage.
class _TrendBadge extends StatelessWidget {
  final bool isUp;
  final double changePercent;
  final Color trendColor;

  const _TrendBadge({
    required this.isUp,
    required this.changePercent,
    required this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: trendColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: trendColor,
            size: 16,
          ),
          Text(
            '${changePercent.abs().toStringAsFixed(2)}%',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: trendColor,
            ),
          ),
        ],
      ),
    );
  }
}
