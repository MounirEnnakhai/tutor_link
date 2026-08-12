import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/student_request_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tutor_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/shimmer_loading.dart';

class MyRequestsScreen extends ConsumerWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final requestsAsync = ref.watch(myRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => context.push(AppRoutes.createRequest),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Please sign in'))
          : requestsAsync.when(
        loading: () => const ShimmerList(count: 4),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_note_rounded,
                      size: 72, color: AppTheme.grey300),
                  const SizedBox(height: 16),
                  Text('No requests yet',
                      style:
                      Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text(
                    'Post a learning request and let\ntutors come to you!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppTheme.grey500,
                        fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Post a Request',
                    width: 200,
                    height: 44,
                    icon: Icons.add,
                    onPressed: () =>
                        context.push(AppRoutes.createRequest),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(myRequestsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 10),
              itemBuilder: (_, i) =>
                  _MyRequestCard(request: requests[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createRequest),
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }
}

class _MyRequestCard extends ConsumerWidget {
  final StudentRequestEntity request;
  const _MyRequestCard({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = request.isOpen;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOpen
              ? AppTheme.successColor.withOpacity(0.3)
              : AppTheme.grey200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOpen
                      ? AppTheme.successColor.withOpacity(0.12)
                      : AppTheme.grey200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isOpen
                            ? AppTheme.successColor
                            : AppTheme.grey400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOpen ? 'Open' : 'Closed',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isOpen
                            ? AppTheme.successColor
                            : AppTheme.grey400,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            request.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.grey500,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _InfoChip(
                  icon: Icons.book_outlined, label: request.subject),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.person_outline,
                label: request.type == 'group' ? 'Group' : 'Private',
              ),
              if (request.maxBudget != null) ...[
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.attach_money_rounded,
                  label: '${request.maxBudget!.toStringAsFixed(0)} MAD',
                  color: AppTheme.successColor,
                ),
              ],
            ],
          ),
          if (isOpen) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _closeRequest(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: const BorderSide(color: AppTheme.errorColor),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Close Request',
                        style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _closeRequest(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Close Request'),
        content: const Text(
            'Mark this request as closed? Tutors won\'t see it anymore.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Close it'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final firestore = ref.read(firestoreProvider);
      await firestore
          .collection('student_requests')
          .doc(request.id)
          .update({'status': 'closed'});
      ref.invalidate(myRequestsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({
    required this.icon,
    required this.label,
    this.color = AppTheme.grey500,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}