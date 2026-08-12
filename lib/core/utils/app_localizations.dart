import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Auth
      'signIn': 'Sign In',
      'signOut': 'Sign Out',
      'register': 'Create Account',
      'email': 'Email Address',
      'password': 'Password',
      'forgotPassword': 'Forgot Password?',
      'noAccount': "Don't have an account?",
      'haveAccount': 'Already have an account?',

      // Home
      'home': 'Home',
      'search': 'Search',
      'favorites': 'Favorites',
      'profile': 'Profile',
      'map': 'Map',
      'featuredTutors': 'Top Tutors',
      'latestOffers': 'Latest Offers',
      'seeAll': 'See all',
      'categories': 'Categories',

      // Tutor
      'tutorProfile': 'Tutor Profile',
      'biography': 'Biography',
      'qualifications': 'Qualifications',
      'subjects': 'Subjects',
      'experience': 'Experience',
      'contact': 'Contact',
      'verified': 'Verified',
      'notVerified': 'Not Verified',
      'reviews': 'Reviews',
      'offers': 'Offers',

      // Offers
      'privateLesson': 'Private Lesson',
      'groupClass': 'Group Class',
      'hourlyRate': 'Hourly Rate',
      'monthlyPrice': 'Monthly Price',
      'online': 'Online',
      'inPerson': 'In-person',
      'maxStudents': 'Max Students',
      'availableSeats': 'Available Seats',

      // Search
      'searchTutors': 'Search Tutors',
      'filter': 'Filter',
      'clearAll': 'Clear all',
      'noResults': 'No tutors found',

      // Map
      'nearbyTutors': 'Nearby Tutors',
      'radius': 'Radius',

      // Admin
      'dashboard': 'Dashboard',
      'users': 'Users',
      'totalUsers': 'Total Users',
      'pendingVerifications': 'Pending Verifications',
      'approve': 'Approve',
      'reject': 'Reject',

      // Common
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'create': 'Create',
      'loading': 'Loading...',
      'error': 'Something went wrong',
      'retry': 'Retry',
      'back': 'Back',
      'done': 'Done',
      'yes': 'Yes',
      'no': 'No',

      // Reviews
      'writeReview': 'Write a Review',
      'yourRating': 'Your Rating',
      'yourReview': 'Your Review',
      'submitReview': 'Submit Review',

      // Subjects
      'mathematics': 'Mathematics',
      'physics': 'Physics',
      'chemistry': 'Chemistry',
      'biology': 'Biology',
      'english': 'English',
      'french': 'French',
      'computerScience': 'Computer Science',
      'economics': 'Economics',
      'other': 'Other',
    },
    'fr': {
      // Auth
      'signIn': 'Se connecter',
      'signOut': 'Se déconnecter',
      'register': 'Créer un compte',
      'email': 'Adresse e-mail',
      'password': 'Mot de passe',
      'forgotPassword': 'Mot de passe oublié ?',
      'noAccount': 'Pas encore de compte ?',
      'haveAccount': 'Vous avez déjà un compte ?',

      // Home
      'home': 'Accueil',
      'search': 'Rechercher',
      'favorites': 'Favoris',
      'profile': 'Profil',
      'map': 'Carte',
      'featuredTutors': 'Meilleurs tuteurs',
      'latestOffers': 'Dernières offres',
      'seeAll': 'Voir tout',
      'categories': 'Catégories',

      // Tutor
      'tutorProfile': 'Profil du tuteur',
      'biography': 'Biographie',
      'qualifications': 'Qualifications',
      'subjects': 'Matières',
      'experience': 'Expérience',
      'contact': 'Contacter',
      'verified': 'Vérifié',
      'notVerified': 'Non vérifié',
      'reviews': 'Avis',
      'offers': 'Offres',

      // Offers
      'privateLesson': 'Cours particulier',
      'groupClass': 'Cours collectif',
      'hourlyRate': 'Tarif horaire',
      'monthlyPrice': 'Prix mensuel',
      'online': 'En ligne',
      'inPerson': 'En présentiel',

      // Common
      'save': 'Enregistrer',
      'cancel': 'Annuler',
      'delete': 'Supprimer',
      'edit': 'Modifier',
      'loading': 'Chargement...',
      'error': 'Une erreur est survenue',
    },
    'ar': {
      // Auth
      'signIn': 'تسجيل الدخول',
      'signOut': 'تسجيل الخروج',
      'register': 'إنشاء حساب',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'forgotPassword': 'نسيت كلمة المرور؟',

      // Home
      'home': 'الرئيسية',
      'search': 'بحث',
      'favorites': 'المفضلة',
      'profile': 'الملف الشخصي',
      'map': 'الخريطة',
      'featuredTutors': 'أفضل المعلمين',
      'latestOffers': 'أحدث العروض',
      'seeAll': 'عرض الكل',
      'categories': 'التصنيفات',

      // Tutor
      'tutorProfile': 'ملف المعلم',
      'biography': 'السيرة الذاتية',
      'qualifications': 'المؤهلات',
      'subjects': 'المواد',
      'experience': 'الخبرة',
      'contact': 'تواصل',
      'verified': 'موثق',
      'notVerified': 'غير موثق',
      'reviews': 'التقييمات',
      'offers': 'العروض',

      // Common
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'edit': 'تعديل',
      'loading': 'جاري التحميل...',
      'error': 'حدث خطأ ما',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }

  // Convenience getters
  String get signIn => get('signIn');
  String get signOut => get('signOut');
  String get register => get('register');
  String get email => get('email');
  String get password => get('password');
  String get home => get('home');
  String get search => get('search');
  String get favorites => get('favorites');
  String get profile => get('profile');
  String get featuredTutors => get('featuredTutors');
  String get latestOffers => get('latestOffers');
  String get seeAll => get('seeAll');
  String get categories => get('categories');
  String get save => get('save');
  String get cancel => get('cancel');
  String get error => get('error');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'fr', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
