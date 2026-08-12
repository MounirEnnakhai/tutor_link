import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/user_entity.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await ref.read(authNotifierProvider.notifier).signInWithEmail(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) return;

    final state = ref.read(authNotifierProvider);
    state.when(
      data: (user) {
        if (user != null) {
          _redirectByRole(user);
        } else {
          setState(() => _isLoading = false);
        }
      },
      error: (e, _) {
        setState(() => _isLoading = false);
        _showError(e.toString());
      },
      loading: () {},
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();

    if (!mounted) return;

    final state = ref.read(authNotifierProvider);
    state.when(
      data: (user) {
        if (user != null) {
          _redirectByRole(user);
        } else {
          setState(() => _isLoading = false);
        }
      },
      error: (e, _) {
        setState(() => _isLoading = false);
        _showError(e.toString());
      },
      loading: () {},
    );
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.35,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'TutorLink',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      'Welcome back!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Form
          Positioned(
            top: size.height * 0.28,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Sign In',
                            style: theme.textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Email
                          AppTextField(
                            controller: _emailCtrl,
                            label: 'Email Address',
                            hintText: 'your@email.com',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            validator: Validators.email,
                          ),
                          const SizedBox(height: 16),

                          // Password
                          AppTextField(
                            controller: _passwordCtrl,
                            label: 'Password',
                            hintText: '••••••••',
                            obscureText: _obscurePassword,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppTheme.grey500,
                              ),
                              onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                            ),
                            validator: Validators.password,
                          ),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showForgotPassword,
                              child: const Text('Forgot Password?'),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Sign In button
                          AppButton(
                            label: 'Sign In',
                            onPressed: _signIn,
                            isLoading: _isLoading,
                          ),
                          const SizedBox(height: 20),

                          // Divider
                          Row(children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'or continue with',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.grey500,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ]),
                          const SizedBox(height: 20),

                          // Google Sign-In
                          _GoogleButton(onPressed: _signInWithGoogle),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.grey500,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push(AppRoutes.register),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPassword() {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email to receive a reset link.'),
            const SizedBox(height: 16),
            AppTextField(
              controller: emailCtrl,
              hintText: 'your@email.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ref
                  .read(authNotifierProvider.notifier)
                  .sendPasswordResetEmail(emailCtrl.text.trim());
              if (!mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success
                      ? 'Password reset email sent!'
                      : 'Failed to send reset email'),
                  backgroundColor:
                  success ? AppTheme.successColor : AppTheme.errorColor,
                ),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _GoogleButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: AppTheme.grey300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: const Text(
              'G',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4285F4),
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Continue with Google',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}