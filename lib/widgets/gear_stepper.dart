import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/rc_theme.dart';

/// Pit-friendly gear tooth control widget with fast-increment steppers and tap-to-type.
class GearStepper extends StatelessWidget {
  final String label;
  final String? subtitle;
  final int value;
  final int minValue;
  final int maxValue;
  final List<int> stepIntervals;
  final ValueChanged<int> onChanged;

  const GearStepper({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    this.minValue = 1,
    this.maxValue = 200,
    this.stepIntervals = const [1, 5],
    required this.onChanged,
  });

  void _adjust(int delta) {
    HapticFeedback.selectionClick();
    final newValue = (value + delta).clamp(minValue, maxValue);
    onChanged(newValue);
  }

  void _showDirectInputDialog(BuildContext context) {
    final controller = TextEditingController(text: value.toString());
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
            'Set $label Teeth',
            style: const TextStyle(color: RcTheme.textWhite, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: RcTheme.textWhite, fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              suffixText: 'T',
              suffixStyle: const TextStyle(color: RcTheme.accentCyan, fontWeight: FontWeight.bold),
              hintText: 'e.g. $value',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: RcTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                final entered = int.tryParse(controller.text);
                if (entered != null) {
                  onChanged(entered.clamp(minValue, maxValue));
                }
                Navigator.of(ctx).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: RcTheme.surfaceNavy,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row: Label & Subtitle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: RcTheme.accentCyan,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: RcTheme.textWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                if (subtitle != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: RcTheme.elevatedNavy,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: RcTheme.borderNavy.withOpacity(0.5)),
                    ),
                    child: Text(
                      subtitle!,
                      style: const TextStyle(
                        color: RcTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Main Display: Large Tap-To-Edit Number
            InkWell(
              onTap: () => _showDirectInputDialog(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: RcTheme.backgroundNavy.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: RcTheme.borderNavy),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$value',
                      style: const TextStyle(
                        color: RcTheme.textWhite,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'T',
                      style: TextStyle(
                        color: RcTheme.accentCyan,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.edit_rounded,
                      size: 14,
                      color: RcTheme.textMuted,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Fast Pit Stepper Buttons Row
            Row(
              children: [
                // Decrement buttons
                ...stepIntervals.reversed.map((step) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _buildStepButton(
                        text: '-$step',
                        onTap: () => _adjust(-step),
                        isPrimary: step == 1,
                      ),
                    ),
                  );
                }),
                // Increment buttons
                ...stepIntervals.map((step) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _buildStepButton(
                        text: '+$step',
                        onTap: () => _adjust(step),
                        isPrimary: step == 1,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepButton({
    required String text,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return Material(
      color: isPrimary ? RcTheme.electricBlue : RcTheme.elevatedNavy,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isPrimary ? RcTheme.accentCyan.withOpacity(0.5) : RcTheme.borderNavy,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isPrimary ? RcTheme.textWhite : RcTheme.accentCyan,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
