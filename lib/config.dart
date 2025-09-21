/// Application configuration constants and settings
///
/// This file contains all configuration values that are used throughout the application.
/// It includes API endpoints, app constants, theme settings, and other global configurations.
class AppConfig {
  // Private constructor to prevent instantiation
  AppConfig._();

  // App Information
  static const String appName = 'Blueprint Application';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Flutter MVVM+DDD Architecture Template';

  // API Configuration
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.example.com');

  static const String apiVersion = 'v1';
  static const String apiPrefix = '/api/$apiVersion';

  // Network Configuration
  static const int connectTimeout = 30; // seconds
  static const int receiveTimeout = 30; // seconds
  static const int sendTimeout = 30; // seconds

  // Authentication
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';

  // Cache Configuration
  static const String cacheKey = 'app_cache';
  static const int cacheMaxAge = 3600; // 1 hour in seconds
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB in bytes

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // UI Configuration
  static const double borderRadius = 8.0;
  static const double cardElevation = 2.0;
  static const double buttonPaddingHorizontal = 24.0;
  static const double buttonPaddingVertical = 12.0;
  static const double inputPaddingHorizontal = 16.0;
  static const double inputPaddingVertical = 12.0;

  // Animation Duration
  static const int shortAnimationDuration = 300; // milliseconds
  static const int mediumAnimationDuration = 500; // milliseconds
  static const int longAnimationDuration = 1000; // milliseconds

  // Image Configuration
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int imageQuality = 85; // 0-100
  static const double maxImageWidth = 1920;
  static const double maxImageHeight = 1080;

  // Text Limits
  static const int maxNameLength = 50;
  static const int maxEmailLength = 255;
  static const int maxPasswordLength = 128;
  static const int maxBioLength = 500;
  static const int maxCommentLength = 1000;
  static const int maxPostTitleLength = 200;
  static const int maxPostContentLength = 10000;

  // Validation Patterns
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';
  static const String urlPattern = r'^https?:\/\/[^\s/$.?#].[^\s]*$';

  // Error Messages
  static const String networkErrorMessage = 'เกิดข้อผิดพลาดในการเชื่อมต่อเครือข่าย';
  static const String serverErrorMessage = 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์';
  static const String unknownErrorMessage = 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ';
  static const String invalidInputMessage = 'ข้อมูลที่กรอกไม่ถูกต้อง';
  static const String authenticationErrorMessage = 'การยืนยันตัวตนล้มเหลว';
  static const String permissionDeniedMessage = 'ไม่มีสิทธิ์ในการเข้าถึง';

  // Success Messages
  static const String loginSuccessMessage = 'เข้าสู่ระบบสำเร็จ';
  static const String registerSuccessMessage = 'สมัครสมาชิกสำเร็จ';
  static const String logoutSuccessMessage = 'ออกจากระบบสำเร็จ';
  static const String updateSuccessMessage = 'อัปเดตข้อมูลสำเร็จ';
  static const String deleteSuccessMessage = 'ลบข้อมูลสำเร็จ';

  // Feature Flags
  static const bool enableDebugMode = bool.fromEnvironment('DEBUG_MODE', defaultValue: false);
  static const bool enableAnalytics = bool.fromEnvironment('ENABLE_ANALYTICS', defaultValue: true);
  static const bool enableCrashlytics = bool.fromEnvironment('ENABLE_CRASHLYTICS', defaultValue: true);
  static const bool enableLogging = bool.fromEnvironment('ENABLE_LOGGING', defaultValue: true);

  // Social Login
  static const bool enableGoogleLogin = bool.fromEnvironment('ENABLE_GOOGLE_LOGIN', defaultValue: true);
  static const bool enableFacebookLogin = bool.fromEnvironment('ENABLE_FACEBOOK_LOGIN', defaultValue: true);
  static const bool enableAppleLogin = bool.fromEnvironment('ENABLE_APPLE_LOGIN', defaultValue: true);

  // Deep Links
  static const String deepLinkScheme = 'blueprintapp';
  static const String deepLinkHost = 'app.blueprint.com';

  // File Upload
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'txt'];
  static const List<String> allowedVideoTypes = ['mp4', 'avi', 'mov', 'mkv'];

  // Notification
  static const String notificationChannelId = 'blueprint_notifications';
  static const String notificationChannelName = 'Blueprint Notifications';
  static const String notificationChannelDescription = 'General notifications from Blueprint App';

  // Database
  static const String databaseName = 'blueprint_app.db';
  static const int databaseVersion = 1;

  // Environment
  static bool get isProduction => const String.fromEnvironment('ENVIRONMENT') == 'production';
  static bool get isStaging => const String.fromEnvironment('ENVIRONMENT') == 'staging';
  static bool get isDevelopment => const String.fromEnvironment('ENVIRONMENT') == 'development';

  // URLs
  static String get termsOfServiceUrl => '$baseUrl/terms';
  static String get privacyPolicyUrl => '$baseUrl/privacy';
  static String get supportUrl => '$baseUrl/support';
  static String get aboutUrl => '$baseUrl/about';

  // Social Media
  static const String facebookUrl = 'https://facebook.com/blueprintapp';
  static const String twitterUrl = 'https://twitter.com/blueprintapp';
  static const String instagramUrl = 'https://instagram.com/blueprintapp';
  static const String linkedinUrl = 'https://linkedin.com/company/blueprintapp';

  // Contact Information
  static const String supportEmail = 'support@blueprint.com';
  static const String salesEmail = 'sales@blueprint.com';
  static const String developerEmail = 'dev@blueprint.com';
  static const String supportPhone = '+66-2-123-4567';
}
