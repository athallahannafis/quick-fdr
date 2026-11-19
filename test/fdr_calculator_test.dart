import 'package:flutter_test/flutter_test.dart';
import 'package:quick_fdr/utils/fdr_calculator.dart';

void main() {
  group('FdrCalculator', () {
    test('calculates correct FDR for standard values', () {
      // TT-02: 70T spur, 22T pinion, 2.60 IGR -> 8.2727...
      final tt02Fdr = FdrCalculator.calculateFdr(spur: 70, pinion: 22, igr: 2.60);
      expect(tt02Fdr, closeTo(8.2727, 0.001));

      // LC10B5: 78T spur, 23T pinion, 2.50 IGR -> 8.4782...
      final lc10b5Fdr = FdrCalculator.calculateFdr(spur: 78, pinion: 23, igr: 2.50);
      expect(lc10b5Fdr, closeTo(8.4782, 0.001));

      // PTG2R: 70T spur, 25T pinion, 2.50 IGR -> 7.0
      final ptg2rFdr = FdrCalculator.calculateFdr(spur: 70, pinion: 25, igr: 2.50);
      expect(ptg2rFdr, closeTo(7.0, 0.001));
    });

    test('handles edge cases gracefully (zero or negative inputs)', () {
      expect(FdrCalculator.calculateFdr(spur: 70, pinion: 0, igr: 2.60), 0.0);
      expect(FdrCalculator.calculateFdr(spur: 70, pinion: -1, igr: 2.60), 0.0);
      expect(FdrCalculator.calculateFdr(spur: 0, pinion: 22, igr: 2.60), 0.0);
      expect(FdrCalculator.calculateFdr(spur: -70, pinion: 22, igr: 2.60), 0.0);
      expect(FdrCalculator.calculateFdr(spur: 70, pinion: 22, igr: 0.0), 0.0);
      expect(FdrCalculator.calculateFdr(spur: 70, pinion: 22, igr: -2.60), 0.0);
    });

    test('formats FDR correctly', () {
      expect(FdrCalculator.formatFdr(8.2727), '8.27');
      expect(FdrCalculator.formatFdr(7.0), '7.00');
      expect(FdrCalculator.formatFdr(0.0), '---');
      expect(FdrCalculator.formatFdr(-1.0), '---');
    });

    test('calculates transmission ratio (spur / pinion)', () {
      expect(FdrCalculator.calculateGearRatio(spur: 70, pinion: 22), closeTo(3.1818, 0.001));
      expect(FdrCalculator.calculateGearRatio(spur: 70, pinion: 0), 0.0);
    });

    test('generates pinion reference table around base pinion', () {
      final table = FdrCalculator.calculatePinionTable(
        spur: 70,
        igr: 2.60,
        basePinion: 22,
        range: 2,
      );

      // Should include pinions: 20, 21, 22, 23, 24
      expect(table.length, 5);
      expect(table.first['pinion'], 20);
      expect(table.last['pinion'], 24);

      final currentEntry = table.firstWhere((e) => e['isCurrent'] == true);
      expect(currentEntry['pinion'], 22);
      expect(currentEntry['fdrFormatted'], '8.27');
    });

    test('clamps pinion reference table to minPinion', () {
      final table = FdrCalculator.calculatePinionTable(
        spur: 70,
        igr: 2.60,
        basePinion: 6,
        range: 6,
        minPinion: 6,
      );

      expect(table.first['pinion'], 6);
      expect(table.last['pinion'], 12);
    });
  });
}
