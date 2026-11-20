import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quick_fdr/services/preset_storage.dart';
import 'package:quick_fdr/services/pwa_install_client.dart';
import 'package:quick_fdr/theme/rc_theme.dart';
import 'package:quick_fdr/screens/calculator_screen.dart';

class _FakePwaInstallClient implements PwaInstallClient {
  @override
  bool canInstall;
  int triggerCount = 0;
  void Function()? onInstalled;

  _FakePwaInstallClient({this.canInstall = false});

  @override
  void triggerInstall() {
    triggerCount++;
  }

  @override
  void setOnInstalled(void Function()? callback) {
    onInstalled = callback;
  }

  void simulateInstalled() {
    canInstall = false;
    onInstalled?.call();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PresetStorage storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = PresetStorage();
  });

  testWidgets('CalculatorScreen loads presets, calculates FDR, and reacts to adjustments', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: RcTheme.themeData,
        home: CalculatorScreen(storage: storage),
      ),
    );

    // Initial load wait
    await tester.pumpAndSettle();

    // Verify app title and presets present
    expect(find.text('QUICK FDR'), findsOneWidget);
    expect(find.text('LC10B5'), findsOneWidget);
    expect(find.text('PTG2R'), findsOneWidget);
    expect(find.text('TT02'), findsWidgets); // Appears in chip and telemetry badge

    // Default preset is TT02: Spur 70, Pinion 22, IGR 2.60 -> 8.27
    expect(find.text('8.27'), findsOneWidget);
    expect(find.textContaining('2.60'), findsWidgets);

    // Step Pinion +1 (from 22 to 23)
    // 70 / 23 * 2.60 = 7.9130... -> 7.91
    await tester.tap(find.text('+1').first);
    await tester.pumpAndSettle();

    expect(find.text('23'), findsWidgets);
    expect(find.text('7.91'), findsOneWidget);

    // Tap LC10B5 chip (Spur 78, Pinion 23, IGR 2.50 -> 8.48)
    await tester.tap(find.text('LC10B5'));
    await tester.pumpAndSettle();

    expect(find.text('8.48'), findsOneWidget);
    expect(find.textContaining('2.50'), findsWidgets);

    // Tap Reset to Stock button
    await tester.tap(find.byTooltip('Reset to Kit Stock'));
    await tester.pumpAndSettle();

    expect(find.text('8.48'), findsOneWidget);

    // Open Pinion Matrix
    await tester.tap(find.byTooltip('Pinion Matrix'));
    await tester.pumpAndSettle();

    expect(find.text('PINION FDR MATRIX'), findsOneWidget);

    // Close Pinion Matrix
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.text('PINION FDR MATRIX'), findsNothing);
  });

  testWidgets('allows pinion down to 6T and clamps below 6T', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: RcTheme.themeData,
        home: CalculatorScreen(storage: storage),
      ),
    );

    await tester.pumpAndSettle();

    // TT02 starts at Pinion 22; decrement by 5 three times (22 -> 17 -> 12 -> 7)
    for (int i = 0; i < 3; i++) {
      await tester.tap(find.text('-5').first);
      await tester.pumpAndSettle();
    }
    expect(find.text('7'), findsOneWidget);

    // Decrement by 1 to reach 6T (70 / 6 * 2.60 = 30.333... -> 30.33)
    await tester.tap(find.text('-1').first);
    await tester.pumpAndSettle();
    expect(find.text('6'), findsOneWidget);
    expect(find.text('30.33'), findsOneWidget);

    // Further decrementing clamps at 6T
    await tester.tap(find.text('-1').first);
    await tester.pumpAndSettle();
    expect(find.text('6'), findsOneWidget);

    await tester.tap(find.text('-5').first);
    await tester.pumpAndSettle();
    expect(find.text('6'), findsOneWidget);

    // Pinion Matrix should start at 6T and not show 5T
    await tester.tap(find.byTooltip('Pinion Matrix'));
    await tester.pumpAndSettle();
    expect(find.text('6 T'), findsOneWidget);
    expect(find.text('5 T'), findsNothing);
  });

  testWidgets('preserves updated pinion and spur values across kit tab switches', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: RcTheme.themeData,
        home: CalculatorScreen(storage: storage),
      ),
    );
    await tester.pumpAndSettle();

    // Start on TT02 (Spur 70, Pinion 22, IGR 2.60 -> 8.27)
    // Change Pinion +5 (22 -> 27) and Spur +1 (70 -> 71)
    // 71 / 27 * 2.60 = 6.8370... -> 6.84
    await tester.tap(find.text('+5'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('+1').last);
    await tester.tap(find.text('+1').last); // Spur +1
    await tester.pumpAndSettle();

    expect(find.text('6.84'), findsOneWidget);
    expect(find.text('(71T / 27T) × 2.60 IGR'), findsOneWidget);

    // Switch to LC10B5 (Spur 78, Pinion 23, IGR 2.50 -> 8.48)
    await tester.ensureVisible(find.text('LC10B5'));
    await tester.tap(find.text('LC10B5'));
    await tester.pumpAndSettle();
    expect(find.text('8.48'), findsOneWidget);

    // Update LC10B5 Pinion -1 (23 -> 22) and Spur -1 (78 -> 77)
    // 77 / 22 * 2.50 = 8.75
    await tester.ensureVisible(find.text('-1').first);
    await tester.tap(find.text('-1').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('-1').last);
    await tester.tap(find.text('-1').last);
    await tester.pumpAndSettle();
    expect(find.text('8.75'), findsOneWidget);
    expect(find.text('(77T / 22T) × 2.50 IGR'), findsOneWidget);

    // Switch back to TT02 -> previous updates (Spur 71, Pinion 27) must be preserved
    await tester.ensureVisible(find.text('TT02').first);
    await tester.tap(find.text('TT02').first);
    await tester.pumpAndSettle();
    expect(find.text('6.84'), findsOneWidget);
    expect(find.text('(71T / 27T) × 2.60 IGR'), findsOneWidget);

    // Switch back to LC10B5 -> previous updates (Spur 77, Pinion 22) must be preserved
    await tester.ensureVisible(find.text('LC10B5'));
    await tester.tap(find.text('LC10B5'));
    await tester.pumpAndSettle();
    expect(find.text('8.75'), findsOneWidget);
    expect(find.text('(77T / 22T) × 2.50 IGR'), findsOneWidget);

    // Reset LC10B5 to stock -> only LC10B5 resets; TT02 keeps its updated values
    await tester.ensureVisible(find.byTooltip('Reset to Kit Stock'));
    await tester.tap(find.byTooltip('Reset to Kit Stock'));
    await tester.pumpAndSettle();
    expect(find.text('8.48'), findsOneWidget);

    await tester.ensureVisible(find.text('TT02').first);
    await tester.tap(find.text('TT02').first);
    await tester.pumpAndSettle();
    expect(find.text('6.84'), findsOneWidget);
    expect(find.text('(71T / 27T) × 2.60 IGR'), findsOneWidget);

    // Switching back to LC10B5 should still show stock (8.48)
    await tester.ensureVisible(find.text('LC10B5'));
    await tester.tap(find.text('LC10B5'));
    await tester.pumpAndSettle();
    expect(find.text('8.48'), findsOneWidget);
  });

  testWidgets('persists updated pinion and spur across screen reloads', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: RcTheme.themeData,
        home: CalculatorScreen(storage: storage),
      ),
    );
    await tester.pumpAndSettle();

    // Update TT02 via Pinion Matrix and Spur direct-input dialog
    await tester.tap(find.byTooltip('Pinion Matrix'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).last, const Offset(0, -150));
    await tester.pumpAndSettle();
    await tester.tap(find.text('25 T'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('70'));
    await tester.tap(find.text('70'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '71');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.text('(71T / 25T) × 2.60 IGR'), findsOneWidget);

    // Rebuild a fresh CalculatorScreen using the same storage (simulates app restart)
    await tester.pumpWidget(
      MaterialApp(
        key: const ValueKey('reloaded_app'),
        theme: RcTheme.themeData,
        home: CalculatorScreen(storage: storage),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('(71T / 25T) × 2.60 IGR'), findsOneWidget);
  });

  testWidgets('preserves updated pinion and spur for custom presets across tab switches', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: RcTheme.themeData,
        home: CalculatorScreen(storage: storage),
      ),
    );
    await tester.pumpAndSettle();

    // Add a custom preset
    await tester.ensureVisible(find.text('+ Add Kit'));
    await tester.tap(find.text('+ Add Kit'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('preset_name_field')), 'Xray X4');
    await tester.enterText(find.byKey(const Key('preset_igr_field')), '1.90');
    await tester.enterText(find.byKey(const Key('preset_spur_field')), '90');
    await tester.enterText(find.byKey(const Key('preset_pinion_field')), '30');
    await tester.tap(find.text('Save Preset'));
    await tester.pumpAndSettle();

    expect(find.text('(90T / 30T) × 1.90 IGR'), findsOneWidget);

    // Adjust custom preset Pinion +1 (30 -> 31) and Spur -1 (90 -> 89)
    await tester.ensureVisible(find.text('+1').first);
    await tester.tap(find.text('+1').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('-1').last);
    await tester.tap(find.text('-1').last);
    await tester.pumpAndSettle();
    expect(find.text('(89T / 31T) × 1.90 IGR'), findsOneWidget);

    // Switch to TT02 and back to Xray X4
    await tester.ensureVisible(find.text('TT02').first);
    await tester.tap(find.text('TT02').first);
    await tester.pumpAndSettle();
    expect(find.text('(70T / 22T) × 2.60 IGR'), findsOneWidget);

    await tester.ensureVisible(find.text('Xray X4').first);
    await tester.tap(find.text('Xray X4').first);
    await tester.pumpAndSettle();
    expect(find.text('(89T / 31T) × 1.90 IGR'), findsOneWidget);
  });

  testWidgets('shows Install App shortcut next to Pinion Matrix when installable and hides after install', (WidgetTester tester) async {
    final pwaClient = _FakePwaInstallClient(canInstall: true);

    await tester.pumpWidget(
      MaterialApp(
        theme: RcTheme.themeData,
        home: CalculatorScreen(
          storage: storage,
          pwaInstallClient: pwaClient,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final installButton = find.byTooltip('Install App');
    expect(installButton, findsOneWidget);

    await tester.tap(installButton);
    await tester.pump();
    expect(pwaClient.triggerCount, 1);

    pwaClient.simulateInstalled();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Install App'), findsNothing);
  });
}
