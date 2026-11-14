import 'package:flutter/material.dart';
import '../models/car_preset.dart';
import '../theme/rc_theme.dart';

/// Horizontal scrollable preset selector chips with kit name, IGR badge, and custom kit deletion.
class KitSelectorChips extends StatelessWidget {
  final List<CarPreset> presets;
  final CarPreset selectedPreset;
  final ValueChanged<CarPreset> onSelectPreset;
  final VoidCallback onAddPreset;
  final ValueChanged<String> onDeletePreset;

  const KitSelectorChips({
    super.key,
    required this.presets,
    required this.selectedPreset,
    required this.onSelectPreset,
    required this.onAddPreset,
    required this.onDeletePreset,
  });

  void _confirmDelete(BuildContext context, CarPreset preset) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: RcTheme.surfaceNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: RcTheme.borderNavy),
          ),
          title: Text(
            'Delete ${preset.name}?',
            style: const TextStyle(color: RcTheme.textWhite, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete this custom preset (${preset.name} with IGR ${preset.igr.toStringAsFixed(2)})?',
            style: const TextStyle(color: RcTheme.textMuted, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: RcTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: RcTheme.dangerRed),
              onPressed: () {
                Navigator.of(ctx).pop();
                onDeletePreset(preset.id);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: presets.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          // "+ Add Kit" action chip at the end
          if (index == presets.length) {
            return ActionChip(
              avatar: const Icon(Icons.add_rounded, size: 18, color: RcTheme.accentCyan),
              label: const Text(
                '+ Add Kit',
                style: TextStyle(
                  color: RcTheme.accentCyan,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: RcTheme.surfaceNavy,
              side: BorderSide(color: RcTheme.accentCyan.withValues(alpha: 0.5), width: 1.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              onPressed: onAddPreset,
            );
          }

          final preset = presets[index];
          final isSelected = preset.id == selectedPreset.id;

          return Material(
            color: isSelected ? RcTheme.electricBlue : RcTheme.surfaceNavy,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: () => onSelectPreset(preset),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? RcTheme.accentCyan : RcTheme.borderNavy,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      preset.name,
                      style: TextStyle(
                        color: isSelected ? RcTheme.textWhite : RcTheme.textWhite.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? RcTheme.backgroundNavy.withValues(alpha: 0.4) : RcTheme.elevatedNavy,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        preset.igr.toStringAsFixed(2),
                        style: TextStyle(
                          color: isSelected ? RcTheme.accentCyan : RcTheme.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    // Delete button for custom presets
                    if (!preset.isBuiltIn) ...[
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _confirmDelete(context, preset),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: isSelected ? RcTheme.textWhite : RcTheme.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
