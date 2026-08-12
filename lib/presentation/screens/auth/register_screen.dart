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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  UserRole _selectedRole = UserRole.student;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await ref.read(authNotifierProvider.notifier).register(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          fullName: _nameCtrl.text.trim(),
          role: _selectedRole,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    final authState = ref.read(authNotifierProvider);
    authState.when(
      data: (user) {
        if (user != null) _redirectByRole(user);
      },
      error: (e, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Join TutorLink',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Connect with the best tutors or share your knowledge.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.grey500,
                ),
              ),
              const SizedBox(height: 32),

              // Role Selection
              Text(
                'I want to join as',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _RoleCard(
                    role: UserRole.student,
                    icon: Icons.menu_book_rounded,
                    label: 'Student',
                    description: 'Find tutors & learn',
                    isSelected: _selectedRole == UserRole.student,
                    onTap: () => setState(() => _selectedRole = UserRole.student),
                  ),
                  const SizedBox(width: 12),
                  _RoleCard(
                    role: UserRole.tutor,
                    icon: Icons.cast_for_education_rounded,
                    label: 'Tutor',
                    description: 'Teach & earn',
                    isSelected: _selectedRole == UserRole.tutor,
                    onTap: () => setState(() => _selectedRole = UserRole.tutor),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Full Name
              AppTextField(
                controller: _nameCtrl,
                label: 'Full Name',
                hintText: 'Your full name',
                prefixIcon: Icons.person_outline,
                validator: Validators.requiredField,
              ),
              const SizedBox(height: 16),

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
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: Validators.password,
              ),
              const SizedBox(height: 16),

              // Confirm Password
              AppTextField(
                controller: _confirmPasswordCtrl,
                label: 'Confirm Password',
                hintText: '••••••••',
                obscureText: _obscurePassword,
                prefixIcon: Icons.lock_outline,
                validator: (val) {
                  if (val != _passwordCtrl.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Terms note
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text.rich(
                  TextSpan(
                    text: 'By registering, you agree to our ',
                    style: TextStyle(
                        color: AppTheme.grey500, fontSize: 12),
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Register Button
              AppButton(
                label: 'Create Account',
                onPressed: _register,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.grey500,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.pop(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Sign In',
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
    );
  }
}

class _RoleCard extends StatelessWidget {
  final UserRole role;
  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withOpacity(0.08)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.grey200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : AppTheme.grey500,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : Theme.of(context).colorScheme.onSurface,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.grey500,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
