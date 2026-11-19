import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/car_preset.dart';
import '../theme/rc_theme.dart';

/// Dialog allowing racers to add a custom kit preset with an immutable IGR.
class AddPresetDialog extends StatefulWidget {
  final ValueChanged<CarPreset> onSave;

  const AddPresetDialog({
    super.key,
    required this.onSave,
  });

  @override
  State<AddPresetDialog> createState() => _AddPresetDialogState();
}

class _AddPresetDialogState extends State<AddPresetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _igrController = TextEditingController();
  final _spurController = TextEditingController(text: '70');
  final _pinionController = TextEditingController(text: '22');

  @override
  void dispose() {
    _nameController.dispose();
    _igrController.dispose();
    _spurController.dispose();
    _pinionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final igr = double.parse(_igrController.text.trim());
      final spur = int.parse(_spurController.text.trim());
      final pinion = int.parse(_pinionController.text.trim());

      final newPreset = CarPreset(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        igr: igr,
        defaultSpur: spur,
        defaultPinion: pinion,
        isBuiltIn: false,
      );

      widget.onSave(newPreset);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: RcTheme.surfaceNavy,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: RcTheme.elevatedNavy,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.tune_rounded, color: RcTheme.accentCyan, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Add New Kit Preset',
                      style: TextStyle(
                        color: RcTheme.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Permanent Lock Notice Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: RcTheme.lockedGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lock_rounded, size: 16, color: RcTheme.lockedGold),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Important: Internal Gear Ratio (IGR) is locked once created and cannot be edited later.',
                          style: TextStyle(
                            color: RcTheme.lockedGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Kit Name Field
                TextFormField(
                  key: const Key('preset_name_field'),
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(color: RcTheme.textWhite, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    labelText: 'Kit / Chassis Name',
                    hintText: 'e.g. Kyosho Fazer Mk2, Xray X4',
                    prefixIcon: Icon(Icons.directions_car_rounded, color: RcTheme.textMuted, size: 20),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a kit name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Internal Gear Ratio (IGR) Field
                TextFormField(
                  key: const Key('preset_igr_field'),
                  controller: _igrController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  style: const TextStyle(color: RcTheme.textWhite, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    labelText: 'Internal Gear Ratio (IGR)',
                    hintText: 'e.g. 2.43 or 1.90',
                    prefixIcon: Icon(Icons.lock_outline_rounded, color: RcTheme.lockedGold, size: 20),
                    helperText: 'Chassis transmission differential ratio',
                    helperStyle: TextStyle(color: RcTheme.textMuted, fontSize: 11),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter IGR value';
                    }
                    final parsed = double.tryParse(value.trim());
                    if (parsed == null || parsed <= 0) {
                      return 'IGR must be a positive number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Stock Spur & Pinion Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: const Key('preset_spur_field'),
                        controller: _spurController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(color: RcTheme.textWhite, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: 'Stock Spur',
                          suffixText: 'T',
                        ),
                        validator: (value) {
                          final parsed = int.tryParse(value ?? '');
                          if (parsed == null || parsed <= 0) {
                            return 'Min 1';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        key: const Key('preset_pinion_field'),
                        controller: _pinionController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(color: RcTheme.textWhite, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: 'Stock Pinion',
                          suffixText: 'T',
                        ),
                        validator: (value) {
                          final parsed = int.tryParse(value ?? '');
                          if (parsed == null || parsed <= 0) {
                            return 'Min 1';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(color: RcTheme.textMuted)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Save Preset'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
