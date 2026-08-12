import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/tutor_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tutor_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/shimmer_loading.dart';
import '../../widgets/tutor_card/tutor_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FAVORITES SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final favoritesAsync = ref.watch(favoriteTutorsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Tutors')),
      body: user == null
          ? const _NotLoggedIn()
          : favoritesAsync.when(
              loading: () => const ShimmerList(count: 5),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (tutors) {
                if (tutors.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border_rounded,
                            size: 64, color: AppTheme.grey300),
                        const SizedBox(height: 16),
                        Text('No saved tutors yet',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap the heart icon on tutor\nprofiles to save them here',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppTheme.grey500, fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          label: 'Browse Tutors',
                          onPressed: () => context.push('/student/search'),
                          width: 180,
                          height: 44,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: tutors.length,
                  itemBuilder: (_, i) =>
                      TutorCard(tutor: tutors[i], isHorizontal: false),
                );
              },
            ),
    );
  }
}

class _NotLoggedIn extends StatelessWidget {
  const _NotLoggedIn();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 48, color: AppTheme.grey400),
          const SizedBox(height: 16),
          const Text('Sign in to see your favorites'),
          const SizedBox(height: 16),
          AppButton(
            label: 'Sign In',
            width: 160,
            height: 44,
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
    );
  }
}
