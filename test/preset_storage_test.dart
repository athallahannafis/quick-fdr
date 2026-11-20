import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quick_fdr/models/car_preset.dart';
import 'package:quick_fdr/services/preset_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CarPreset Model', () {
    test('serializes to and from JSON correctly', () {
      const preset = CarPreset(
        id: 'custom_1',
        name: 'Kyosho Fazer Mk2',
        igr: 2.47,
        defaultSpur: 68,
        defaultPinion: 32,
        isBuiltIn: false,
      );

      final json = preset.toJson();
      final deserialized = CarPreset.fromJson(json);

      expect(deserialized.id, 'custom_1');
      expect(deserialized.name, 'Kyosho Fazer Mk2');
      expect(deserialized.igr, 2.47);
      expect(deserialized.defaultSpur, 68);
      expect(deserialized.defaultPinion, 32);
      expect(deserialized.isBuiltIn, false);
    });
  });

  group('PresetStorage Service', () {
    late PresetStorage storage;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storage = PresetStorage();
    });

    test('initial load returns the 3 built-in presets (LC10B5, PTG2R, TT02)', () async {
      final presets = await storage.loadAllPresets();

      expect(presets.length, 3);
      expect(presets.any((p) => p.id == 'lc10b5' && p.igr == 2.50 && p.isBuiltIn), isTrue);
      expect(presets.any((p) => p.id == 'ptg2r' && p.igr == 2.50 && p.isBuiltIn), isTrue);
      expect(presets.any((p) => p.id == 'tt02' && p.igr == 2.60 && p.isBuiltIn), isTrue);
    });

    test('saves and retrieves custom presets without modifying built-in presets', () async {
      const custom = CarPreset(
        id: 'custom_xray',
        name: 'Xray X4',
        igr: 1.90,
        defaultSpur: 110,
        defaultPinion: 35,
        isBuiltIn: false,
      );

      await storage.saveCustomPreset(custom);

      final presets = await storage.loadAllPresets();
      expect(presets.length, 4);

      final retrieved = presets.firstWhere((p) => p.id == 'custom_xray');
      expect(retrieved.name, 'Xray X4');
      expect(retrieved.igr, 1.90);
      expect(retrieved.isBuiltIn, false);
    });

    test('deletes both custom and built-in presets persistently', () async {
      const custom = CarPreset(
        id: 'to_delete',
        name: 'Delete Me',
        igr: 2.0,
        defaultSpur: 70,
        defaultPinion: 20,
        isBuiltIn: false,
      );

      await storage.saveCustomPreset(custom);
      var presets = await storage.loadAllPresets();
      expect(presets.length, 4);

      // Delete custom preset
      await storage.deletePreset('to_delete');
      presets = await storage.loadAllPresets();
      expect(presets.length, 3);
      expect(presets.any((p) => p.id == 'to_delete'), isFalse);

      // Delete built-in preset TT02
      await storage.deletePreset('tt02');
      presets = await storage.loadAllPresets();
      expect(presets.length, 2);
      expect(presets.any((p) => p.id == 'tt02'), isFalse);

      // Deleting all remaining presets does not resurrect defaults
      await storage.deletePreset('lc10b5');
      await storage.deletePreset('ptg2r');
      presets = await storage.loadAllPresets();
      expect(presets, isEmpty);
    });

    test('renames built-in and custom presets while preserving IGR', () async {
      await storage.renamePreset('tt02', 'Tamiya TT-02');
      final presets = await storage.loadAllPresets();
      final tt02 = presets.firstWhere((p) => p.id == 'tt02');
      expect(tt02.name, 'Tamiya TT-02');
      expect(tt02.igr, 2.60);
      expect(tt02.defaultSpur, 70);
      expect(tt02.defaultPinion, 22);
    });

    test('supports pinning multiple presets to leftmost and unpinning them', () async {
      await storage.togglePinPreset('tt02');
      await storage.togglePinPreset('ptg2r');

      var presets = await storage.loadAllPresets();
      expect(presets.map((p) => p.id).toList(), ['tt02', 'ptg2r', 'lc10b5']);
      expect(presets[0].isPinned, isTrue);
      expect(presets[1].isPinned, isTrue);
      expect(presets[2].isPinned, isFalse);

      // Adding a new unpinned custom preset places it after all pinned presets
      const custom = CarPreset(
        id: 'custom_x4',
        name: 'Xray X4',
        igr: 1.90,
        defaultSpur: 90,
        defaultPinion: 30,
        isBuiltIn: false,
      );
      await storage.saveCustomPreset(custom);
      presets = await storage.loadAllPresets();
      expect(presets.map((p) => p.id).toList(), ['tt02', 'ptg2r', 'lc10b5', 'custom_x4']);

      // Unpin TT02 -> PTG2R remains leftmost pinned, TT02 moves to unpinned section
      await storage.togglePinPreset('tt02');
      presets = await storage.loadAllPresets();
      expect(presets.map((p) => p.id).toList(), ['ptg2r', 'tt02', 'lc10b5', 'custom_x4']);
      expect(presets[0].isPinned, isTrue);
      expect(presets[1].isPinned, isFalse);
    });

    test('stores and retrieves last selected kit ID', () async {
      expect(await storage.getLastSelectedKitId(), isNull);

      await storage.saveLastSelectedKitId('ptg2r');
      expect(await storage.getLastSelectedKitId(), 'ptg2r');
    });

    test('saves, loads, and clears per-kit spur and pinion values', () async {
      await storage.saveKitGears('tt02', spur: 74, pinion: 26);
      await storage.saveKitGears('lc10b5', spur: 80, pinion: 21);

      final loaded = await storage.loadAllKitGears(['tt02', 'lc10b5', 'ptg2r']);
      expect(loaded['tt02'], (spur: 74, pinion: 26));
      expect(loaded['lc10b5'], (spur: 80, pinion: 21));
      expect(loaded.containsKey('ptg2r'), isFalse);

      await storage.clearKitGears('tt02');
      final afterClear = await storage.loadAllKitGears(['tt02', 'lc10b5']);
      expect(afterClear.containsKey('tt02'), isFalse);
      expect(afterClear['lc10b5'], (spur: 80, pinion: 21));
    });

    test('deletes saved kit gears when custom preset is deleted', () async {
      const custom = CarPreset(
        id: 'custom_gears',
        name: 'Custom Car',
        igr: 2.10,
        defaultSpur: 72,
        defaultPinion: 24,
        isBuiltIn: false,
      );

      await storage.saveCustomPreset(custom);
      await storage.saveKitGears('custom_gears', spur: 75, pinion: 28);
      await storage.deletePreset('custom_gears');

      final loaded = await storage.loadAllKitGears(['custom_gears']);
      expect(loaded.containsKey('custom_gears'), isFalse);
    });
  });
}
