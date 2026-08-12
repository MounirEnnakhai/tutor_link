import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../domain/entities/user_entity.dart';
import '../../providers/auth_provider.dart';

final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  final firestore = ref.read(firestoreProvider);
  return firestore
      .collection(AppConstants.usersCollection)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(UserModel.fromFirestore).toList());
});

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  String _searchQuery = '';
  UserRole? _filterRole;

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search, size: 20),
                isDense: true,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Role filter tabs
          _RoleFilterBar(
            selected: _filterRole,
            onChanged: (r) => setState(() => _filterRole = r),
          ),
          const Divider(height: 1),

          Expanded(
            child: usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (users) {
                var filtered = users.where((u) {
                  final matchesSearch = _searchQuery.isEmpty ||
                      u.fullName.toLowerCase().contains(_searchQuery) ||
                      u.email.toLowerCase().contains(_searchQuery);
                  final matchesRole =
                      _filterRole == null || u.role == _filterRole;
                  return matchesSearch && matchesRole;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No users found',
                        style: TextStyle(color: AppTheme.grey500)),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _UserTile(user: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleFilterBar extends StatelessWidget {
  final UserRole? selected;
  final ValueChanged<UserRole?> onChanged;
  const _RoleFilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _FilterChip('All', null, selected, onChanged),
          const SizedBox(width: 8),
          _FilterChip('Students', UserRole.student, selected, onChanged),
          const SizedBox(width: 8),
          _FilterChip('Tutors', UserRole.tutor, selected, onChanged),
          const SizedBox(width: 8),
          _FilterChip('Admins', UserRole.admin, selected, onChanged),
        ],
      ),
    );
  }
}

Widget _FilterChip(String label, UserRole? role, UserRole? selected,
    ValueChanged<UserRole?> onChanged) {
  final isSelected = selected == role;
  return GestureDetector(
    onTap: () => onChanged(role),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor : AppTheme.grey100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : AppTheme.grey600,
          fontFamily: 'Poppins',
        ),
      ),
    ),
  );
}

class _UserTile extends ConsumerWidget {
  final UserModel user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleColor = _roleColor(user.role);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: roleColor.withOpacity(0.15),
            child: Text(
              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: roleColor,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.grey500,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _RoleBadge(role: user.role, color: roleColor),
                    const SizedBox(width: 8),
                    if (!user.isActive)
                      _Badge(
                          label: 'Suspended',
                          color: AppTheme.errorColor),
                  ],
                ),
              ],
            ),
          ),

          // Actions menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppTheme.grey400),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            onSelected: (action) => _handleAction(context, ref, action),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'view',
                child: Row(children: [
                  Icon(Icons.visibility_outlined, size: 18),
                  SizedBox(width: 10),
                  Text('View Profile'),
                ]),
              ),
              PopupMenuItem(
                value: 'toggle',
                child: Row(children: [
                  Icon(
                    user.isActive
                        ? Icons.block_rounded
                        : Icons.check_circle_outline,
                    size: 18,
                    color: user.isActive
                        ? AppTheme.errorColor
                        : AppTheme.successColor,
                  ),
                  const SizedBox(width: 10),
                  Text(user.isActive ? 'Suspend' : 'Activate'),
                ]),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline_rounded,
                      size: 18, color: AppTheme.errorColor),
                  SizedBox(width: 10),
                  Text('Delete',
                      style: TextStyle(color: AppTheme.errorColor)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(
      BuildContext context, WidgetRef ref, String action) async {
    final firestore = ref.read(firestoreProvider);
    switch (action) {
      case 'toggle':
        await firestore
            .collection(AppConstants.usersCollection)
            .doc(user.id)
            .update({'isActive': !user.isActive});
        break;
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete User'),
            content: Text('Delete ${user.fullName}? This is permanent.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await firestore
              .collection(AppConstants.usersCollection)
              .doc(user.id)
              .delete();
        }
        break;
    }
  }

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppTheme.accentColor;
      case UserRole.tutor:
        return AppTheme.secondaryColor;
      default:
        return AppTheme.primaryColor;
    }
  }
}

class _RoleBadge extends StatelessWidget {
  final UserRole role;
  final Color color;
  const _RoleBadge({required this.role, required this.color});

  @override
  Widget build(BuildContext context) {
    return _Badge(
      label: role.name[0].toUpperCase() + role.name.substring(1),
      color: color,
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}
