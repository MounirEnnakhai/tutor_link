import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/offer_entity.dart';
import '../../providers/tutor_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/shimmer_loading.dart';

class OfferDetailScreen extends ConsumerWidget {
  final String offerId;
  const OfferDetailScreen({super.key, required this.offerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerAsync = ref.watch(offerByIdProvider(offerId));

    return Scaffold(
      appBar: AppBar(title: const Text('Offer Details')),
      body: offerAsync.when(
        loading: () => const ShimmerList(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (offer) => _OfferDetailBody(offer: offer),
      ),
    );
  }
}

class _OfferDetailBody extends StatelessWidget {
  final OfferEntity offer;
  const _OfferDetailBody({required this.offer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header card — gradient, always white text, fine as-is
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: offer.isGroupClass
                ? const LinearGradient(
              colors: [Color(0xFF7209B7), Color(0xFFF72585)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _GradientBadge(
                      label: offer.isGroupClass ? 'Group Class' : 'Private Lesson'),
                  const SizedBox(width: 8),
                  _GradientBadge(label: offer.subject),
                ],
              ),
              const SizedBox(height: 16),
              Text(offer.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  )),
              const SizedBox(height: 8),
              Text(offer.tutorName,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                      fontFamily: 'Poppins')),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    '${offer.displayPrice.toStringAsFixed(0)} MAD',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(offer.priceLabel,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontFamily: 'Poppins')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text('About this offer', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(offer.description, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 20),

        _DetailSection(offer: offer),
        const SizedBox(height: 20),

        if (offer.isGroupClass && offer.classSchedule.isNotEmpty) ...[
          Text('Class Schedule', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...offer.classSchedule.map((s) => _ScheduleItem(slot: s)),
          const SizedBox(height: 20),
        ],
        if (!offer.isGroupClass && offer.availabilitySchedule.isNotEmpty) ...[
          Text('Availability', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...offer.availabilitySchedule.map((s) => _ScheduleItem(slot: s)),
          const SizedBox(height: 20),
        ],

        AppButton(
          label: 'Contact Tutor',
          icon: Icons.chat_bubble_outline_rounded,
          onPressed: () => context.push('/tutor/${offer.tutorId}'),
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'View Tutor Profile',
          isOutlined: true,
          onPressed: () => context.push('/tutor/${offer.tutorId}'),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _GradientBadge extends StatelessWidget {
  final String label;
  const _GradientBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins')),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final OfferEntity offer;
  const _DetailSection({required this.offer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = <_DetailItem>[];

    if (offer.isGroupClass) {
      if (offer.maxStudents != null) {
        items.add(_DetailItem(
          icon: Icons.group_rounded,
          label: 'Max Students',
          value: '${offer.maxStudents}',
        ));
      }
      if (offer.availableSeats != null) {
        items.add(_DetailItem(
          icon: Icons.event_seat_rounded,
          label: 'Available Seats',
          value: '${offer.availableSeats}',
          highlight: (offer.availableSeats ?? 0) < 3,
        ));
      }
      items.add(_DetailItem(
        icon: offer.isOnline == true
            ? Icons.videocam_outlined
            : Icons.location_on_outlined,
        label: 'Format',
        value: offer.isOnline == true ? 'Online' : 'In-person',
      ));
    } else {
      if (offer.teachingMode != null) {
        items.add(_DetailItem(
          icon: Icons.location_on_outlined,
          label: 'Teaching Mode',
          value: offer.teachingMode!,
        ));
      }
    }

    if (offer.location != null) {
      items.add(_DetailItem(
        icon: Icons.place_outlined,
        label: 'Location',
        value: offer.location!,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Details', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: theme.colorScheme.onSurface.withOpacity(0.12)),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                items[i],
                if (i < items.length - 1)
                  const Divider(height: 1, indent: 56),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 14),
          Text(label,
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 13,
                  fontFamily: 'Poppins')),
          const Spacer(),
          Text(value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                fontFamily: 'Poppins',
                color: highlight ? AppTheme.warningColor : null,
              )),
        ],
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final ScheduleSlot slot;
  const _ScheduleItem({required this.slot});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border:
        Border.all(color: AppTheme.primaryColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Text(slot.day,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  fontFamily: 'Poppins')),
          const Spacer(),
          Text('${slot.startTime} – ${slot.endTime}',
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 13,
                  fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}