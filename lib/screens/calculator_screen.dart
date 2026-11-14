import 'package:flutter/material.dart';
import '../models/car_preset.dart';
import '../services/preset_storage.dart';
import '../theme/rc_theme.dart';
import '../utils/fdr_calculator.dart';
import '../widgets/add_preset_dialog.dart';
import '../widgets/fdr_telemetry_card.dart';
import '../widgets/gear_stepper.dart';
import '../widgets/kit_selector_chips.dart';
import '../widgets/pinion_matrix_sheet.dart';
import '../widgets/rc_gear_logo.dart';

/// Main interactive screen for Quick FDR calculator.
class CalculatorScreen extends StatefulWidget {
  final PresetStorage? storage;

  const CalculatorScreen({
    super.key,
    this.storage,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  late final PresetStorage _storage;

  List<CarPreset> _presets = [];
  CarPreset? _selectedPreset;
  int _currentSpur = 70;
  int _currentPinion = 22;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _storage = widget.storage ?? PresetStorage();
    _initPresets();
  }

  Future<void> _initPresets() async {
    final allPresets = await _storage.loadAllPresets();
    final lastKitId = await _storage.getLastSelectedKitId();

    CarPreset activeKit;
    if (lastKitId != null && allPresets.any((p) => p.id == lastKitId)) {
      activeKit = allPresets.firstWhere((p) => p.id == lastKitId);
    } else {
      // Default to TT02 if present, otherwise first available
      activeKit = allPresets.firstWhere(
        (p) => p.id == 'tt02',
        orElse: () => allPresets.first,
      );
    }

    if (mounted) {
      setState(() {
        _presets = allPresets;
        _selectedPreset = activeKit;
        _currentSpur = activeKit.defaultSpur;
        _currentPinion = activeKit.defaultPinion;
        _isLoading = false;
      });
    }
  }

  void _onSelectPreset(CarPreset preset) {
    setState(() {
      _selectedPreset = preset;
      _currentSpur = preset.defaultSpur;
      _currentPinion = preset.defaultPinion;
    });
    _storage.saveLastSelectedKitId(preset.id);
  }

  Future<void> _onAddPreset() async {
    showDialog(
      context: context,
      builder: (ctx) => AddPresetDialog(
        onSave: (newPreset) async {
          await _storage.saveCustomPreset(newPreset);
          final updated = await _storage.loadAllPresets();
          setState(() {
            _presets = updated;
            _selectedPreset = newPreset;
            _currentSpur = newPreset.defaultSpur;
            _currentPinion = newPreset.defaultPinion;
          });
          _storage.saveLastSelectedKitId(newPreset.id);
        },
      ),
    );
  }

  Future<void> _onDeletePreset(String id) async {
    await _storage.deletePreset(id);
    final updated = await _storage.loadAllPresets();
    setState(() {
      _presets = updated;
      if (_selectedPreset?.id == id) {
        _selectedPreset = updated.first;
        _currentSpur = updated.first.defaultSpur;
        _currentPinion = updated.first.defaultPinion;
      }
    });
  }

  void _resetToStock() {
    if (_selectedPreset != null) {
      setState(() {
        _currentSpur = _selectedPreset!.defaultSpur;
        _currentPinion = _selectedPreset!.defaultPinion;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reset to ${_selectedPreset!.name} stock: ${_selectedPreset!.defaultSpur}T Spur, ${_selectedPreset!.defaultPinion}T Pinion',
            style: const TextStyle(color: RcTheme.textWhite),
          ),
          backgroundColor: RcTheme.elevatedNavy,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showPinionMatrix() {
    if (_selectedPreset == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PinionMatrixSheet(
        kitName: _selectedPreset!.name,
        igr: _selectedPreset!.igr,
        currentSpur: _currentSpur,
        currentPinion: _currentPinion,
        onSelectPinion: (newPinion) {
          setState(() {
            _currentPinion = newPinion;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _selectedPreset == null) {
      return const Scaffold(
        backgroundColor: RcTheme.backgroundNavy,
        body: Center(
          child: CircularProgressIndicator(color: RcTheme.accentCyan),
        ),
      );
    }

    final activeKit = _selectedPreset!;
    final fdr = FdrCalculator.calculateFdr(
      spur: _currentSpur,
      pinion: _currentPinion,
      igr: activeKit.igr,
    );
    final fdrFormatted = FdrCalculator.formatFdr(fdr);
    final gearRatio = FdrCalculator.calculateGearRatio(
      spur: _currentSpur,
      pinion: _currentPinion,
    );

    return Scaffold(
      backgroundColor: RcTheme.backgroundNavy,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: RcTheme.surfaceNavy,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: RcTheme.borderNavy),
              ),
              child: const RcGearLogo(size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'QUICK FDR',
              style: TextStyle(
                color: RcTheme.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart_rounded, color: RcTheme.accentCyan),
            tooltip: 'Pinion Matrix',
            onPressed: _showPinionMatrix,
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded, color: RcTheme.textMuted),
            tooltip: 'Reset to Kit Stock',
            onPressed: _resetToStock,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // Kit Presets Selector Row
              KitSelectorChips(
                presets: _presets,
                selectedPreset: activeKit,
                onSelectPreset: _onSelectPreset,
                onAddPreset: _onAddPreset,
                onDeletePreset: _onDeletePreset,
              ),
              const SizedBox(height: 16),

              // Main FDR Telemetry Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FdrTelemetryCard(
                  kitName: activeKit.name,
                  igr: activeKit.igr,
                  spur: _currentSpur,
                  pinion: _currentPinion,
                  fdr: fdr,
                  fdrFormatted: fdrFormatted,
                  gearRatio: gearRatio,
                ),
              ),
              const SizedBox(height: 16),

              // Gear Tuning Controls Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Pinion Stepper (with +/- 1 and +/- 5 buttons)
                    GearStepper(
                      label: 'PINION GEAR',
                      subtitle: 'Motor shaft gear',
                      value: _currentPinion,
                      minValue: 8,
                      maxValue: 80,
                      stepIntervals: const [1, 5],
                      onChanged: (val) {
                        setState(() {
                          _currentPinion = val;
                        });
                      },
                    ),
                    const SizedBox(height: 8),

                    // Spur Stepper (with +/- 1 buttons, note rarely adjusted)
                    GearStepper(
                      label: 'SPUR GEAR',
                      subtitle: 'Rarely adjusted',
                      value: _currentSpur,
                      minValue: 40,
                      maxValue: 140,
                      stepIntervals: const [1],
                      onChanged: (val) {
                        setState(() {
                          _currentSpur = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
