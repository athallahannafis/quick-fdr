import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/car_preset.dart';

/// Storage service for loading and saving built-in and user-defined car presets.
class PresetStorage {
  static const String _presetsKey = 'car_presets';
  static const String _customPresetsKey = 'custom_car_presets';
  static const String _lastSelectedKey = 'last_selected_kit_id';
  static const String _kitGearsKeyPrefix = 'kit_gears_';

  /// Default built-in presets required by specifications:
  /// LC10B5 (2.50 IGR), PTG2R (2.50 IGR), and TT02 (2.60 IGR).
  static const List<CarPreset> defaultPresets = [
    CarPreset(
      id: 'lc10b5',
      name: 'LC10B5',
      igr: 2.50,
      defaultSpur: 78,
      defaultPinion: 23,
      isBuiltIn: true,
    ),
    CarPreset(
      id: 'ptg2r',
      name: 'PTG2R',
      igr: 2.50,
      defaultSpur: 70,
      defaultPinion: 25,
      isBuiltIn: true,
    ),
    CarPreset(
      id: 'tt02',
      name: 'TT02',
      igr: 2.60,
      defaultSpur: 70,
      defaultPinion: 22,
      isBuiltIn: true,
    ),
  ];

  List<CarPreset> _decodePresets(List<String> jsonList) {
    final presets = <CarPreset>[];
    for (final jsonStr in jsonList) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        presets.add(CarPreset.fromJson(map));
      } catch (_) {
        // Skip corrupt entry gracefully
      }
    }
    return presets;
  }

  Future<void> _savePresetsList(
    SharedPreferences prefs,
    List<CarPreset> presets,
  ) async {
    await prefs.setStringList(
      _presetsKey,
      presets.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }

  /// Loads all presets in their saved display order, seeding built-in defaults on first run.
  Future<List<CarPreset>> loadAllPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final storedJsonList = prefs.getStringList(_presetsKey);

    if (storedJsonList == null) {
      final legacyCustomList = prefs.getStringList(_customPresetsKey) ?? [];
      final initial = [...defaultPresets, ..._decodePresets(legacyCustomList)];
      await _savePresetsList(prefs, initial);
      return initial;
    }

    return _decodePresets(storedJsonList);
  }

  /// Saves a new custom preset or updates an existing preset in place.
  Future<void> saveCustomPreset(CarPreset preset) async {
    final presets = await loadAllPresets();
    final prefs = await SharedPreferences.getInstance();
    final index = presets.indexWhere((p) => p.id == preset.id);
    if (index >= 0) {
      presets[index] = preset;
    } else {
      presets.add(preset);
    }
    await _savePresetsList(prefs, presets);
  }

  /// Renames any preset (built-in or custom) while preserving its IGR and gear defaults.
  Future<void> renamePreset(String id, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    final presets = await loadAllPresets();
    final index = presets.indexWhere((p) => p.id == id);
    if (index < 0) return;

    presets[index] = presets[index].copyWith(name: trimmed);
    final prefs = await SharedPreferences.getInstance();
    await _savePresetsList(prefs, presets);
  }

  /// Pins any preset to the leftmost (first) position.
  Future<void> pinPresetToLeft(String id) async {
    final presets = await loadAllPresets();
    final index = presets.indexWhere((p) => p.id == id);
    if (index <= 0) return;

    final target = presets.removeAt(index);
    presets.insert(0, target);
    final prefs = await SharedPreferences.getInstance();
    await _savePresetsList(prefs, presets);
  }

  /// Deletes a preset by ID (built-in or custom) and clears its saved gear values.
  Future<void> deletePreset(String id) async {
    final presets = await loadAllPresets();
    presets.removeWhere((p) => p.id == id);

    final prefs = await SharedPreferences.getInstance();
    await _savePresetsList(prefs, presets);
    await prefs.remove('$_kitGearsKeyPrefix$id');
  }

  /// Saves the current spur and pinion tooth counts for a specific kit preset.
  Future<void> saveKitGears(
    String kitId, {
    required int spur,
    required int pinion,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_kitGearsKeyPrefix$kitId',
      jsonEncode({'spur': spur, 'pinion': pinion}),
    );
  }

  /// Loads saved spur and pinion tooth counts for the given kit IDs.
  Future<Map<String, ({int spur, int pinion})>> loadAllKitGears(
    Iterable<String> kitIds,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final result = <String, ({int spur, int pinion})>{};

    for (final kitId in kitIds) {
      final raw = prefs.getString('$_kitGearsKeyPrefix$kitId');
      if (raw == null) continue;
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final spur = (map['spur'] as num).toInt();
        final pinion = (map['pinion'] as num).toInt();
        if (spur > 0 && pinion > 0) {
          result[kitId] = (spur: spur, pinion: pinion);
        }
      } catch (_) {
        // Skip corrupt entry gracefully
      }
    }

    return result;
  }

  /// Clears saved spur and pinion tooth counts for a specific kit preset.
  Future<void> clearKitGears(String kitId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_kitGearsKeyPrefix$kitId');
  }

  /// Saves the last selected kit ID.
  Future<void> saveLastSelectedKitId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSelectedKey, id);
  }

  /// Clears the last selected kit ID.
  Future<void> clearLastSelectedKitId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSelectedKey);
  }

  /// Retrieves the last selected kit ID, or null if none saved.
  Future<String?> getLastSelectedKitId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSelectedKey);
  }
}
