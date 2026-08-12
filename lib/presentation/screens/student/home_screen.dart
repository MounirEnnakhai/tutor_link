import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/offer_entity.dart';
import '../../../domain/entities/tutor_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tutor_provider.dart';
import '../../widgets/common/shimmer_loading.dart';
import '../../widgets/tutor_card/tutor_card.dart';
import '../../widgets/offers/offer_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedNavIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.search_rounded, label: 'Search'),
    _NavItem(icon: Icons.map_rounded, label: 'Map'),
    _NavItem(icon: Icons.favorite_rounded, label: 'Favorites'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  void _onNavTap(int index) {
    setState(() => _selectedNavIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        context.push(AppRoutes.search);
        break;
      case 2:
        context.push(AppRoutes.map);
        break;
      case 3:
        context.push(AppRoutes.favorites);
        break;
      case 4:
        context.push(AppRoutes.studentProfile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const _HomeBody(),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createRequest),
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('Post a Request'),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }

  Widget _buildBottomNav() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
                  (i) => _NavBarItem(
                item: _navItems[i],
                isSelected: _selectedNavIndex == i,
                onTap: () => _onNavTap(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final featuredTutors = ref.watch(featuredTutorsProvider);
    final featuredOffers = ref.watch(featuredOffersProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context, user?.fullName)),
        SliverToBoxAdapter(child: _buildPostRequestBanner(context)),
        SliverToBoxAdapter(child: _buildCategories(context)),
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: 'Top Tutors',
            onSeeAll: () => context.push(AppRoutes.search),
          ),
        ),
        SliverToBoxAdapter(
          child: featuredTutors.when(
            data: (tutors) => _TutorCarousel(tutors: tutors),
            loading: () => _ShimmerCarousel(),
            error: (_, __) => const _ErrorWidget(),
          ),
        ),
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: 'Latest Offers',
            onSeeAll: () => context.push(AppRoutes.search),
          ),
        ),
        featuredOffers.when(
          data: (offers) => SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: OfferCard(offer: offers[i]),
              ),
              childCount: offers.length,
            ),
          ),
          loading: () =>
          const SliverToBoxAdapter(child: ShimmerLoading()),
          error: (_, __) =>
          const SliverToBoxAdapter(child: _ErrorWidget()),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildPostRequestBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.createRequest),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7209B7), Color(0xFFF72585)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.edit_note_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Can\'t find a tutor?',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    'Post a request — tutors will contact you!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white70, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String? name) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${name?.split(' ').first ?? 'there'} 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Find your perfect tutor today',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_outlined,
                          color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => context.push(AppRoutes.search),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppTheme.grey400),
                      const SizedBox(width: 12),
                      Text(
                        'Search tutors, subjects...',
                        style: TextStyle(
                          color: AppTheme.grey400,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.tune_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = [
      _Category('Math', Icons.calculate_rounded, const Color(0xFF4361EE)),
      _Category('Physics', Icons.science_rounded, const Color(0xFF7209B7)),
      _Category('Chemistry', Icons.biotech_rounded, const Color(0xFF3A0CA3)),
      _Category('Biology', Icons.eco_rounded, const Color(0xFF06D6A0)),
      _Category('English', Icons.translate_rounded, const Color(0xFFFFB703)),
      _Category('French', Icons.language_rounded, const Color(0xFFF72585)),
      _Category('CS', Icons.computer_rounded, const Color(0xFF4CC9F0)),
      _Category('Economics', Icons.bar_chart_rounded, const Color(0xFF2EC4B6)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Categories'),
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _CategoryChip(category: categories[i]),
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final _Category category;
  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        '${AppRoutes.search}?subject=${Uri.encodeComponent(category.label)}',
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(category.icon, color: category.color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            category.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _Category {
  final String label;
  final IconData icon;
  final Color color;
  const _Category(this.label, this.icon, this.color);
}

class _TutorCarousel extends StatelessWidget {
  final List<TutorEntity> tutors;
  const _TutorCarousel({required this.tutors});

  @override
  Widget build(BuildContext context) {
    if (tutors.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('No tutors available yet')),
      );
    }
    return SizedBox(
      height: 220,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: tutors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => TutorCard(tutor: tutors[i]),
      ),
    );
  }
}

class _ShimmerCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) =>
        const ShimmerLoading(width: 170, height: 210),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: const Text('See all')),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(child: Text('Failed to load. Pull to refresh.')),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _NavBarItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color:
              isSelected ? AppTheme.primaryColor : AppTheme.grey400,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.grey400,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}