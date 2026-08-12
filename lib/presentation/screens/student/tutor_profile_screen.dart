import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/offer_entity.dart';
import '../../../domain/entities/review_entity.dart';
import '../../../domain/entities/tutor_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tutor_provider.dart';
import '../../widgets/common/shimmer_loading.dart';
import '../../widgets/offers/offer_card.dart';

class TutorProfileScreen extends ConsumerStatefulWidget {
  final String tutorId;
  const TutorProfileScreen({super.key, required this.tutorId});

  @override
  ConsumerState<TutorProfileScreen> createState() => _TutorProfileScreenState();
}

class _TutorProfileScreenState extends ConsumerState<TutorProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite(String tutorId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final firestore = ref.read(firestoreProvider);
    final col = firestore.collection('favorites');

    final existing = await col
        .where('studentId', isEqualTo: user.id)
        .where('tutorId', isEqualTo: tutorId)
        .get();

    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.delete();
    } else {
      await col.add({'studentId': user.id, 'tutorId': tutorId});
    }

    ref.invalidate(favoriteTutorIdsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final tutorAsync = ref.watch(tutorByIdProvider(widget.tutorId));
    final offersAsync = ref.watch(offersByTutorProvider(widget.tutorId));
    final reviewsAsync = ref.watch(reviewsByTutorProvider(widget.tutorId));
    final favoriteIds = ref.watch(favoriteTutorIdsProvider).valueOrNull ?? [];
    final isFavorite = favoriteIds.contains(widget.tutorId);

    return Scaffold(
      body: tutorAsync.when(
        loading: () => const _LoadingState(),
        error: (e, _) => _ErrorState(message: e.toString()),
        data: (tutor) => _buildBody(tutor, offersAsync, reviewsAsync, isFavorite),
      ),
    );
  }

  Widget _buildBody(
    TutorEntity tutor,
    AsyncValue<List<OfferEntity>> offersAsync,
    AsyncValue<List<ReviewEntity>> reviewsAsync,
    bool isFavorite,
  ) {
    return NestedScrollView(
      headerSliverBuilder: (context, _) => [
        _buildSliverAppBar(tutor, isFavorite),
        SliverToBoxAdapter(child: _buildTutorInfo(tutor)),
        SliverToBoxAdapter(child: _buildTabBar()),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _AboutTab(tutor: tutor),
          _OffersTab(offersAsync: offersAsync),
          _ReviewsTab(tutorId: widget.tutorId, reviewsAsync: reviewsAsync),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(TutorEntity tutor, bool isFavorite) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      stretch: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 16, color: AppTheme.grey900),
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: 18,
              color: isFavorite ? AppTheme.accentColor : AppTheme.grey700,
            ),
          ),
          onPressed: () => _toggleFavorite(tutor.id),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: CachedNetworkImage(
          imageUrl: tutor.photoUrl ?? '',
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => Container(
            decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
            child: Center(
              child: Text(
                tutor.fullName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTutorInfo(TutorEntity tutor) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + Verified
          Row(
            children: [
              Expanded(
                child: Text(
                  tutor.fullName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              if (tutor.isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.verified_rounded,
                          color: AppTheme.successColor, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),

          // Education level
          Text(
            tutor.educationLevel,
            style: const TextStyle(
                fontSize: 14, color: AppTheme.grey500, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 12),

          // Stats row
          Row(
            children: [
              _StatChip(
                icon: Icons.star_rounded,
                iconColor: AppTheme.warningColor,
                value: tutor.rating.toStringAsFixed(1),
                label: '(${tutor.totalReviews} reviews)',
              ),
              const SizedBox(width: 16),
              _StatChip(
                icon: Icons.work_rounded,
                iconColor: AppTheme.primaryColor,
                value: '${tutor.yearsOfExperience}',
                label: 'years exp.',
              ),
              const SizedBox(width: 16),
              _StatChip(
                icon: Icons.people_rounded,
                iconColor: AppTheme.secondaryColor,
                value: '${tutor.totalStudents}',
                label: 'students',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Subjects chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: tutor.subjects
                .map((s) => _SubjectTag(subject: s))
                .toList(),
          ),
          const SizedBox(height: 16),

          // Contact buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _contactTutor(tutor),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: const Text('Contact'),
                ),
              ),
              const SizedBox(width: 12),
              if (tutor.phoneNumber != null)
                OutlinedButton(
                  onPressed: () => _callTutor(tutor.phoneNumber!),
                  child: const Icon(Icons.phone_outlined, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.grey500,
        indicatorColor: AppTheme.primaryColor,
        indicatorWeight: 2.5,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        tabs: const [
          Tab(text: 'About'),
          Tab(text: 'Offers'),
          Tab(text: 'Reviews'),
        ],
      ),
    );
  }

  void _contactTutor(TutorEntity tutor) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ContactBottomSheet(tutor: tutor),
    );
  }

  void _callTutor(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }
}

class _AboutTab extends StatelessWidget {
  final TutorEntity tutor;
  const _AboutTab({required this.tutor});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionTitle('Biography'),
        const SizedBox(height: 8),
        Text(tutor.biography, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 20),

        _SectionTitle('Qualifications'),
        const SizedBox(height: 8),
        ...tutor.qualifications.map((q) => _BulletItem(text: q)),
        const SizedBox(height: 20),

        if (tutor.certifications.isNotEmpty) ...[
          _SectionTitle('Certifications'),
          const SizedBox(height: 8),
          ...tutor.certifications.map((c) => _BulletItem(text: c)),
          const SizedBox(height: 20),
        ],

        _SectionTitle('Teaching Languages'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: tutor.teachingLanguages
              .map((l) => Chip(
                    label: Text(l),
                    avatar: const Icon(Icons.language, size: 14),
                  ))
              .toList(),
        ),
        const SizedBox(height: 20),

        _SectionTitle('Teaching Modes'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: tutor.teachingModes
              .map((m) => Chip(
                    label: Text(m),
                    avatar: Icon(
                      m.toLowerCase().contains('online')
                          ? Icons.videocam_outlined
                          : Icons.location_on_outlined,
                      size: 14,
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 20),

        if (tutor.location != null) ...[
          _SectionTitle('Location'),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 18),
              const SizedBox(width: 8),
              Text(
                '${tutor.location!.city ?? ''}, ${tutor.location!.country ?? ''}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}

class _OffersTab extends StatelessWidget {
  final AsyncValue<List<OfferEntity>> offersAsync;
  const _OffersTab({required this.offersAsync});

  @override
  Widget build(BuildContext context) {
    return offersAsync.when(
      loading: () => const ShimmerList(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (offers) {
        if (offers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 48, color: AppTheme.grey400),
                SizedBox(height: 12),
                Text('No active offers',
                    style: TextStyle(color: AppTheme.grey500)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: offers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => OfferCard(offer: offers[i]),
        );
      },
    );
  }
}

class _ReviewsTab extends ConsumerWidget {
  final String tutorId;
  final AsyncValue<List<ReviewEntity>> reviewsAsync;
  const _ReviewsTab({required this.tutorId, required this.reviewsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return reviewsAsync.when(
      loading: () => const ShimmerList(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (reviews) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (user != null)
            ElevatedButton.icon(
              onPressed: () => context.push('/review/write/$tutorId'),
              icon: const Icon(Icons.rate_review_outlined, size: 18),
              label: const Text('Write a Review'),
            ),
          const SizedBox(height: 16),
          if (reviews.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No reviews yet. Be the first!',
                    style: TextStyle(color: AppTheme.grey500)),
              ),
            )
          else
            ...reviews.map((r) => _ReviewCard(review: r)),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewEntity review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                backgroundImage: review.studentPhotoUrl != null
                    ? CachedNetworkImageProvider(review.studentPhotoUrl!)
                    : null,
                child: review.studentPhotoUrl == null
                    ? Text(
                        review.studentName[0].toUpperCase(),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.studentName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          fontFamily: 'Poppins'),
                    ),
                    Text(
                      _formatDate(review.createdAt),
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.grey400,
                          fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),
              RatingBarIndicator(
                rating: review.rating,
                itemSize: 14,
                itemBuilder: (_, __) =>
                    const Icon(Icons.star_rounded, color: AppTheme.warningColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.comment,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppTheme.grey600),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays < 1) return 'Today';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).round()}w ago';
    return '${(diff.inDays / 30).round()}mo ago';
  }
}

// ─── Helper widgets ──────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  const _StatChip(
      {required this.icon,
      required this.iconColor,
      required this.value,
      required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              fontFamily: 'Poppins'),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(
              fontSize: 11,
              color: AppTheme.grey500,
              fontFamily: 'Poppins'),
        ),
      ],
    );
  }
}

class _SubjectTag extends StatelessWidget {
  final String subject;
  const _SubjectTag({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        subject,
        style: const TextStyle(
            fontSize: 12,
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins'),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  const _BulletItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child:
                Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _ContactBottomSheet extends StatelessWidget {
  final TutorEntity tutor;
  const _ContactBottomSheet({required this.tutor});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          Text('Contact ${tutor.fullName.split(' ').first}',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          if (tutor.email != null)
            _ContactOption(
              icon: Icons.email_outlined,
              label: 'Send Email',
              value: tutor.email!,
              onTap: () async {
                final uri = Uri.parse('mailto:${tutor.email}');
                if (await canLaunchUrl(uri)) launchUrl(uri);
              },
            ),
          if (tutor.phoneNumber != null) ...[
            const SizedBox(height: 12),
            _ContactOption(
              icon: Icons.phone_outlined,
              label: 'Call Tutor',
              value: tutor.phoneNumber!,
              onTap: () async {
                final uri = Uri.parse('tel:${tutor.phoneNumber}');
                if (await canLaunchUrl(uri)) launchUrl(uri);
              },
            ),
            const SizedBox(height: 12),
            _ContactOption(
              icon: Icons.chat_outlined,
              label: 'WhatsApp',
              value: tutor.phoneNumber!,
              onTap: () async {
                final uri = Uri.parse(
                    'https://wa.me/${tutor.phoneNumber!.replaceAll('+', '').replaceAll(' ', '')}');
                if (await canLaunchUrl(uri)) launchUrl(uri);
              },
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ContactOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  const _ContactOption(
      {required this.icon,
      required this.label,
      required this.value,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.grey200),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: 'Poppins')),
                Text(value,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.grey500,
                        fontFamily: 'Poppins')),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppTheme.grey400),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text('Error: $message')),
    );
  }
}
