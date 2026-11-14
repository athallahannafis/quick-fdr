import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/calculator_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/rc_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI navigation bar and status bar to blend into deep navy theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: RcTheme.backgroundNavy,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const QuickFdrApp());
}

class QuickFdrApp extends StatelessWidget {
  const QuickFdrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick FDR',
      debugShowCheckedModeBanner: false,
      theme: RcTheme.themeData,
      home: const _AppNavigator(),
    );
  }
}

class _AppNavigator extends StatefulWidget {
  const _AppNavigator();

  @override
  State<_AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<_AppNavigator> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(
        duration: const Duration(milliseconds: 1600),
        onTimeout: () {
          if (mounted) {
            setState(() {
              _showSplash = false;
            });
          }
        },
      );
    }
    return const CalculatorScreen();
  }
}
