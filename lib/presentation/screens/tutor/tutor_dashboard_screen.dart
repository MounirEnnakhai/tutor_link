import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tutor_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/shimmer_loading.dart';
import '../../widgets/common/student_request_card.dart';
import '../../widgets/offers/offer_card.dart';

class TutorDashboardScreen extends ConsumerStatefulWidget {
  const TutorDashboardScreen({super.key});

  @override
  ConsumerState<TutorDashboardScreen> createState() =>
      _TutorDashboardScreenState();
}

class _TutorDashboardScreenState extends ConsumerState<TutorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final tutorAsync = ref.watch(currentTutorProfileProvider);

    return Scaffold(
      body: tutorAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tutor) => NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              collapsedHeight: 60,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 56),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor:
                                Colors.white.withOpacity(0.2),
                                child: Text(
                                  user?.fullName[0].toUpperCase() ?? 'T',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user?.fullName ?? 'Tutor',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    if (tutor != null)
                                      _VerificationBadge(
                                          status: tutor.verificationStatus),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.settings_outlined,
                                    color: Colors.white),
                                onPressed: () => context
                                    .push(AppRoutes.tutorProfileEdit),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (tutor != null)
                            Row(
                              children: [
                                _DashStat(
                                    label: 'Rating',
                                    value: tutor.rating
                                        .toStringAsFixed(1)),
                                _DashStat(
                                    label: 'Reviews',
                                    value: '${tutor.totalReviews}'),
                                _DashStat(
                                    label: 'Students',
                                    value: '${tutor.totalStudents}'),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  tooltip: 'Sign Out',
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Sign Out'),
                        content: const Text(
                            'Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.errorColor,
                            ),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      await ref
                          .read(authNotifierProvider.notifier)
                          .signOut();
                      context.go(AppRoutes.login);
                    }
                  },
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                indicatorColor: Colors.white,
                indicatorWeight: 2.5,
                labelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(text: 'My Offers'),
                  Tab(text: 'Student Requests'),
                ],
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _MyOffersTab(tutor: tutor),
              const _StudentRequestsTab(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createOffer),
        icon: const Icon(Icons.add),
        label: const Text('New Offer'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}

// ─── Tab 1: My Offers ─────────────────────────────────────────────────────────

class _MyOffersTab extends ConsumerWidget {
  final dynamic tutor;
  const _MyOffersTab({required this.tutor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tutor == null) {
      return const Center(child: Text('Complete your profile first'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Quick Actions',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.add_circle_outline_rounded,
                label: 'New Offer',
                color: AppTheme.primaryColor,
                onTap: () => context.push(AppRoutes.createOffer),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickAction(
                icon: Icons.list_alt_rounded,
                label: 'Manage',
                color: AppTheme.secondaryColor,
                onTap: () => context.push(AppRoutes.manageOffers),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickAction(
                icon: Icons.verified_user_outlined,
                label: 'Verify',
                color: AppTheme.successColor,
                onTap: () => context.push(AppRoutes.tutorProfileEdit),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickAction(
                icon: Icons.edit_outlined,
                label: 'Profile',
                color: AppTheme.warningColor,
                onTap: () => context.push(AppRoutes.tutorProfileEdit),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        if (tutor.biography.isEmpty || tutor.subjects.isEmpty)
          _ProfileCompletenessCard(tutor: tutor),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Active Offers',
                style: Theme.of(context).textTheme.titleMedium),
            TextButton(
              onPressed: () => context.push(AppRoutes.manageOffers),
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _OffersWidget(tutorId: tutor.id),
      ],
    );
  }
}

class _OffersWidget extends ConsumerWidget {
  final String tutorId;
  const _OffersWidget({required this.tutorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(offersByTutorProvider(tutorId));
    return offersAsync.when(
      loading: () => const ShimmerList(count: 3),
      error: (e, _) => Text('Error: $e'),
      data: (offers) {
        if (offers.isEmpty) {
          return Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.inbox_outlined,
                    size: 48, color: AppTheme.grey300),
                const SizedBox(height: 12),
                const Text('No offers yet',
                    style: TextStyle(color: AppTheme.grey500)),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Create your first offer',
                  onPressed: () => context.push(AppRoutes.createOffer),
                  height: 42,
                ),
              ],
            ),
          );
        }
        return Column(
          children: offers
              .take(5)
              .map((o) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OfferCard(offer: o),
          ))
              .toList(),
        );
      },
    );
  }
}

// ─── Tab 2: Student Requests ──────────────────────────────────────────────────

class _StudentRequestsTab extends ConsumerWidget {
  const _StudentRequestsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(studentRequestsProvider);

    return requestsAsync.when(
      loading: () => const ShimmerList(count: 5),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined,
                    size: 64,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.3)),
                const SizedBox(height: 16),
                Text('No student requests yet',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'When students post learning requests\nthey will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                      fontFamily: 'Poppins'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(studentRequestsProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) =>
                StudentRequestCard(request: requests[i]),
          ),
        );
      },
    );
  }
}

// ─── Helper widgets ───────────────────────────────────────────────────────────

class _DashStat extends StatelessWidget {
  final String label;
  final String value;
  const _DashStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins')),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 11,
                  fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontFamily: 'Poppins')),
          ],
        ),
      ),
    );
  }
}

class _ProfileCompletenessCard extends StatelessWidget {
  final dynamic tutor;
  const _ProfileCompletenessCard({required this.tutor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border:
        Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppTheme.warningColor, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Complete your profile to attract more students.',
              style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: () =>
                context.push(AppRoutes.tutorProfileEdit),
            child:
            const Text('Complete', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  final dynamic status;
  const _VerificationBadge({required this.status});

  String get _statusString {
    if (status == null) return 'notSubmitted';
    try {
      return status.name as String;
    } catch (_) {
      return status.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _statusString;
    final label = s == 'verified'
        ? '✓ Verified'
        : s == 'pending'
        ? '⏳ Pending'
        : 'Not Verified';
    final color = s == 'verified'
        ? AppTheme.successColor
        : s == 'pending'
        ? AppTheme.warningColor
        : AppTheme.grey400;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins'),
      ),
    );
  }
}