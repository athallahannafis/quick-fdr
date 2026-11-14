import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/rc_theme.dart';
import '../widgets/rc_gear_logo.dart';

/// Clean splash screen featuring the custom RC gear logo and "Quick FDR" branding.
class SplashScreen extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onTimeout;

  const SplashScreen({
    super.key,
    this.duration = const Duration(milliseconds: 1500),
    this.onTimeout,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();

    _timer = Timer(widget.duration, () {
      if (mounted) {
        widget.onTimeout?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RcTheme.backgroundNavy,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Custom RC Gear Meshing Logo
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: RcTheme.surfaceNavy,
                    border: Border.all(color: RcTheme.borderNavy, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: RcTheme.accentCyan.withValues(alpha: 0.12),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const RcGearLogo(size: 110),
                ),
                const SizedBox(height: 32),
                // Bold Racing App Name
                const Text(
                  'Quick FDR',
                  style: TextStyle(
                    color: RcTheme.textWhite,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 8),
                // RC Telemetry Subtitle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: RcTheme.elevatedNavy,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: RcTheme.borderNavy, width: 1),
                  ),
                  child: const Text(
                    'RC FINAL DRIVE RATIO',
                    style: TextStyle(
                      color: RcTheme.accentCyan,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
