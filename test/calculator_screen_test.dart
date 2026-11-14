import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quick_fdr/services/preset_storage.dart';
import 'package:quick_fdr/theme/rc_theme.dart';
import 'package:quick_fdr/screens/calculator_screen.dart';

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
}
