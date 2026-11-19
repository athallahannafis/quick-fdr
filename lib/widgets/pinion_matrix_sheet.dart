import 'package:flutter/material.dart';
import '../theme/rc_theme.dart';
import '../utils/fdr_calculator.dart';

/// Modal bottom sheet showing adjacent pinions and their calculated FDRs.
class PinionMatrixSheet extends StatelessWidget {
  final String kitName;
  final double igr;
  final int currentSpur;
  final int currentPinion;
  final int minPinion;
  final ValueChanged<int> onSelectPinion;

  const PinionMatrixSheet({
    super.key,
    required this.kitName,
    required this.igr,
    required this.currentSpur,
    required this.currentPinion,
    this.minPinion = 6,
    required this.onSelectPinion,
  });

  @override
  Widget build(BuildContext context) {
    final table = FdrCalculator.calculatePinionTable(
      spur: currentSpur,
      igr: igr,
      basePinion: currentPinion,
      range: 6,
      minPinion: minPinion,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        color: RcTheme.surfaceNavy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: RcTheme.borderNavy,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PINION FDR MATRIX',
                    style: TextStyle(
                      color: RcTheme.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$kitName (Spur: ${currentSpur}T • IGR: ${igr.toStringAsFixed(2)})',
                    style: const TextStyle(
                      color: RcTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: RcTheme.textMuted),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: RcTheme.backgroundNavy,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PINION TEETH',
                  style: TextStyle(
                    color: RcTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'FINAL DRIVE RATIO',
                  style: TextStyle(
                    color: RcTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // List of Rows
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: table.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final row = table[index];
                final pinion = row['pinion'] as int;
                final fdrFormatted = row['fdrFormatted'] as String;
                final isCurrent = row['isCurrent'] as bool;

                return InkWell(
                  onTap: () {
                    onSelectPinion(pinion);
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isCurrent ? RcTheme.electricBlue.withValues(alpha: 0.25) : RcTheme.elevatedNavy.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '$pinion T',
                              style: TextStyle(
                                color: isCurrent ? RcTheme.accentCyan : RcTheme.textWhite,
                                fontSize: 15,
                                fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                              ),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: RcTheme.accentCyan,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'CURRENT',
                                  style: TextStyle(
                                    color: RcTheme.backgroundNavy,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          fdrFormatted,
                          style: TextStyle(
                            color: isCurrent ? RcTheme.textWhite : RcTheme.textWhite.withValues(alpha: 0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
