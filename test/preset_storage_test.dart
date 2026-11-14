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

    test('deletes custom presets, but prevents deleting built-in presets', () async {
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

      // Successfully delete custom preset
      await storage.deletePreset('to_delete');
      presets = await storage.loadAllPresets();
      expect(presets.length, 3);
      expect(presets.any((p) => p.id == 'to_delete'), isFalse);

      // Attempting to delete built-in preset TT02 has no effect
      await storage.deletePreset('tt02');
      presets = await storage.loadAllPresets();
      expect(presets.length, 3);
      expect(presets.any((p) => p.id == 'tt02'), isTrue);
    });

    test('stores and retrieves last selected kit ID', () async {
      expect(await storage.getLastSelectedKitId(), isNull);

      await storage.saveLastSelectedKitId('ptg2r');
      expect(await storage.getLastSelectedKitId(), 'ptg2r');
    });
  });
}
