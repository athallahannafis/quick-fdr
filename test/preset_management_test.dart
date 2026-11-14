import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_fdr/models/car_preset.dart';
import 'package:quick_fdr/theme/rc_theme.dart';
import 'package:quick_fdr/widgets/kit_selector_chips.dart';
import 'package:quick_fdr/widgets/add_preset_dialog.dart';

void main() {
  const defaultPresets = [
    CarPreset(id: 'lc10b5', name: 'LC10B5', igr: 2.50, defaultSpur: 78, defaultPinion: 23, isBuiltIn: true),
    CarPreset(id: 'ptg2r', name: 'PTG2R', igr: 2.50, defaultSpur: 70, defaultPinion: 25, isBuiltIn: true),
    CarPreset(id: 'tt02', name: 'TT02', igr: 2.60, defaultSpur: 70, defaultPinion: 22, isBuiltIn: true),
  ];

  group('KitSelectorChips Widget', () {
    testWidgets('renders preset chips, highlights selected, and triggers callbacks', (WidgetTester tester) async {
      CarPreset selected = defaultPresets[2]; // TT02
      bool addTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: RcTheme.themeData,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return KitSelectorChips(
                  presets: defaultPresets,
                  selectedPreset: selected,
                  onSelectPreset: (preset) {
                    setState(() {
                      selected = preset;
                    });
                  },
                  onAddPreset: () {
                    addTapped = true;
                  },
                  onDeletePreset: (_) {},
                );
              },
            ),
          ),
        ),
      );

      // Verify all default preset names and Add Kit chip appear
      expect(find.text('LC10B5'), findsOneWidget);
      expect(find.text('PTG2R'), findsOneWidget);
      expect(find.text('TT02'), findsOneWidget);
      expect(find.text('+ Add Kit'), findsOneWidget);

      // Tap LC10B5
      await tester.tap(find.text('LC10B5'));
      await tester.pump();
      expect(selected.id, 'lc10b5');

      // Tap Add Kit
      await tester.tap(find.text('+ Add Kit'));
      await tester.pump();
      expect(addTapped, isTrue);
    });
  });

  group('AddPresetDialog Widget', () {
    testWidgets('validates inputs and creates new preset with immutable IGR', (WidgetTester tester) async {
      CarPreset? createdPreset;

      await tester.pumpWidget(
        MaterialApp(
          theme: RcTheme.themeData,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AddPresetDialog(
                        onSave: (preset) {
                          createdPreset = preset;
                        },
                      ),
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Check for lock warning banner
      expect(find.textContaining('cannot be edited'), findsOneWidget);

      // Fill in fields
      await tester.enterText(find.byKey(const Key('preset_name_field')), 'Kyosho Fazer');
      await tester.enterText(find.byKey(const Key('preset_igr_field')), '2.47');
      await tester.enterText(find.byKey(const Key('preset_spur_field')), '68');
      await tester.enterText(find.byKey(const Key('preset_pinion_field')), '32');

      // Tap Save
      await tester.tap(find.text('Save Preset'));
      await tester.pumpAndSettle();

      expect(createdPreset, isNotNull);
      expect(createdPreset!.name, 'Kyosho Fazer');
      expect(createdPreset!.igr, 2.47);
      expect(createdPreset!.defaultSpur, 68);
      expect(createdPreset!.defaultPinion, 32);
      expect(createdPreset!.isBuiltIn, false);
    });
  });
}
