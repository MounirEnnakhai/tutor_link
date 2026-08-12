import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/user_entity.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
    _navigate();
  }

  void _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      context.go(AppRoutes.login);
    } else {
      _redirectByRole(user);
    }
  }

  void _redirectByRole(UserEntity user) {
    switch (user.role) {
      case UserRole.student:
        context.go(AppRoutes.studentHome);
        break;
      case UserRole.tutor:
        context.go(AppRoutes.tutorDashboard);
        break;
      case UserRole.admin:
        context.go(AppRoutes.adminDashboard);
        break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fadeIn,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 52,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'TutorLink',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Learn from the best',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 64),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
