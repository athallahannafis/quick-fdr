import 'package:flutter/material.dart';
import '../models/car_preset.dart';
import '../services/preset_storage.dart';
import '../services/pwa_install_client.dart';
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
  final PwaInstallClient? pwaInstallClient;

  const CalculatorScreen({
    super.key,
    this.storage,
    this.pwaInstallClient,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  static const int _minPinion = 6;
  static const int _maxPinion = 80;

  late final PresetStorage _storage;
  late final PwaInstallClient _pwaInstallClient;

  List<CarPreset> _presets = [];
  final Map<String, ({int spur, int pinion})> _savedGearsByKit = {};
  CarPreset? _selectedPreset;
  int _currentSpur = 70;
  int _currentPinion = 22;
  bool _isLoading = true;
  bool _canInstallPwa = false;

  @override
  void initState() {
    super.initState();
    _storage = widget.storage ?? PresetStorage();
    _pwaInstallClient = widget.pwaInstallClient ?? createPwaInstallClient();
    _canInstallPwa = _pwaInstallClient.canInstall;
    _pwaInstallClient.setOnInstalled(() {
      if (mounted) {
        setState(() {
          _canInstallPwa = false;
        });
      }
    });
    _initPresets();
  }

  @override
  void dispose() {
    _pwaInstallClient.setOnInstalled(null);
    super.dispose();
  }

  void _applySelectedPreset(CarPreset preset) {
    final saved = _savedGearsByKit[preset.id];
    _selectedPreset = preset;
    _currentSpur = saved?.spur ?? preset.defaultSpur;
    _currentPinion = saved?.pinion ?? preset.defaultPinion;
  }

  void _updateCurrentGears({int? spur, int? pinion}) {
    final activeKit = _selectedPreset;
    if (activeKit == null) return;

    final nextSpur = spur ?? _currentSpur;
    final nextPinion = pinion ?? _currentPinion;

    setState(() {
      _currentSpur = nextSpur;
      _currentPinion = nextPinion;
      _savedGearsByKit[activeKit.id] = (spur: nextSpur, pinion: nextPinion);
    });
    _storage.saveKitGears(activeKit.id, spur: nextSpur, pinion: nextPinion);
  }

  Future<void> _initPresets() async {
    final allPresets = await _storage.loadAllPresets();
    final lastKitId = await _storage.getLastSelectedKitId();
    final savedGears = await _storage.loadAllKitGears(allPresets.map((p) => p.id));

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
        _savedGearsByKit
          ..clear()
          ..addAll(savedGears);
        _applySelectedPreset(activeKit);
        _isLoading = false;
      });
    }
  }

  void _onSelectPreset(CarPreset preset) {
    setState(() {
      _applySelectedPreset(preset);
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
          if (!mounted) return;
          setState(() {
            _presets = updated;
            _applySelectedPreset(newPreset);
          });
          _storage.saveLastSelectedKitId(newPreset.id);
        },
      ),
    );
  }

  Future<void> _onDeletePreset(String id) async {
    await _storage.deletePreset(id);
    final updated = await _storage.loadAllPresets();
    if (!mounted) return;
    setState(() {
      _presets = updated;
      _savedGearsByKit.remove(id);
      if (_selectedPreset?.id == id) {
        _applySelectedPreset(updated.first);
      }
    });
    if (_selectedPreset != null) {
      _storage.saveLastSelectedKitId(_selectedPreset!.id);
    }
  }

  void _resetToStock() {
    final activeKit = _selectedPreset;
    if (activeKit != null) {
      setState(() {
        _currentSpur = activeKit.defaultSpur;
        _currentPinion = activeKit.defaultPinion;
        _savedGearsByKit.remove(activeKit.id);
      });
      _storage.clearKitGears(activeKit.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reset to ${activeKit.name} stock: ${activeKit.defaultSpur}T Spur, ${activeKit.defaultPinion}T Pinion',
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
        minPinion: _minPinion,
        onSelectPinion: (newPinion) {
          _updateCurrentGears(pinion: newPinion.clamp(_minPinion, _maxPinion));
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
          if (_canInstallPwa)
            IconButton(
              icon: const Icon(Icons.install_mobile_rounded, color: RcTheme.accentCyan),
              tooltip: 'Install App',
              onPressed: _pwaInstallClient.triggerInstall,
            ),
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
                      minValue: _minPinion,
                      maxValue: _maxPinion,
                      stepIntervals: const [1, 5],
                      onChanged: (val) => _updateCurrentGears(pinion: val),
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
                      onChanged: (val) => _updateCurrentGears(spur: val),
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
