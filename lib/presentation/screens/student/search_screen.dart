import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/review_entity.dart';
import '../../providers/tutor_provider.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/shimmer_loading.dart';
import '../../widgets/tutor_card/tutor_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialSubject;
  const SearchScreen({super.key, this.initialSubject});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchCtrl = TextEditingController();
  SearchFilter _filter = const SearchFilter();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialSubject != null) {
      _filter = _filter.copyWith(subject: widget.initialSubject);
      _searchCtrl.text = widget.initialSubject!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _doSearch());
    }
  }

  void _doSearch() {
    final query = _searchCtrl.text.trim();
    final filter = query.isNotEmpty
        ? _filter.copyWith(subject: query)
        : _filter;
    ref.read(searchNotifierProvider.notifier).search(filter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Tutors'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: _showFilters ? AppTheme.primaryColor : null,
            ),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onSubmitted: (_) => _doSearch(),
                    decoration: InputDecoration(
                      hintText: 'Search subject or tutor name...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.grey400),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                ref.read(searchNotifierProvider.notifier).clear();
                              },
                            )
                          : null,
                    ),
                    onChanged: (v) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _doSearch,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Search'),
                ),
              ],
            ),
          ),

          // Filters panel
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(key: ValueKey('hidden')),
            secondChild: _FilterPanel(
              key: const ValueKey('filters'),
              filter: _filter,
              onChanged: (f) {
                setState(() => _filter = f);
                _doSearch();
              },
            ),
            crossFadeState: _showFilters
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),

          // Active filter chips
          if (!_filter.isEmpty)
            _ActiveFilters(
              filter: _filter,
              onClearAll: () {
                setState(() => _filter = const SearchFilter());
                _doSearch();
              },
            ),

          const Divider(height: 1),

          // Results
          Expanded(
            child: searchResults.when(
              data: (tutors) {
                if (tutors.isEmpty) {
                  return const _EmptyResults();
                }
                return ListView.builder(
                  itemCount: tutors.length,
                  itemBuilder: (_, i) =>
                      TutorCard(tutor: tutors[i], isHorizontal: false),
                );
              },
              loading: () => ListView.builder(
                itemCount: 6,
                itemBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: ShimmerLoading(height: 100),
                ),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPanel extends StatefulWidget {
  final SearchFilter filter;
  final ValueChanged<SearchFilter> onChanged;
  const _FilterPanel({super.key, required this.filter, required this.onChanged});

  @override
  State<_FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<_FilterPanel> {
  late SearchFilter _localFilter;

  @override
  void initState() {
    super.initState();
    _localFilter = widget.filter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject filter
          const Text('Subject',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: AppConstants.subjects.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final s = AppConstants.subjects[i];
                final isSelected = _localFilter.subject == s;
                return FilterChip(
                  label: Text(s, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _localFilter = _localFilter.copyWith(
                          subject: isSelected ? null : s);
                    });
                    widget.onChanged(_localFilter);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Offer Type
          Row(
            children: [
              _FilterToggle(
                label: 'Private',
                icon: Icons.person_outline,
                isSelected: _localFilter.offerType == 'private',
                onTap: () {
                  setState(() {
                    _localFilter = _localFilter.copyWith(
                        offerType: _localFilter.offerType == 'private'
                            ? null
                            : 'private');
                  });
                  widget.onChanged(_localFilter);
                },
              ),
              const SizedBox(width: 8),
              _FilterToggle(
                label: 'Group',
                icon: Icons.group_outlined,
                isSelected: _localFilter.offerType == 'group',
                onTap: () {
                  setState(() {
                    _localFilter = _localFilter.copyWith(
                        offerType: _localFilter.offerType == 'group'
                            ? null
                            : 'group');
                  });
                  widget.onChanged(_localFilter);
                },
              ),
              const SizedBox(width: 8),
              _FilterToggle(
                label: 'Online only',
                icon: Icons.videocam_outlined,
                isSelected: _localFilter.onlineOnly == true,
                onTap: () {
                  setState(() {
                    _localFilter = _localFilter.copyWith(
                        onlineOnly: _localFilter.onlineOnly == true ? null : true);
                  });
                  widget.onChanged(_localFilter);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Min rating
          Row(
            children: [
              const Text('Min Rating: ',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      fontFamily: 'Poppins')),
              ...List.generate(5, (i) {
                final star = i + 1.0;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _localFilter = _localFilter.copyWith(
                          minRating: _localFilter.minRating == star ? null : star);
                    });
                    widget.onChanged(_localFilter);
                  },
                  child: Icon(
                    Icons.star_rounded,
                    size: 24,
                    color: (_localFilter.minRating ?? 0) >= star
                        ? AppTheme.warningColor
                        : AppTheme.grey300,
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterToggle(
      {required this.label,
      required this.icon,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : AppTheme.grey100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: isSelected ? Colors.white : AppTheme.grey600),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.grey600,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveFilters extends StatelessWidget {
  final SearchFilter filter;
  final VoidCallback onClearAll;
  const _ActiveFilters({required this.filter, required this.onClearAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.primaryColor.withOpacity(0.05),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Filters active',
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins'),
            ),
          ),
          TextButton(
            onPressed: onClearAll,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
            ),
            child: const Text('Clear all', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: AppTheme.grey300),
          const SizedBox(height: 16),
          Text(
            'No tutors found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters\nor search different keywords',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.grey500, fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }
}
