import 'package:flutter/material.dart';
import '../models/car_preset.dart';
import '../theme/rc_theme.dart';

enum _PresetMenuAction {
  togglePin,
  rename,
  remove,
}

/// Horizontal scrollable preset selector chips with kit name, IGR badge, pin flag, and per-preset menu.
class KitSelectorChips extends StatelessWidget {
  final List<CarPreset> presets;
  final CarPreset? selectedPreset;
  final ValueChanged<CarPreset> onSelectPreset;
  final VoidCallback onAddPreset;
  final ValueChanged<String> onTogglePinPreset;
  final void Function(String id, String newName) onRenamePreset;
  final ValueChanged<String> onDeletePreset;

  const KitSelectorChips({
    super.key,
    required this.presets,
    required this.selectedPreset,
    required this.onSelectPreset,
    required this.onAddPreset,
    required this.onTogglePinPreset,
    required this.onRenamePreset,
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
          ),
          title: Text(
            'Delete ${preset.name}?',
            style: const TextStyle(
              color: RcTheme.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this preset (${preset.name} with IGR ${preset.igr.toStringAsFixed(2)})?',
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

  void _showRenameDialog(BuildContext context, CarPreset preset) {
    showDialog(
      context: context,
      builder: (ctx) => _RenamePresetDialog(
        initialName: preset.name,
        onConfirm: (newName) => onRenamePreset(preset.id, newName),
      ),
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
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              onPressed: onAddPreset,
            );
          }

          final preset = presets[index];
          final isSelected = selectedPreset?.id == preset.id;

          return Material(
            color: isSelected ? RcTheme.electricBlue : RcTheme.surfaceNavy,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: () => onSelectPreset(preset),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (preset.isPinned) ...[
                      Icon(
                        Icons.push_pin_rounded,
                        key: Key('preset_pin_badge_${preset.id}'),
                        size: 13,
                        color: isSelected ? RcTheme.textWhite : RcTheme.lockedGold,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      preset.name,
                      style: TextStyle(
                        color: isSelected
                            ? RcTheme.textWhite
                            : RcTheme.textWhite.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? RcTheme.backgroundNavy.withValues(alpha: 0.4)
                            : RcTheme.elevatedNavy,
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
                    const SizedBox(width: 2),
                    PopupMenuButton<_PresetMenuAction>(
                      key: Key('preset_menu_${preset.id}'),
                      tooltip: 'Preset options',
                      color: RcTheme.surfaceNavy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: RcTheme.borderNavy),
                      ),
                      padding: EdgeInsets.zero,
                      onSelected: (action) {
                        switch (action) {
                          case _PresetMenuAction.togglePin:
                            onTogglePinPreset(preset.id);
                          case _PresetMenuAction.rename:
                            _showRenameDialog(context, preset);
                          case _PresetMenuAction.remove:
                            _confirmDelete(context, preset);
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem<_PresetMenuAction>(
                          value: _PresetMenuAction.togglePin,
                          child: Row(
                            children: [
                              Icon(
                                preset.isPinned
                                    ? Icons.push_pin_outlined
                                    : Icons.push_pin_rounded,
                                size: 16,
                                color: preset.isPinned
                                    ? RcTheme.lockedGold
                                    : RcTheme.accentCyan,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                preset.isPinned ? 'Unpin' : 'Pin to Leftmost',
                                style: const TextStyle(
                                  color: RcTheme.textWhite,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem<_PresetMenuAction>(
                          value: _PresetMenuAction.rename,
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                size: 16,
                                color: RcTheme.textWhite,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Rename',
                                style: TextStyle(
                                  color: RcTheme.textWhite,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem<_PresetMenuAction>(
                          value: _PresetMenuAction.remove,
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 16,
                                color: RcTheme.dangerRed,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Remove',
                                style: TextStyle(
                                  color: RcTheme.dangerRed,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.more_vert_rounded,
                          size: 16,
                          color: isSelected ? RcTheme.textWhite : RcTheme.textMuted,
                        ),
                      ),
                    ),
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

class _RenamePresetDialog extends StatefulWidget {
  final String initialName;
  final ValueChanged<String> onConfirm;

  const _RenamePresetDialog({
    required this.initialName,
    required this.onConfirm,
  });

  @override
  State<_RenamePresetDialog> createState() => _RenamePresetDialogState();
}

class _RenamePresetDialogState extends State<_RenamePresetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onConfirm(_controller.text.trim());
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: RcTheme.surfaceNavy,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        'Rename Preset',
        style: TextStyle(
          color: RcTheme.textWhite,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          key: const Key('rename_preset_field'),
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: RcTheme.textWhite, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            labelText: 'Preset Name',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a preset name';
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: RcTheme.textMuted)),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
