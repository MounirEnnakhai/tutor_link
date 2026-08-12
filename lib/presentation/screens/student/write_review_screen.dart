import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tutor_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class WriteReviewScreen extends ConsumerStatefulWidget {
  final String tutorId;
  const WriteReviewScreen({super.key, required this.tutorId});

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentCtrl = TextEditingController();
  double _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final user = ref.read(currentUserProvider)!;
      final firestore = ref.read(firestoreProvider);

      // Save review
      final reviewRef = await firestore
          .collection(AppConstants.reviewsCollection)
          .add({
        'tutorId': widget.tutorId,
        'studentId': user.id,
        'studentName': user.fullName,
        'studentPhotoUrl': user.photoUrl,
        'rating': _rating,
        'comment': _commentCtrl.text.trim(),
        'isVisible': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update tutor rating (transaction)
      await firestore.runTransaction((tx) async {
        final tutorRef = firestore
            .collection(AppConstants.tutorsCollection)
            .doc(widget.tutorId);
        final tutorDoc = await tx.get(tutorRef);
        final data = tutorDoc.data()!;
        final totalReviews = (data['totalReviews'] as int? ?? 0) + 1;
        final currentRating = (data['rating'] as num?)?.toDouble() ?? 0.0;
        final newRating =
            ((currentRating * (totalReviews - 1)) + _rating) / totalReviews;

        tx.update(tutorRef, {
          'rating': newRating,
          'totalReviews': totalReviews,
        });
      });

      ref.invalidate(reviewsByTutorProvider(widget.tutorId));
      ref.invalidate(tutorByIdProvider(widget.tutorId));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      context.pop();
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit review: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tutorAsync = ref.watch(tutorByIdProvider(widget.tutorId));

    return Scaffold(
      appBar: AppBar(title: const Text('Write a Review')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              tutorAsync.when(
                data: (tutor) => Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                      child: Text(
                        tutor.fullName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(tutor.fullName,
                        style: Theme.of(context).textTheme.titleLarge),
                    Text(tutor.subjects.take(2).join(', '),
                        style: const TextStyle(color: AppTheme.grey500)),
                  ],
                ),
                loading: () => const SizedBox(height: 80),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 32),
              Text('Your Rating',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),

              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                itemCount: 5,
                itemSize: 48,
                glow: false,
                itemBuilder: (_, __) => const Icon(
                  Icons.star_rounded,
                  color: AppTheme.warningColor,
                ),
                onRatingUpdate: (r) => setState(() => _rating = r),
              ),

              if (_rating > 0) ...[
                const SizedBox(height: 8),
                Text(
                  _ratingLabel(_rating),
                  style: TextStyle(
                    color: AppTheme.warningColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],

              const SizedBox(height: 28),
              AppTextField(
                controller: _commentCtrl,
                label: 'Your Review',
                hintText:
                    'Share your experience with this tutor...',
                maxLines: 5,
                validator: (v) {
                  if (v == null || v.trim().length < 20) {
                    return 'Please write at least 20 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 28),
              AppButton(
                label: 'Submit Review',
                onPressed: _submit,
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _ratingLabel(double rating) {
    switch (rating.toInt()) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent!';
      default:
        return '';
    }
  }
}
