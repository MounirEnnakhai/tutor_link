import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tutor_provider.dart';

class _VerificationRequest {
  final String id;
  final String tutorId;
  final String tutorName;
  final List<String> documents;
  final String status;
  final DateTime createdAt;

  const _VerificationRequest({
    required this.id,
    required this.tutorId,
    required this.tutorName,
    required this.documents,
    required this.status,
    required this.createdAt,
  });
}

final verificationRequestsProvider =
    StreamProvider<List<_VerificationRequest>>((ref) {
  final firestore = ref.read(firestoreProvider);
  return firestore
      .collection(AppConstants.verificationRequestsCollection)
      .where('status', isEqualTo: 'pending')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .asyncMap((snap) async {
    final requests = <_VerificationRequest>[];
    for (final doc in snap.docs) {
      final data = doc.data();
      // Fetch tutor name
      String tutorName = 'Unknown';
      try {
        final tutorDoc = await firestore
            .collection(AppConstants.tutorsCollection)
            .doc(data['tutorId'])
            .get();
        if (tutorDoc.exists) {
          tutorName = tutorDoc.data()?['fullName'] ?? 'Unknown';
        }
      } catch (_) {}

      requests.add(_VerificationRequest(
        id: doc.id,
        tutorId: data['tutorId'] ?? '',
        tutorName: tutorName,
        documents: List<String>.from(data['documents'] ?? []),
        status: data['status'] ?? 'pending',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ));
    }
    return requests;
  });
});

class VerificationScreen extends ConsumerWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(verificationRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutor Verification'),
      ),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified_rounded,
                      size: 72, color: AppTheme.successColor),
                  const SizedBox(height: 16),
                  Text(
                    'All caught up!',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No pending verification requests.',
                    style: TextStyle(
                        color: AppTheme.grey500, fontFamily: 'Poppins'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _PendingBanner(count: requests.length),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) =>
                      _VerificationCard(request: requests[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PendingBanner extends StatelessWidget {
  final int count;
  const _PendingBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: AppTheme.warningColor.withOpacity(0.1),
      child: Text(
        '$count pending verification${count > 1 ? 's' : ''}',
        style: const TextStyle(
          color: AppTheme.warningColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

class _VerificationCard extends ConsumerStatefulWidget {
  final _VerificationRequest request;
  const _VerificationCard({required this.request});

  @override
  ConsumerState<_VerificationCard> createState() => _VerificationCardState();
}

class _VerificationCardState extends ConsumerState<_VerificationCard> {
  bool _isProcessing = false;

  Future<void> _approve() async {
    setState(() => _isProcessing = true);
    try {
      final firestore = ref.read(firestoreProvider);

      // Update verification request
      await firestore
          .collection(AppConstants.verificationRequestsCollection)
          .doc(widget.request.id)
          .update({
        'status': 'approved',
        'reviewedAt': FieldValue.serverTimestamp(),
      });

      // Update tutor profile
      await firestore
          .collection(AppConstants.tutorsCollection)
          .doc(widget.request.tutorId)
          .update({'verificationStatus': 'verified'});

      ref.invalidate(verificationRequestsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.request.tutorName} approved!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _reject() async {
    final reason = await _showRejectDialog();
    if (reason == null) return;

    setState(() => _isProcessing = true);
    try {
      final firestore = ref.read(firestoreProvider);

      await firestore
          .collection(AppConstants.verificationRequestsCollection)
          .doc(widget.request.id)
          .update({
        'status': 'rejected',
        'rejectionReason': reason,
        'reviewedAt': FieldValue.serverTimestamp(),
      });

      await firestore
          .collection(AppConstants.tutorsCollection)
          .doc(widget.request.tutorId)
          .update({'verificationStatus': 'rejected'});

      ref.invalidate(verificationRequestsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request rejected.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<String?> _showRejectDialog() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g., Documents unclear or insufficient...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.12),
                  child: Text(
                    widget.request.tutorName[0].toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.request.tutorName,
                          style: theme.textTheme.titleSmall),
                      Text(
                        'Submitted ${_formatDate(widget.request.createdAt)}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.grey400,
                            fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                        color: AppTheme.warningColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),

          // Documents
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.request.documents.length} document(s) submitted',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 8),
                ...widget.request.documents.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.description_outlined,
                                size: 16, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'Document ${e.key + 1}',
                              style: const TextStyle(
                                  fontSize: 12, fontFamily: 'Poppins'),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                              ),
                              child: const Text('View',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(14),
            child: _isProcessing
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _reject,
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorColor,
                            side: const BorderSide(color: AppTheme.errorColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _approve,
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successColor,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
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
