import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_fdr/models/car_preset.dart';
import 'package:quick_fdr/theme/rc_theme.dart';
import 'package:quick_fdr/widgets/kit_selector_chips.dart';
import 'package:quick_fdr/widgets/add_preset_dialog.dart';

void main() {
  const defaultPresets = [
    CarPreset(id: 'lc10b5', name: 'LC10B5', igr: 2.50, defaultSpur: 78, defaultPinion: 23, isBuiltIn: true, isPinned: true),
    CarPreset(id: 'ptg2r', name: 'PTG2R', igr: 2.50, defaultSpur: 70, defaultPinion: 25, isBuiltIn: true),
    CarPreset(id: 'tt02', name: 'TT02', igr: 2.60, defaultSpur: 70, defaultPinion: 22, isBuiltIn: true),
  ];

  group('KitSelectorChips Widget', () {
    testWidgets('renders preset chips, flagged pin badges, and triggers callbacks', (WidgetTester tester) async {
      CarPreset selected = defaultPresets[2]; // TT02
      bool addTapped = false;
      String? toggledPinId;
      String? renamedId;
      String? renamedValue;
      String? deletedId;

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
                  onTogglePinPreset: (id) {
                    toggledPinId = id;
                  },
                  onRenamePreset: (id, newName) {
                    renamedId = id;
                    renamedValue = newName;
                  },
                  onDeletePreset: (id) {
                    deletedId = id;
                  },
                );
              },
            ),
          ),
        ),
      );

      // Verify all default preset names, flagged pin icon on LC10B5 only, and triple-dot menus appear
      expect(find.text('LC10B5'), findsOneWidget);
      expect(find.text('PTG2R'), findsOneWidget);
      expect(find.text('TT02'), findsOneWidget);
      expect(find.text('Add Kit'), findsOneWidget);
      expect(find.byKey(const Key('preset_pin_badge_lc10b5')), findsOneWidget);
      expect(find.byKey(const Key('preset_pin_badge_ptg2r')), findsNothing);
      expect(find.byKey(const Key('preset_pin_badge_tt02')), findsNothing);
      expect(find.byIcon(Icons.more_vert_rounded), findsNWidgets(3));

      // Tap LC10B5
      await tester.tap(find.text('LC10B5'));
      await tester.pump();
      expect(selected.id, 'lc10b5');

      // Tap Add Kit
      await tester.tap(find.text('Add Kit'));
      await tester.pump();
      expect(addTapped, isTrue);

      // Open pinned LC10B5 menu -> shows "Unpin"
      await tester.tap(find.byKey(const Key('preset_menu_lc10b5')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unpin'));
      await tester.pumpAndSettle();
      expect(toggledPinId, 'lc10b5');

      // Open unpinned TT02 menu and tap Pin to Leftmost
      await tester.tap(find.byKey(const Key('preset_menu_tt02')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pin to Leftmost'));
      await tester.pumpAndSettle();
      expect(toggledPinId, 'tt02');

      // Open LC10B5 menu and Rename
      await tester.tap(find.byKey(const Key('preset_menu_lc10b5')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('rename_preset_field')), 'LC10B5 Pro');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(renamedId, 'lc10b5');
      expect(renamedValue, 'LC10B5 Pro');

      // Open PTG2R menu, tap Remove, test Cancel first, then confirm Delete
      await tester.tap(find.byKey(const Key('preset_menu_ptg2r')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect(find.text('Delete PTG2R?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(deletedId, isNull);

      await tester.tap(find.byKey(const Key('preset_menu_ptg2r')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(deletedId, 'ptg2r');
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

    testWidgets('renders without overflow on narrow 320px width screens', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

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
                        onSave: (_) {},
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

      expect(tester.takeException(), isNull);
      expect(find.text('Add New Kit Preset'), findsOneWidget);
      expect(find.text('Save Preset'), findsOneWidget);
    });
  });
}
