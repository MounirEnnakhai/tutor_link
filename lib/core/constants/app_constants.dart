class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'TutorLink';
  static const String appTagline = 'Learn from the best';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String tutorsCollection = 'tutors';
  static const String studentsCollection = 'students';
  static const String offersCollection = 'offers';
  static const String reviewsCollection = 'reviews';
  static const String favoritesCollection = 'favorites';
  static const String verificationRequestsCollection = 'verification_requests';
  static const String chatsCollection = 'chats';
  static const String notificationsCollection = 'notifications';

  // Storage Paths
  static const String profilePicturesPath = 'profile_pictures';
  static const String offerImagesPath = 'offer_images';
  static const String verificationDocsPath = 'verification_docs';

  // Pagination
  static const int defaultPageSize = 20;
  static const int mapPageSize = 50;

  // Map
  static const double defaultMapZoom = 12.0;
  static const double defaultRadius = 10.0; // km
  static const double defaultLat = 33.5731;  // Casablanca, Morocco
  static const double defaultLng = -7.5898;

  // Price
  static const String defaultCurrency = 'MAD';
  static const List<String> supportedCurrencies = ['MAD', 'EUR', 'USD'];

  // Subjects
  static const List<String> subjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'French',
    'Arabic',
    'Computer Science',
    'Economics',
    'History',
    'Geography',
    'Philosophy',
    'Music',
    'Art',
    'Other',
  ];

  // Education Levels
  static const List<String> educationLevels = [
    'Primary School',
    'Middle School',
    'High School',
    'Baccalaureate',
    'Bachelor\'s',
    'Master\'s',
    'PhD',
    'Professional',
  ];

  // Teaching Modes
  static const List<String> teachingModes = [
    'Online',
    'At Tutor Location',
    'At Student Location',
    'Both',
  ];

  // Languages
  static const List<String> languages = [
    'Arabic',
    'French',
    'English',
    'Spanish',
    'German',
    'Other',
  ];

  // Rating
  static const int maxRating = 5;
  static const double minRating = 1.0;

  // File sizes
  static const int maxImageSizeMB = 5;
  static const int maxDocSizeMB = 10;

  // Regex
  static const String emailRegex =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phoneRegex = r'^\+?[0-9]{8,15}$';

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Padding & Spacing
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 28.0;
  static const double radiusRound = 100.0;

  // Card elevation
  static const double cardElevation = 2.0;

  // Error messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Please check your internet connection.';
  static const String authError = 'Authentication failed. Please try again.';
}
