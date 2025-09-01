/// Core application constants
///
/// PATTERN: Factory Pattern - Centralized constant management
/// WHERE: Used throughout the application for consistent values
/// WHY: Ensures single source of truth for app-wide constants
library;

class AppConstants {
  // App Information
  static const String appName = 'Design Patterns';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Tower Defense Learning Platform';

  // Supported Languages
  static const List<String> supportedLanguages = ['en', 'es', 'fr', 'de'];
  static const String defaultLanguage = 'en';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double glassmorphismBlur = 20.0;
  static const double glassmorphismOpacity = 0.2;

  // Tower Defense Game Constants
  static const int maxTowerLevel = 5;
  static const int maxPlayerLevel = 100;
  static const double towerRange = 150.0;

  // Pattern Categories
  static const int totalDesignPatterns = 18;
  static const int creationalPatterns = 6;
  static const int structuralPatterns = 6;
  static const int behavioralPatterns = 6;
}

class DatabaseConstants {
  static const String configDatabase = 'config.db';
  static const String configTableName = 'app_config';
  static const int databaseVersion = 1;
}

class FirebaseConstants {
  static const String usersCollection = 'users';
  static const String configCollection = 'config';
  static const String legalCollection = 'legal';
  static const String profileImagesPath = 'profile_images';
}
