import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/offer_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tutor_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/shimmer_loading.dart';

class ManageOffersScreen extends ConsumerWidget {
  const ManageOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutor = ref.watch(currentTutorProfileProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Offers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => context.push(AppRoutes.createOffer),
          ),
        ],
      ),
      body: tutor == null
          ? const Center(child: CircularProgressIndicator())
          : _OffersList(tutorId: tutor.id),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createOffer),
        icon: const Icon(Icons.add),
        label: const Text('New Offer'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}

class _OffersList extends ConsumerWidget {
  final String tutorId;
  const _OffersList({required this.tutorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(offersByTutorProvider(tutorId));
    final theme = Theme.of(context);

    return offersAsync.when(
      loading: () => const ShimmerList(count: 5),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (offers) {
        if (offers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.post_add_rounded,
                    size: 72,
                    color: theme.colorScheme.onSurface.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text('No offers yet', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Create your first offer to\nstart connecting with students.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Create Offer',
                  width: 180,
                  height: 44,
                  icon: Icons.add,
                  onPressed: () => context.push(AppRoutes.createOffer),
                ),
              ],
            ),
          );
        }

        final private =
        offers.where((o) => o.type == OfferType.privateLesson).toList();
        final group =
        offers.where((o) => o.type == OfferType.groupClass).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (private.isNotEmpty) ...[
              _SectionHeader(
                title: 'Private Lessons',
                count: private.length,
                icon: Icons.person_outline,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 8),
              ...private.map((o) => _ManageOfferCard(offer: o)),
              const SizedBox(height: 16),
            ],
            if (group.isNotEmpty) ...[
              _SectionHeader(
                title: 'Group Classes',
                count: group.length,
                icon: Icons.group_outlined,
                color: AppTheme.secondaryColor,
              ),
              const SizedBox(height: 8),
              ...group.map((o) => _ManageOfferCard(offer: o)),
            ],
            const SizedBox(height: 80),
          ],
        );
      },
    );
  }
}

class _ManageOfferCard extends ConsumerWidget {
  final OfferEntity offer;
  const _ManageOfferCard({required this.offer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isActive = offer.status == OfferStatus.active;
    final borderColor = theme.colorScheme.onSurface.withOpacity(0.12);

    return Dismissible(
      key: Key(offer.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('Delete',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    fontFamily: 'Poppins')),
          ],
        ),
      ),
      confirmDismiss: (direction) => _confirmDelete(context),
      onDismissed: (_) => _deleteOffer(context, ref),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isActive
                          ? (offer.isGroupClass
                          ? AppTheme.secondaryColor
                          : AppTheme.primaryColor)
                          : theme.colorScheme.onSurface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                offer.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: isActive
                                      ? null
                                      : theme.colorScheme.onSurface
                                      .withOpacity(0.4),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _StatusBadge(isActive: isActive),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _TagChip(
                                label: offer.subject,
                                color: AppTheme.primaryColor),
                            const SizedBox(width: 6),
                            _TagChip(
                                label: offer.isGroupClass ? 'Group' : 'Private',
                                color: AppTheme.secondaryColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
              child: Row(
                children: [
                  Text(
                    '${offer.displayPrice.toStringAsFixed(0)} MAD${offer.priceLabel}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: isActive
                          ? AppTheme.primaryColor
                          : theme.colorScheme.onSurface.withOpacity(0.4),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: isActive ? 'Pause' : 'Activate',
                    icon: Icon(
                      isActive
                          ? Icons.pause_circle_outline_rounded
                          : Icons.play_circle_outline_rounded,
                      color: isActive
                          ? AppTheme.warningColor
                          : AppTheme.successColor,
                    ),
                    onPressed: () => _toggleStatus(context, ref),
                  ),
                  IconButton(
                    tooltip: 'Edit',
                    icon: Icon(Icons.edit_outlined,
                        color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    onPressed: () => context.push(
                        '${AppRoutes.createOffer}?offerId=${offer.id}'),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppTheme.errorColor),
                    onPressed: () async {
                      final confirmed = await _confirmDelete(context);
                      if (confirmed == true && context.mounted) {
                        _deleteOffer(context, ref);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Offer'),
        content: Text(
            'Are you sure you want to delete "${offer.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteOffer(BuildContext context, WidgetRef ref) async {
    try {
      final firestore = ref.read(firestoreProvider);
      await firestore
          .collection(AppConstants.offersCollection)
          .doc(offer.id)
          .update({'status': 'deleted'});
      ref.invalidate(offersByTutorProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Offer deleted'),
              backgroundColor: AppTheme.errorColor),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _toggleStatus(BuildContext context, WidgetRef ref) async {
    try {
      final newStatus =
      offer.status == OfferStatus.active ? 'paused' : 'active';
      final firestore = ref.read(firestoreProvider);
      await firestore
          .collection(AppConstants.offersCollection)
          .doc(offer.id)
          .update({'status': newStatus});
      ref.invalidate(offersByTutorProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('$count',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontFamily: 'Poppins')),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.successColor.withOpacity(0.12)
            : theme.colorScheme.onSurface.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.successColor
                  : theme.colorScheme.onSurface.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Active' : 'Paused',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? AppTheme.successColor
                  : theme.colorScheme.onSurface.withOpacity(0.5),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;
  const _TagChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins')),
    );
  }
}