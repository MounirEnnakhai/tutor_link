import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/tutor_entity.dart';

class TutorCard extends StatelessWidget {
  final TutorEntity tutor;
  final bool isHorizontal;

  const TutorCard({super.key, required this.tutor, this.isHorizontal = true});

  @override
  Widget build(BuildContext context) {
    return isHorizontal ? _buildHorizontal(context) : _buildVertical(context);
  }

  Widget _buildHorizontal(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.push('/tutor/${tutor.id}'),
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.grey200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo + verified badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: CachedNetworkImage(
                    imageUrl: tutor.photoUrl ?? '',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _avatarPlaceholder(),
                    placeholder: (_, __) => _avatarPlaceholder(),
                  ),
                ),
                if (tutor.isVerified)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tutor.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tutor.subjects.take(2).join(', '),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.grey500,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: tutor.rating,
                        itemSize: 12,
                        itemBuilder: (_, __) => const Icon(
                          Icons.star_rounded,
                          color: AppTheme.warningColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tutor.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '(${tutor.totalReviews})',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.grey400,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVertical(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.push('/tutor/${tutor.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(14),
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
            // Avatar
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CachedNetworkImage(
                    imageUrl: tutor.photoUrl ?? '',
                    width: 68,
                    height: 68,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _avatarPlaceholderSmall(),
                    placeholder: (_, __) => _avatarPlaceholderSmall(),
                  ),
                ),
                if (tutor.isVerified)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 8,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tutor.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tutor.subjects.take(3).join(' · '),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.grey500,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: tutor.rating,
                        itemSize: 13,
                        itemBuilder: (_, __) => const Icon(
                          Icons.star_rounded,
                          color: AppTheme.warningColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${tutor.rating.toStringAsFixed(1)} (${tutor.totalReviews})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${tutor.yearsOfExperience}y exp.',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.grey500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppTheme.grey400),
          ],
        ),
      ),
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      height: 120,
      color: AppTheme.grey100,
      child: Center(
        child: CircleAvatar(
          radius: 28,
          backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
          child: Text(
            tutor.fullName.isNotEmpty ? tutor.fullName[0].toUpperCase() : 'T',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatarPlaceholderSmall() {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          tutor.fullName.isNotEmpty ? tutor.fullName[0].toUpperCase() : 'T',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}
