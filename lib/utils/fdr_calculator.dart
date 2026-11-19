/// Utility class for calculating RC Final Drive Ratio (FDR) and gear metrics.
class FdrCalculator {
  /// Calculates Final Drive Ratio: (Spur / Pinion) * Internal Gear Ratio (IGR).
  ///
  /// Returns 0.0 if any parameter is zero or negative.
  static double calculateFdr({
    required int spur,
    required int pinion,
    required double igr,
  }) {
    if (pinion <= 0 || spur <= 0 || igr <= 0) {
      return 0.0;
    }
    return (spur / pinion) * igr;
  }

  /// Calculates Transmission Gear Ratio: Spur / Pinion.
  ///
  /// Returns 0.0 if pinion or spur is zero or negative.
  static double calculateGearRatio({
    required int spur,
    required int pinion,
  }) {
    if (pinion <= 0 || spur <= 0) {
      return 0.0;
    }
    return spur / pinion;
  }

  /// Formats an FDR number to 2 decimal places, or '---' if non-positive.
  static String formatFdr(double fdr) {
    if (fdr <= 0) {
      return '---';
    }
    return fdr.toStringAsFixed(2);
  }

  /// Generates a reference lookup table for adjacent pinion sizes.
  ///
  /// [range] specifies how many teeth above and below [basePinion] to include.
  /// [minPinion] specifies the lowest pinion tooth count to include.
  static List<Map<String, dynamic>> calculatePinionTable({
    required int spur,
    required double igr,
    required int basePinion,
    int range = 5,
    int minPinion = 1,
  }) {
    final list = <Map<String, dynamic>>[];
    final startPinion = (basePinion - range < minPinion) ? minPinion : (basePinion - range);
    final endPinion = basePinion + range;

    for (int p = startPinion; p <= endPinion; p++) {
      final fdr = calculateFdr(spur: spur, pinion: p, igr: igr);
      list.add({
        'pinion': p,
        'fdr': fdr,
        'fdrFormatted': formatFdr(fdr),
        'isCurrent': p == basePinion,
      });
    }

    return list;
  }
}
