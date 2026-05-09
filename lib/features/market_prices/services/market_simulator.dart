import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// Represents a single date variety with its live price state.
class DateVarietyPrice {
  final String name;
  final double basePrice;
  double currentPrice;
  List<double> priceHistory;
  double lastChange;
  bool isUp;

  DateVarietyPrice({
    required this.name,
    required this.basePrice,
  })  : currentPrice = basePrice,
        priceHistory = [basePrice],
        lastChange = 0.0,
        isUp = true;

  double get changePercent {
    if (priceHistory.length < 2) return 0.0;
    final prev = priceHistory[priceHistory.length - 2];
    if (prev == 0) return 0.0;
    return ((currentPrice - prev) / prev) * 100;
  }

  double get totalChangePercent {
    if (basePrice == 0) return 0.0;
    return ((currentPrice - basePrice) / basePrice) * 100;
  }
}

/// The Market Pulse simulation engine.
///
/// Generates Gaussian-distributed price fluctuations at randomized intervals
/// (5–10 seconds). Extends [ChangeNotifier] so only price-dependent widgets
/// rebuild — the full page scaffold is untouched.
class MarketSimulator extends ChangeNotifier {
  // ── Configuration ──────────────────────────────────────────────────────
  static const double _volatilityMin = -0.005; // -0.5%
  static const double _volatilityMax = 0.008;  // +0.8%
  static const double _normalMean = 0.0015;    // Slight bullish lean
  static const double _ramadanMean = 0.0025;   // Stronger bullish lean
  static const double _stdDev = 0.003;         // Gaussian spread
  static const int _maxHistoryPoints = 30;     // Sparkline data cap
  static const int _minIntervalSec = 5;
  static const int _maxIntervalSec = 10;

  // ── State ──────────────────────────────────────────────────────────────
  final List<DateVarietyPrice> varieties;
  final Random _random = Random();
  Timer? _timer;

  bool _useSimulation = true;
  bool get useSimulation => _useSimulation;

  bool _isPreRamadan = false;
  bool get isPreRamadan => _isPreRamadan;

  bool _isRunning = false;
  bool get isRunning => _isRunning;

  // ── Constructor ────────────────────────────────────────────────────────
  MarketSimulator()
      : varieties = [
          DateVarietyPrice(name: 'Medjool', basePrice: 3.850),
          DateVarietyPrice(name: 'Ajwa', basePrice: 6.500),
          DateVarietyPrice(name: 'Deglet Noor', basePrice: 1.950),
        ] {
    start();
  }

  // ── Public API ─────────────────────────────────────────────────────────

  /// Start the price poller.
  void start() {
    if (_isRunning || !_useSimulation) return;
    _isRunning = true;
    _scheduleNextTick();
    notifyListeners();
  }

  /// Stop the price poller.
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    notifyListeners();
  }

  /// Toggle between Simulation mode and (future) Real API mode.
  void toggleMode() {
    _useSimulation = !_useSimulation;
    if (_useSimulation) {
      start();
    } else {
      stop();
    }
    notifyListeners();
  }

  /// Toggle the Pre-Ramadan bullish bias.
  void togglePreRamadan() {
    _isPreRamadan = !_isPreRamadan;
    notifyListeners();
  }

  /// Reset all prices to their base values.
  void resetPrices() {
    for (final v in varieties) {
      v.currentPrice = v.basePrice;
      v.priceHistory = [v.basePrice];
      v.lastChange = 0.0;
      v.isUp = true;
    }
    notifyListeners();
  }

  // ── Private ────────────────────────────────────────────────────────────

  /// Schedules the next tick at a random interval between 5–10 seconds.
  void _scheduleNextTick() {
    final seconds =
        _minIntervalSec + _random.nextInt(_maxIntervalSec - _minIntervalSec + 1);
    _timer = Timer(Duration(seconds: seconds), () {
      _tick();
      if (_isRunning) _scheduleNextTick();
    });
  }

  /// Executes one price update cycle across all varieties.
  void _tick() {
    for (final variety in varieties) {
      final delta = _generateGaussianDelta();
      final newPrice = variety.currentPrice * (1 + delta);

      variety.lastChange = newPrice - variety.currentPrice;
      variety.isUp = variety.lastChange >= 0;
      variety.currentPrice = double.parse(newPrice.toStringAsFixed(2));

      variety.priceHistory.add(variety.currentPrice);
      if (variety.priceHistory.length > _maxHistoryPoints) {
        variety.priceHistory.removeAt(0);
      }
    }
    notifyListeners();
  }

  /// Generates a Gaussian-distributed price change using the Box-Muller transform,
  /// then clamps it to the allowed volatility window.
  double _generateGaussianDelta() {
    // Box-Muller transform: convert two uniform randoms into a Gaussian
    final u1 = _random.nextDouble();
    final u2 = _random.nextDouble();
    final z = sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);

    final mean = _isPreRamadan ? _ramadanMean : _normalMean;
    final raw = mean + z * _stdDev;

    // Clamp to the volatility window
    return raw.clamp(_volatilityMin, _volatilityMax);
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
