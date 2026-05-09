/// ═══════════════════════════════════════════════════════════════════════════════
/// market_ticker.dart — Auto-Scrolling Price Ticker Bar
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// A horizontally scrolling ticker bar (like a stock market ticker) that shows
/// live price updates for all date varieties. Uses animation to scroll smoothly
/// and duplicates the item list 3× to create a seamless infinite loop.
///
/// Gradient fades on both edges prevent content from being abruptly cut off.
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../services/market_simulator.dart';

/// A horizontally auto-scrolling ticker bar displaying live price data.
///
/// Uses an [AnimationController] for continuous smooth scrolling. The item list
/// is duplicated to create a seamless infinite loop. Gradient fades are applied
/// at the left and right edges.
class MarketTicker extends StatefulWidget {
  final List<DateVarietyPrice> varieties;

  const MarketTicker({super.key, required this.varieties});

  @override
  State<MarketTicker> createState() => _MarketTickerState();
}

class _MarketTickerState extends State<MarketTicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scrollController;
  late final ScrollController _listController;

  @override
  void initState() {
    super.initState();
    _listController = ScrollController();
    _scrollController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..addListener(_onScrollTick);
    _scrollController.repeat();
  }

  void _onScrollTick() {
    if (!_listController.hasClients) return;
    final maxScroll = _listController.position.maxScrollExtent;
    final currentScroll = _scrollController.value * maxScroll;
    _listController.jumpTo(currentScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Duplicate the list 3× for a seamless loop
    final items = [
      ...widget.varieties,
      ...widget.varieties,
      ...widget.varieties,
    ];

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.vanillaCustard.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.ghostBorder),
      ),
      child: ShaderMask(
        shaderCallback: (bounds) {
          return const LinearGradient(
            colors: [
              Colors.transparent,
              Colors.white,
              Colors.white,
              Colors.transparent,
            ],
            stops: [0.0, 0.05, 0.95, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: ListView.builder(
          controller: _listController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final variety = items[index];
            final isUp = variety.isUp;
            final color =
                isUp ? AppColors.bullishGreen : AppColors.bearishRed;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Variety name
                  Text(
                    variety.name.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Price
                  Text(
                    variety.currentPrice.toStringAsFixed(3),
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Trend arrow
                  Icon(
                    isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: color,
                    size: 18,
                  ),
                  // Separator dot
                  const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: SizedBox(
                      width: 3,
                      height: 3,
                      child: DecoratedBox(decoration: BoxDecoration(
                        color: Color(0x4D54433B),
                        shape: BoxShape.circle,
                      )),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
