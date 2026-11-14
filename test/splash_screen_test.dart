import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_fdr/theme/rc_theme.dart';
import 'package:quick_fdr/widgets/rc_gear_logo.dart';
import 'package:quick_fdr/screens/splash_screen.dart';

void main() {
  testWidgets('SplashScreen displays logo, Quick FDR text and navigates', (WidgetTester tester) async {
    bool navigated = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: RcTheme.themeData,
        home: SplashScreen(
          duration: const Duration(milliseconds: 500),
          onTimeout: () {
            navigated = true;
          },
        ),
      ),
    );

    // Verify initial elements
    expect(find.text('Quick FDR'), findsOneWidget);
    expect(find.byType(RcGearLogo), findsOneWidget);
    expect(find.text('RC FINAL DRIVE RATIO'), findsOneWidget);

    // Fast-forward past splash duration
    await tester.pump(const Duration(milliseconds: 600));

    expect(navigated, isTrue);
  });
}
