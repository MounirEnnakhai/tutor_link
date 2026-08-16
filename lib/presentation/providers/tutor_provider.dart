import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../data/datasources/firestore/tutor_remote_datasource.dart';
import '../../data/models/offer_model.dart';
import '../../data/models/tutor_model.dart';
import '../../domain/entities/offer_entity.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/entities/student_request_entity.dart';
import '../../domain/entities/tutor_entity.dart';
import 'auth_provider.dart';

// ─── Theme ───────────────────────────────────────────────────────────────────

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('themeMode') ?? 'system';
    state = _parseThemeMode(saved);
  }

  void setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

final themeModeProvider =
StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

// ─── Tutor DataSource ─────────────────────────────────────────────────────────

final tutorDataSourceProvider = Provider<TutorRemoteDataSource>((ref) {
  return TutorRemoteDataSource(
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(firebaseStorageProvider),
  );
});

// ─── Featured Tutors ──────────────────────────────────────────────────────────

final featuredTutorsProvider = FutureProvider<List<TutorEntity>>((ref) async {
  final ds = ref.watch(tutorDataSourceProvider);
  return ds.getFeaturedTutors(limit: 8);
});

// ─── Tutor by ID ──────────────────────────────────────────────────────────────

final tutorByIdProvider =
FutureProvider.family<TutorEntity, String>((ref, tutorId) async {
  final ds = ref.watch(tutorDataSourceProvider);
  return ds.getTutorById(tutorId);
});

// ─── Current Tutor Profile ────────────────────────────────────────────────────

final currentTutorProfileProvider = FutureProvider<TutorEntity?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null || !user.isTutor) return null;

  final ds = ref.watch(tutorDataSourceProvider);
  return ds.getTutorByUserId(user.id);
});

// ─── Search Providers ────────────────────────────────────────────────────────

class SearchNotifier extends StateNotifier<AsyncValue<List<TutorEntity>>> {
  final TutorRemoteDataSource _ds;
  SearchFilter _currentFilter = const SearchFilter();

  SearchNotifier(this._ds) : super(const AsyncValue.data([]));

  SearchFilter get currentFilter => _currentFilter;

  Future<void> search(SearchFilter filter, {double? lat, double? lng}) async {
    _currentFilter = filter;
    state = const AsyncValue.loading();
    try {
      final results = await _ds.searchTutors(
        filter: filter,
        userLat: lat,
        userLng: lng,
      );
      state = AsyncValue.data(results);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clear() {
    _currentFilter = const SearchFilter();
    state = const AsyncValue.data([]);
  }
}

final searchNotifierProvider =
StateNotifierProvider<SearchNotifier, AsyncValue<List<TutorEntity>>>((ref) {
  return SearchNotifier(ref.watch(tutorDataSourceProvider));
});

// ─── Offers ──────────────────────────────────────────────────────────────────

final featuredOffersProvider = FutureProvider<List<OfferEntity>>((ref) async {
  final firestore = ref.watch(firestoreProvider);
  final query = await firestore
      .collection(AppConstants.offersCollection)
      .where('status', isEqualTo: 'active')
      .orderBy('createdAt', descending: true)
      .limit(10)
      .get();

  return query.docs.map((d) => OfferModel.fromFirestore(d)).toList();
});

final offersByTutorProvider =
FutureProvider.family<List<OfferEntity>, String>((ref, tutorId) async {
  final firestore = ref.watch(firestoreProvider);
  final query = await firestore
      .collection(AppConstants.offersCollection)
      .where('tutorId', isEqualTo: tutorId)
      .where('status', isEqualTo: 'active')
      .get();

  return query.docs.map((d) => OfferModel.fromFirestore(d)).toList();
});

final offerByIdProvider =
FutureProvider.family<OfferEntity, String>((ref, offerId) async {
  final firestore = ref.watch(firestoreProvider);
  final doc = await firestore
      .collection(AppConstants.offersCollection)
      .doc(offerId)
      .get();

  if (!doc.exists) throw Exception('Offer not found');
  return OfferModel.fromFirestore(doc);
});

// ─── Reviews ──────────────────────────────────────────────────────────────────

final reviewsByTutorProvider =
FutureProvider.family<List<ReviewEntity>, String>((ref, tutorId) async {
  final firestore = ref.watch(firestoreProvider);
  final query = await firestore
      .collection(AppConstants.reviewsCollection)
      .where('tutorId', isEqualTo: tutorId)
      .where('isVisible', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .get();

  return query.docs.map((d) {
    final data = d.data();
    return ReviewEntity(
      id: d.id,
      tutorId: data['tutorId'] ?? '',
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      studentPhotoUrl: data['studentPhotoUrl'],
      rating: (data['rating'] as num).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isVisible: data['isVisible'] ?? true,
    );
  }).toList();
});

// ─── Favorites ────────────────────────────────────────────────────────────────

final favoriteTutorIdsProvider = StreamProvider<List<String>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection(AppConstants.favoritesCollection)
      .where('studentId', isEqualTo: user.id)
      .snapshots()
      .map((snap) =>
      snap.docs.map((d) => d.data()['tutorId'] as String).toList());
});

final favoriteTutorsProvider = FutureProvider<List<TutorEntity>>((ref) async {
  final ids = ref.watch(favoriteTutorIdsProvider).valueOrNull ?? [];
  if (ids.isEmpty) return [];

  final ds = ref.watch(tutorDataSourceProvider);
  final futures = ids.map((id) => ds.getTutorById(id));
  return Future.wait(futures);
});

// ─── Nearby Tutors ────────────────────────────────────────────────────────────

final nearbyTutorsProvider = FutureProvider.family<List<TutorEntity>,
    ({double lat, double lng, double radius})>((ref, params) async {
  final ds = ref.watch(tutorDataSourceProvider);
  return ds.getNearbyTutors(
    latitude: params.lat,
    longitude: params.lng,
    radiusKm: params.radius,
  );
});

// ─── Student Requests ─────────────────────────────────────────────────────────

StudentRequestEntity _requestFromDoc(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return StudentRequestEntity(
    id: doc.id,
    studentId: data['studentId'] ?? '',
    studentName: data['studentName'] ?? '',
    studentPhotoUrl: data['studentPhotoUrl'],
    subject: data['subject'] ?? '',
    title: data['title'] ?? '',
    description: data['description'] ?? '',
    maxBudget: (data['maxBudget'] as num?)?.toDouble(),
    type: data['type'] ?? 'private',
    preferredMode: data['preferredMode'] ?? 'both',
    location: data['location'],
    educationLevel: data['educationLevel'] ?? '',
    grade: data['grade'],
    status: data['status'] ?? 'open',
    createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}

// All open requests — tutors browse these
final studentRequestsProvider =
FutureProvider<List<StudentRequestEntity>>((ref) async {
  final firestore = ref.watch(firestoreProvider);
  final query = await firestore
      .collection('student_requests')
      .where('status', isEqualTo: 'open')
      .orderBy('createdAt', descending: true)
      .get();

  return query.docs.map(_requestFromDoc).toList();
});

// Filter state for tutor browsing requests
class RequestFilter {
  final String? subject;
  final String? educationLevel;

  const RequestFilter({this.subject, this.educationLevel});

  bool get isEmpty => subject == null && educationLevel == null;

  RequestFilter copyWith({String? subject, String? educationLevel}) {
    return RequestFilter(
      subject: subject,
      educationLevel: educationLevel,
    );
  }
}

final requestFilterProvider =
StateProvider<RequestFilter>((ref) => const RequestFilter());

// Filtered requests — tutors use this
final filteredRequestsProvider =
Provider<AsyncValue<List<StudentRequestEntity>>>((ref) {
  final requests = ref.watch(studentRequestsProvider);
  final filter = ref.watch(requestFilterProvider);

  return requests.whenData((list) {
    var filtered = list;
    if (filter.subject != null) {
      filtered =
          filtered.where((r) => r.subject == filter.subject).toList();
    }
    if (filter.educationLevel != null) {
      filtered = filtered
          .where((r) => r.educationLevel == filter.educationLevel)
          .toList();
    }
    return filtered;
  });
});

// Requests posted by the current student
final myRequestsProvider =
FutureProvider<List<StudentRequestEntity>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final firestore = ref.watch(firestoreProvider);
  final query = await firestore
      .collection('student_requests')
      .where('studentId', isEqualTo: user.id)
      .orderBy('createdAt', descending: true)
      .get();

  return query.docs.map(_requestFromDoc).toList();
});