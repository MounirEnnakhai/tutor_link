import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/student_request_entity.dart';

class StudentRequestCard extends StatelessWidget {
  final StudentRequestEntity request;
  const StudentRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Student avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.secondaryColor.withOpacity(0.15),
                  child: Text(
                    request.studentName.isNotEmpty
                        ? request.studentName[0].toUpperCase()
                        : 'S',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.studentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        _formatDate(request.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.grey400,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                // Type + Subject badges
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _Badge(
                      label: request.subject,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 4),
                    _Badge(
                      label: request.type == 'group' ? 'Group' : 'Private',
                      color: AppTheme.secondaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Title & Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
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
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Details row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                if (request.maxBudget != null) ...[
                  const Icon(Icons.attach_money_rounded,
                      size: 14, color: AppTheme.successColor),
                  Text(
                    'Max ${request.maxBudget!.toStringAsFixed(0)} MAD',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.successColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                const Icon(Icons.videocam_outlined,
                    size: 14, color: AppTheme.grey500),
                const SizedBox(width: 4),
                Text(
                  request.preferredMode,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.grey500,
                    fontFamily: 'Poppins',
                  ),
                ),
                if (request.location != null) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: AppTheme.grey500),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      request.location!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.grey500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),

          // Action button
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showContactOptions(context),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                label: const Text('Respond to Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
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
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppTheme.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Respond to ${request.studentName.split(' ').first}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '"${request.title}"',
              style: const TextStyle(
                color: AppTheme.grey500,
                fontSize: 13,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // In a real app, this would open an in-app chat
            // For now we show a message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppTheme.primaryColor, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'In-app messaging is coming soon!\nFor now, create an offer matching this request.',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/tutor/offers/create');
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create a Matching Offer'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
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
        color: color.withOpacity(0.1),
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