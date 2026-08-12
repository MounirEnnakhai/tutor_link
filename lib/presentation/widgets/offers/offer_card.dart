import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/offer_entity.dart';

class OfferCard extends StatelessWidget {
  final OfferEntity offer;
  const OfferCard({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.push('/offer/${offer.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.grey200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left color bar
            Container(
              width: 6,
              height: 90,
              decoration: BoxDecoration(
                gradient: offer.isGroupClass
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF7209B7), Color(0xFFF72585)],
                      )
                    : const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF4361EE), Color(0xFF4CC9F0)],
                      ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Tutor avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: offer.tutorPhotoUrl ?? '',
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _buildAvatarPlaceholder(),
                placeholder: (_, __) => _buildAvatarPlaceholder(),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      _TypeBadge(isGroup: offer.isGroupClass),
                      const SizedBox(width: 6),
                      _SubjectChip(subject: offer.subject),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offer.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    offer.tutorName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.grey500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),

            // Price
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${offer.displayPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    'MAD${offer.priceLabel}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.grey400,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          offer.tutorName.isNotEmpty ? offer.tutorName[0].toUpperCase() : 'T',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final bool isGroup;
  const _TypeBadge({required this.isGroup});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isGroup
            ? const Color(0xFF7209B7).withOpacity(0.12)
            : AppTheme.primaryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isGroup ? 'Group' : 'Private',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isGroup ? const Color(0xFF7209B7) : AppTheme.primaryColor,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

class _SubjectChip extends StatelessWidget {
  final String subject;
  const _SubjectChip({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.grey100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        subject,
        style: const TextStyle(
          fontSize: 10,
          color: AppTheme.grey600,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
