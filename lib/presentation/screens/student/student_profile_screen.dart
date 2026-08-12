import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/app_button.dart';

class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettings(context, ref, themeMode),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor:
                      AppTheme.primaryColor.withOpacity(0.15),
                      child: Text(
                        user.fullName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(user.fullName,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(user.email,
                    style: const TextStyle(
                        color: AppTheme.grey500,
                        fontFamily: 'Poppins')),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.role.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                      letterSpacing: 1,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          _ProfileSection(
            title: 'Account',
            children: [
              _ProfileMenuItem(
                key: const ValueKey('edit_profile'),
                icon: Icons.person_outline,
                label: 'Edit Profile',
                onTap: () {},
              ),
              _ProfileMenuItem(
                key: const ValueKey('saved_tutors'),
                icon: Icons.favorite_border_rounded,
                label: 'Saved Tutors',
                onTap: () => context.push(AppRoutes.favorites),
              ),
              _ProfileMenuItem(
                key: const ValueKey('my_reviews'),
                icon: Icons.rate_review_outlined,
                label: 'My Reviews',
                onTap: () {},
              ),
              _ProfileMenuItem(
                key: const ValueKey('my_requests'),
                icon: Icons.edit_note_rounded,
                label: 'My Requests',
                onTap: () => context.push(AppRoutes.myRequests),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _ProfileSection(
            title: 'Preferences',
            children: [
              _ProfileMenuItem(
                key: const ValueKey('language'),
                icon: Icons.language_outlined,
                label: 'Language',
                trailing: const Text('English'),
                onTap: () {},
              ),
              _ProfileMenuItem(
                key: const ValueKey('notifications'),
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () {},
              ),
              _ProfileMenuItem(
                key: const ValueKey('dark_mode'),
                icon: themeMode == ThemeMode.dark
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                label: 'Dark Mode',
                trailing: Switch(
                  key: const ValueKey('dark_mode_switch'),
                  value: themeMode == ThemeMode.dark,
                  onChanged: (v) {
                    ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(
                      v ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
                onTap: null,
              ),
            ],
          ),
          const SizedBox(height: 16),

          _ProfileSection(
            title: 'Support',
            children: [
              _ProfileMenuItem(
                key: const ValueKey('help'),
                icon: Icons.help_outline_rounded,
                label: 'Help Center',
                onTap: () {},
              ),
              _ProfileMenuItem(
                key: const ValueKey('privacy'),
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: () {},
              ),
              _ProfileMenuItem(
                key: const ValueKey('terms'),
                icon: Icons.description_outlined,
                label: 'Terms of Service',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),

          AppButton(
            label: 'Sign Out',
            isOutlined: true,
            icon: Icons.logout_rounded,
            onPressed: () async {
              await ref
                  .read(authNotifierProvider.notifier)
                  .signOut();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showSettings(
      BuildContext context, WidgetRef ref, ThemeMode currentMode) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Settings',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ThemeButton(
                  icon: Icons.light_mode,
                  label: 'Light',
                  isSelected: currentMode == ThemeMode.light,
                  onTap: () {
                    ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.light);
                    Navigator.pop(context);
                  },
                ),
                _ThemeButton(
                  icon: Icons.dark_mode,
                  label: 'Dark',
                  isSelected: currentMode == ThemeMode.dark,
                  onTap: () {
                    ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.dark);
                    Navigator.pop(context);
                  },
                ),
                _ThemeButton(
                  icon: Icons.auto_mode,
                  label: 'System',
                  isSelected: currentMode == ThemeMode.system,
                  onTap: () {
                    ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.system);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _ThemeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.grey100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon,
                color:
                isSelected ? Colors.white : AppTheme.grey600),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.grey600,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<_ProfileMenuItem> children;
  const _ProfileSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.grey400,
              letterSpacing: 1.2,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.grey200),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  const Divider(height: 1, indent: 56),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _ProfileMenuItem({
    super.key,
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
              Icon(icon, size: 18, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            trailing ??
                (onTap != null
                    ? const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppTheme.grey400)
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}