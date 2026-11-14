import 'package:flutter/material.dart';
import '../theme/rc_theme.dart';

/// Telemetry dashboard card displaying the computed Final Drive Ratio (FDR),
/// kit info, locked IGR indicator, and exact calculation breakdown.
class FdrTelemetryCard extends StatelessWidget {
  final String kitName;
  final double igr;
  final int spur;
  final int pinion;
  final double fdr;
  final String fdrFormatted;
  final double gearRatio;

  const FdrTelemetryCard({
    super.key,
    required this.kitName,
    required this.igr,
    required this.spur,
    required this.pinion,
    required this.fdr,
    required this.fdrFormatted,
    required this.gearRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: RcTheme.surfaceNavy,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RcTheme.borderNavy, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: RcTheme.accentCyan.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle telemetry corner bracket decoration
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: const BoxDecoration(
                color: RcTheme.elevatedNavy,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(14),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    size: 13,
                    color: RcTheme.lockedGold,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'IGR: ${igr.toStringAsFixed(2)} LOCKED',
                    style: const TextStyle(
                      color: RcTheme.lockedGold,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Kit Name Header
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: RcTheme.backgroundNavy,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: RcTheme.borderNavy),
                      ),
                      child: Text(
                        kitName.toUpperCase(),
                        style: const TextStyle(
                          color: RcTheme.accentCyan,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Main FDR Digital Telemetry Readout
                const Text(
                  'FINAL DRIVE RATIO',
                  style: TextStyle(
                    color: RcTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fdrFormatted,
                  style: const TextStyle(
                    color: RcTheme.textWhite,
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 14),

                // Calculation Breakdown Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: RcTheme.backgroundNavy.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: RcTheme.borderNavy),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calculate_outlined,
                        size: 16,
                        color: RcTheme.accentCyan,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '(${spur}T / ${pinion}T) × ${igr.toStringAsFixed(2)} IGR',
                          style: const TextStyle(
                            color: RcTheme.textWhite,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Transmission Ratio Detail
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Gear Ratio (Spur/Pinion): ',
                      style: TextStyle(
                        color: RcTheme.textMuted.withValues(alpha: 0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${gearRatio.toStringAsFixed(2)} : 1',
                      style: const TextStyle(
                        color: RcTheme.accentCyan,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
