import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/car_preset.dart';

/// Storage service for loading and saving built-in and user-defined car presets.
class PresetStorage {
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

  /// Loads all presets combining the permanent built-in presets with saved custom ones.
  Future<List<CarPreset>> loadAllPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final customJsonList = prefs.getStringList(_customPresetsKey) ?? [];

    final customPresets = <CarPreset>[];
    for (final jsonStr in customJsonList) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        customPresets.add(CarPreset.fromJson(map));
      } catch (_) {
        // Skip corrupt entry gracefully
      }
    }

    return [...defaultPresets, ...customPresets];
  }

  /// Saves a new custom preset.
  /// If the ID matches a built-in preset, the save is rejected.
  Future<void> saveCustomPreset(CarPreset preset) async {
    if (preset.isBuiltIn || defaultPresets.any((d) => d.id == preset.id)) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final customJsonList = prefs.getStringList(_customPresetsKey) ?? [];

    // Filter out existing preset with the same id if updating
    final updatedList = customJsonList.where((jsonStr) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return map['id'] != preset.id;
      } catch (_) {
        return false;
      }
    }).toList();

    updatedList.add(jsonEncode(preset.toJson()));
    await prefs.setStringList(_customPresetsKey, updatedList);
  }

  /// Deletes a custom preset by ID.
  /// Built-in presets cannot be deleted.
  Future<void> deletePreset(String id) async {
    if (defaultPresets.any((d) => d.id == id)) {
      // Cannot delete built-in presets
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final customJsonList = prefs.getStringList(_customPresetsKey) ?? [];

    final updatedList = customJsonList.where((jsonStr) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return map['id'] != id;
      } catch (_) {
        return false;
      }
    }).toList();

    await prefs.setStringList(_customPresetsKey, updatedList);
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

  /// Retrieves the last selected kit ID, or null if none saved.
  Future<String?> getLastSelectedKitId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSelectedKey);
  }
}
