import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quick_fdr/main.dart';
import 'package:quick_fdr/widgets/rc_gear_logo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('QuickFdrApp launches into splash screen and then presents calculator', (WidgetTester tester) async {
    await tester.pumpWidget(const QuickFdrApp());

    // Initially on splash screen
    expect(find.text('Quick FDR'), findsOneWidget);
    expect(find.byType(RcGearLogo), findsOneWidget);

    // Fast forward past splash timer (1600ms)
    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pumpAndSettle();

    // Now on Calculator Screen
    expect(find.text('QUICK FDR'), findsOneWidget);
    expect(find.text('TT02'), findsWidgets);
    expect(find.text('FINAL DRIVE RATIO'), findsOneWidget);
  });
}
