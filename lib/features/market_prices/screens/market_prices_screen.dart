import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routing/app_routes.dart';
import '../services/market_simulator.dart';
import '../widgets/market_ticker.dart';
import '../widgets/pulse_card.dart';

/// The Market Pulse screen — a dynamic, live-updating trading floor experience.
///
/// Architecture:
/// - A single [MarketSimulator] instance drives all price updates.
/// - [ListenableBuilder] wraps only price-dependent UI (ticker + cards),
///   so the scaffold, app bar, and background never re-render on ticks.
/// - A hidden developer toggle is accessible by triple-tapping the section label.
class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen> {
  late final MarketSimulator _simulator;

  @override
  void initState() {
    super.initState();
    _simulator = MarketSimulator();
  }

  @override
  void dispose() {
    _simulator.dispose();
    super.dispose();
  }

  /// Shows the hidden developer toggle panel.
  void _showDevPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DevToggleSheet(simulator: _simulator),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Background botanical watermark
            const Positioned(
              bottom: -30,
              right: -50,
              child: Icon(
                Icons.show_chart,
                size: 200,
                color: Color(0x0FDAC2B7),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── App Bar ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.eco, color: AppColors.primary, size: 20),
                      Text(
                        'DATECARE',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              letterSpacing: 3.0,
                              fontSize: 18,
                            ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primaryContainer,
                          child: Icon(Icons.person,
                              color: AppColors.onPrimary, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Section Label (triple-tap for dev panel) ─────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GestureDetector(
                    onDoubleTap: _showDevPanel,
                    child: Row(
                      children: [
                        const Icon(Icons.ssid_chart,
                            color: AppColors.onSurfaceVariant, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'MARKET PULSE — LIVE SIMULATION',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                letterSpacing: 2.0,
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Live Ticker Bar ──────────────────────────────────────
                ListenableBuilder(
                  listenable: _simulator,
                  builder: (context, _) {
                    return MarketTicker(varieties: _simulator.varieties);
                  },
                ),
                const SizedBox(height: 24),

                // ── Pulse Cards ──────────────────────────────────────────
                Expanded(
                  child: ListenableBuilder(
                    listenable: _simulator,
                    builder: (context, _) {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _simulator.varieties.length,
                        itemBuilder: (context, index) {
                          return PulseCard(
                            variety: _simulator.varieties[index],
                          );
                        },
                      );
                    },
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

// ═══════════════════════════════════════════════════════════════════════════════
// Developer Toggle Bottom Sheet
// ═══════════════════════════════════════════════════════════════════════════════

/// A hidden developer panel for controlling the simulation engine.
class _DevToggleSheet extends StatefulWidget {
  final MarketSimulator simulator;

  const _DevToggleSheet({required this.simulator});

  @override
  State<_DevToggleSheet> createState() => _DevToggleSheetState();
}

class _DevToggleSheetState extends State<_DevToggleSheet> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.simulator,
      builder: (context, _) {
        final sim = widget.simulator;
        return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            border: Border.all(color: AppColors.ghostBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.onSurface.withValues(alpha: 0.08),
                blurRadius: 40,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'DEVELOPER CONSOLE',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      letterSpacing: 2.0,
                      fontSize: 14,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Market Pulse Engine Controls',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),

              // ── Simulation Toggle ────────────────────────────────────
              _DevSwitch(
                label: 'Simulation Mode',
                subtitle: sim.useSimulation
                    ? 'Active — generating prices'
                    : 'Inactive — awaiting Real API',
                value: sim.useSimulation,
                onChanged: (_) => sim.toggleMode(),
              ),
              const SizedBox(height: 16),

              // ── Pre-Ramadan Bias Toggle ──────────────────────────────
              _DevSwitch(
                label: 'Pre-Ramadan Bias',
                subtitle: sim.isPreRamadan
                    ? 'Bullish bias active (+0.25% mean)'
                    : 'Normal volatility (+0.15% mean)',
                value: sim.isPreRamadan,
                onChanged: (_) => sim.togglePreRamadan(),
              ),
              const SizedBox(height: 24),

              // ── Reset Button ─────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    sim.resetPrices();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.bearishRed),
                    foregroundColor: AppColors.bearishRed,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.restart_alt, size: 18),
                  label: const Text(
                    'RESET TO BASE PRICES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Status ───────────────────────────────────────────────
              Center(
                child: Text(
                  sim.isRunning ? '● Engine Running' : '○ Engine Stopped',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: sim.isRunning
                        ? AppColors.bullishGreen
                        : AppColors.bearishRed,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

/// A styled switch row for the developer console.
class _DevSwitch extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _DevSwitch({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
          activeTrackColor: AppColors.primaryContainer,
          inactiveThumbColor: AppColors.outlineVariant,
          inactiveTrackColor: AppColors.surfaceContainerHighest,
        ),
      ],
    );
  }
}
