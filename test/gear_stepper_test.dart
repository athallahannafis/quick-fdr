import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_fdr/theme/rc_theme.dart';
import 'package:quick_fdr/widgets/gear_stepper.dart';
import 'package:quick_fdr/widgets/fdr_telemetry_card.dart';

void main() {
  group('GearStepper Widget', () {
    testWidgets('displays label and value, increments and decrements correctly', (WidgetTester tester) async {
      int currentValue = 22;

      await tester.pumpWidget(
        MaterialApp(
          theme: RcTheme.themeData,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return GearStepper(
                  label: 'PINION GEAR',
                  value: currentValue,
                  minValue: 10,
                  maxValue: 60,
                  stepIntervals: const [1, 5],
                  onChanged: (val) {
                    setState(() {
                      currentValue = val;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Verify label and initial tooth count
      expect(find.text('PINION GEAR'), findsOneWidget);
      expect(find.text('22'), findsOneWidget);
      expect(find.text('T'), findsOneWidget);

      // Tap +1 button
      await tester.tap(find.text('+1'));
      await tester.pump();
      expect(currentValue, 23);
      expect(find.text('23'), findsOneWidget);

      // Tap +5 button
      await tester.tap(find.text('+5'));
      await tester.pump();
      expect(currentValue, 28);
      expect(find.text('28'), findsOneWidget);

      // Tap -1 button
      await tester.tap(find.text('-1'));
      await tester.pump();
      expect(currentValue, 27);
      expect(find.text('27'), findsOneWidget);

      // Tap -5 button
      await tester.tap(find.text('-5'));
      await tester.pump();
      expect(currentValue, 22);
      expect(find.text('22'), findsOneWidget);
    });

    testWidgets('supports single step interval for rarely changed gears like Spur', (WidgetTester tester) async {
      int currentValue = 70;

      await tester.pumpWidget(
        MaterialApp(
          theme: RcTheme.themeData,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return GearStepper(
                  label: 'SPUR GEAR',
                  subtitle: 'Rarely adjusted',
                  value: currentValue,
                  stepIntervals: const [1],
                  onChanged: (val) {
                    setState(() {
                      currentValue = val;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('SPUR GEAR'), findsOneWidget);
      expect(find.text('Rarely adjusted'), findsOneWidget);
      expect(find.text('+5'), findsNothing);
      expect(find.text('+1'), findsOneWidget);

      await tester.tap(find.text('+1'));
      await tester.pump();
      expect(currentValue, 71);
    });
  });

  group('FdrTelemetryCard Widget', () {
    testWidgets('renders FDR, formula breakdown and locked IGR', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: RcTheme.themeData,
          home: const Scaffold(
            body: FdrTelemetryCard(
              kitName: 'TT02',
              igr: 2.60,
              spur: 70,
              pinion: 22,
              fdr: 8.27,
              fdrFormatted: '8.27',
              gearRatio: 3.18,
            ),
          ),
        ),
      );

      expect(find.text('8.27'), findsOneWidget);
      expect(find.text('FINAL DRIVE RATIO'), findsOneWidget);
      expect(find.textContaining('70T / 22T'), findsOneWidget);
      expect(find.textContaining('2.60 IGR'), findsOneWidget);
      expect(find.textContaining('TT02'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    });
  });
}
