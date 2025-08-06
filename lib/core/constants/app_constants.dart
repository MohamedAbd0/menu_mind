class AppConstants {
  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration quickAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  // Border radius
  static const double defaultBorderRadius = 24.0;
  static const double smallBorderRadius = 12.0;
  static const double largeBorderRadius = 32.0;

  // Padding and margins
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  // Card dimensions
  static const double cardElevation = 4.0;
  static const double dishCardHeight = 200.0;

  // Text sizes
  static const double titleTextSize = 24.0;
  static const double subtitleTextSize = 18.0;
  static const double bodyTextSize = 16.0;
  static const double captionTextSize = 14.0;
  static const double smallTextSize = 12.0;

  // Icon sizes
  static const double defaultIconSize = 24.0;
  static const double largeIconSize = 32.0;
  static const double smallIconSize = 16.0;

  // Storage keys
  static const String userAllergiesKey = 'user_allergies';
  static const String userLanguageKey = 'user_language';
  static const String translationCacheKey = 'translation_cache';
  static const String firstLaunchKey = 'first_launch';

  // AI model configuration
  static const String gemmaModelPath = 'assets/models/gemma-2b-it-q4_k_m.gguf';
  static const int maxTokens = 512;
  static const double temperature = 0.7;

  // Supported languages
  static const List<String> supportedLanguages = [
    'en', // English
    'ar', // Arabic
    'es', // Spanish
    'fr', // French
    'de', // German
    'it', // Italian
    'pt', // Portuguese
    'ru', // Russian
    'zh', // Chinese
    'ja', // Japanese
    'ko', // Korean
    'hi', // Hindi
    'tr', // Turkish
  ];

  // Available allergens
  static const List<String> availableAllergens = [
    'Dairy',
    'Gluten',
    'Nuts',
    'Tree Nuts',
    'Peanuts',
    'Shellfish',
    'Fish',
    'Eggs',
    'Soy',
    'Sesame',
    'Mustard',
    'Celery',
    'Sulfites',
    'Lupin',
  ];

  // Camera settings
  static const double cameraAspectRatio = 16 / 9;
  static const int imageQuality = 85;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
}
