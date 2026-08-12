import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

// ─── Platform stats provider ─────────────────────────────────────────────────
final platformStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final firestore = ref.read(firestoreProvider);

  final results = await Future.wait([
    firestore.collection(AppConstants.usersCollection).count().get(),
    firestore.collection(AppConstants.tutorsCollection).count().get(),
    firestore.collection(AppConstants.offersCollection)
        .where('status', isEqualTo: 'active')
        .count()
        .get(),
    firestore.collection(AppConstants.reviewsCollection).count().get(),
    firestore.collection(AppConstants.verificationRequestsCollection)
        .where('status', isEqualTo: 'pending')
        .count()
        .get(),
  ]);

  return {
    'users': results[0].count ?? 0,
    'tutors': results[1].count ?? 0,
    'activeOffers': results[2].count ?? 0,
    'reviews': results[3].count ?? 0,
    'pendingVerifications': results[4].count ?? 0,
  };
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(platformStatsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppTheme.grey50,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Admin Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Welcome, ${user?.fullName.split(' ').first ?? 'Admin'}',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 14,
                              fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                onPressed: () async {
                  await ref.read(authNotifierProvider.notifier).signOut();
                  if (context.mounted) context.go(AppRoutes.login);
                },
              ),
            ],
          ),

          // Stats grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: statsAsync.when(
                loading: () => const _StatsShimmer(),
                error: (e, _) => Text('Error: $e'),
                data: (stats) => _StatsGrid(stats: stats),
              ),
            ),
          ),

          // Quick actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Actions',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _AdminActionsGrid(),
                ],
              ),
            ),
          ),

          // Pending verifications alert
          statsAsync.when(
            data: (stats) {
              final pending = stats['pendingVerifications'] ?? 0;
              if (pending == 0) return const SliverToBoxAdapter(child: SizedBox.shrink());
              return SliverToBoxAdapter(
                child: _PendingAlert(count: pending),
              );
            },
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // Activity chart
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _ActivityChart(),
            ),
          ),

          // Recent actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _RecentActivity(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final Map<String, int> stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem('Total Users', stats['users'] ?? 0, Icons.people_rounded,
          AppTheme.primaryColor),
      _StatItem('Tutors', stats['tutors'] ?? 0, Icons.cast_for_education_rounded,
          AppTheme.secondaryColor),
      _StatItem('Active Offers', stats['activeOffers'] ?? 0,
          Icons.local_offer_rounded, AppTheme.successColor),
      _StatItem('Reviews', stats['reviews'] ?? 0, Icons.star_rounded,
          AppTheme.warningColor),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: items.map((item) => _StatCard(item: item)).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final _StatItem item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.value}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: item.color,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                item.label,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.grey500,
                    fontFamily: 'Poppins'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _StatItem(this.label, this.value, this.icon, this.color);
}

class _AdminActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action('Users', Icons.manage_accounts_rounded, AppTheme.primaryColor,
          AppRoutes.userManagement),
      _Action('Verify Tutors', Icons.verified_user_rounded, AppTheme.successColor,
          AppRoutes.verification),
      _Action('Moderation', Icons.shield_rounded, AppTheme.warningColor, null),
      _Action('Reports', Icons.bar_chart_rounded, AppTheme.secondaryColor, null),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.85,
      children: actions.map((a) => _ActionTile(action: a)).toList(),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final _Action action;
  const _ActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (action.route != null) context.push(action.route!);
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: action.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(action.icon, color: action.color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            action.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }
}

class _Action {
  final String label;
  final IconData icon;
  final Color color;
  final String? route;
  const _Action(this.label, this.icon, this.color, this.route);
}

class _PendingAlert extends StatelessWidget {
  final int count;
  const _PendingAlert({required this.count});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.verification),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.warningColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.warningColor.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.pending_actions_rounded,
                color: AppTheme.warningColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$count tutor verification${count > 1 ? 's' : ''} pending review',
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    fontSize: 13),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppTheme.grey400),
          ],
        ),
      ),
    );
  }
}

class _ActivityChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Placeholder data – replace with real Firestore aggregation
    final spots = [
      FlSpot(0, 12),
      FlSpot(1, 18),
      FlSpot(2, 15),
      FlSpot(3, 25),
      FlSpot(4, 22),
      FlSpot(5, 30),
      FlSpot(6, 28),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('New Registrations',
                  style: Theme.of(context).textTheme.titleSmall),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Last 7 days',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins')),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, meta) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        return Text(
                          days[v.toInt()],
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.grey400,
                              fontFamily: 'Poppins'),
                        );
                      },
                      interval: 1,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 2.5,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryColor.withOpacity(0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final activities = [
      _ActivityEntry('New tutor registered', 'Ahmed El Mansouri', '2 min ago',
          Icons.person_add_rounded, AppTheme.primaryColor),
      _ActivityEntry('Review flagged', 'Report from student', '15 min ago',
          Icons.flag_rounded, AppTheme.errorColor),
      _ActivityEntry('Offer published', 'Advanced Math – Rabat', '1h ago',
          Icons.local_offer_rounded, AppTheme.successColor),
      _ActivityEntry('Verification request', 'Fatima Zahra B.', '3h ago',
          Icons.verified_user_rounded, AppTheme.warningColor),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          ...activities.asMap().entries.map((e) => Column(
                children: [
                  _ActivityRow(entry: e.value),
                  if (e.key < activities.length - 1)
                    const Divider(height: 16, indent: 44),
                ],
              )),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final _ActivityEntry entry;
  const _ActivityRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: entry.color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(entry.icon, size: 16, color: entry.color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      fontFamily: 'Poppins')),
              Text(entry.subtitle,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.grey500,
                      fontFamily: 'Poppins')),
            ],
          ),
        ),
        Text(entry.time,
            style: const TextStyle(
                fontSize: 10,
                color: AppTheme.grey400,
                fontFamily: 'Poppins')),
      ],
    );
  }
}

class _ActivityEntry {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
  const _ActivityEntry(
      this.title, this.subtitle, this.time, this.icon, this.color);
}

class _StatsShimmer extends StatelessWidget {
  const _StatsShimmer();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: List.generate(
        4,
        (_) => Container(
          decoration: BoxDecoration(
            color: AppTheme.grey100,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
