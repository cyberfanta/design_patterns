# Dependencies Mapping - Design Patterns Flutter App

## 📋 **COMPREHENSIVE LIBRARY USAGE MAP**

This document explains every dependency added to the project, its purpose, implementation location, and integration with design patterns.

---

## 🎨 **UI AND ICONS**

### **cupertino_icons: ^1.0.8**
- **Purpose**: iOS-style icons for cross-platform consistency
- **Usage Location**: Throughout all UI components
- **Pattern Integration**: Used with Factory Pattern for icon creation
- **Implementation**: 
  ```dart
  // lib/core/ui/icon_factory.dart
  class IconFactory {
    static IconData getPatternIcon(PatternType type) {
      // Returns appropriate CupertinoIcons
    }
  }
  ```

---

## 🏗️ **STATE MANAGEMENT - CATEGORY SPECIFIC ARCHITECTURE**

### **flutter_riverpod: ^2.6.1**
- **Purpose**: Global MVVM state management for app-wide state
- **Usage Location**: 
  - `lib/core/providers/` - Global providers
  - `lib/features/*/presentation/providers/` - Feature-specific providers
- **Pattern Integration**: Observer + Singleton patterns
- **Architecture**: Used for global app state (language, theme, user session)
- **Implementation**:
  ```dart
  // lib/core/providers/app_providers.dart
  final languageProvider = StateNotifierProvider<LanguageNotifier, Language>(
    (ref) => LanguageNotifier(), // Singleton instance
  );
  ```

### **flutter_bloc: ^9.1.1**
- **Purpose**: Cubits (Creational patterns) + Blocs (Structural patterns)
- **Usage Location**: 
  - `lib/features/creational/domain/viewmodels/` - Cubits
  - `lib/features/structural/domain/viewmodels/` - Blocs
- **Pattern Integration**: Command + Observer patterns
- **Architecture**: MVC (Creational) + MVP (Structural)
- **Implementation**:
  ```dart
  // lib/features/creational/domain/viewmodels/factory_cubit.dart
  class FactoryPatternCubit extends Cubit<FactoryState> {
    // MVC architecture implementation
  }
  ```

### **get: ^4.7.2**
- **Purpose**: GetX for Behavioral patterns (MVVM-C architecture)
- **Usage Location**: `lib/features/behavioral/`
- **Pattern Integration**: Observer + Command + Mediator patterns
- **Architecture**: MVVM-C (Controller-based)
- **Implementation**:
  ```dart
  // lib/features/behavioral/presentation/controllers/observer_controller.dart
  class ObserverPatternController extends GetxController {
    // MVVM-C implementation with reactive state
  }
  ```

---

## 🔥 **FIREBASE SERVICES - COMPLETE INTEGRATION**

### **firebase_core: ^4.0.0**
- **Purpose**: Core Firebase functionality initialization
- **Usage Location**: `lib/main.dart` + `lib/core/firebase/`
- **Pattern Integration**: Singleton pattern for initialization
- **Implementation**: Single point of Firebase initialization

### **firebase_auth: ^6.0.1**
- **Purpose**: Authentication (Email/Google/Apple)
- **Usage Location**: `lib/features/user/data/datasources/auth_remote_datasource.dart`
- **Pattern Integration**: Facade + Proxy patterns
- **Implementation**:
  ```dart
  // lib/features/user/data/datasources/auth_remote_datasource.dart
  class AuthRemoteDataSource {
    // Facade for Firebase Auth complexity
    Future<Either<Failure, User>> signInWithEmail();
    Future<Either<Failure, User>> signInWithGoogle();
  }
  ```

### **cloud_firestore: ^6.0.0**
- **Purpose**: NoSQL database for user profiles and app configuration
- **Usage Location**: 
  - `lib/features/user/data/datasources/user_remote_datasource.dart`
  - `lib/features/config/data/datasources/config_remote_datasource.dart`
- **Pattern Integration**: Repository + Proxy + Memento patterns
- **Implementation**: User data persistence with isolated user folders

### **firebase_storage: ^13.0.0**
- **Purpose**: File storage for profile images
- **Usage Location**: `lib/features/user/data/datasources/storage_remote_datasource.dart`
- **Pattern Integration**: Proxy pattern for lazy loading
- **Implementation**: Profile image upload/download with caching

### **firebase_analytics: ^12.0.0**
- **Purpose**: Analytics tracking (learning behavior, pattern engagement)
- **Usage Location**: `lib/core/analytics/analytics_service.dart`
- **Pattern Integration**: Observer + Strategy patterns
- **Implementation**: Privacy-compliant learning analytics
- **Reference**: See `docs/firebase_analytics_plan.md`

### **firebase_performance: ^0.11.0**
- **Purpose**: Performance monitoring for app optimization
- **Usage Location**: `lib/core/performance/performance_service.dart`
- **Pattern Integration**: Decorator pattern for performance wrapping

### **firebase_crashlytics: ^5.0.0**
- **Purpose**: Crash reporting and error tracking
- **Usage Location**: `lib/core/error/crash_reporting_service.dart`
- **Pattern Integration**: Chain of Responsibility for error handling

### **firebase_app_check: ^0.4.0**
- **Purpose**: App security and abuse protection
- **Usage Location**: `lib/core/security/app_check_service.dart`
- **Pattern Integration**: Proxy pattern for security validation

### **google_sign_in: ^7.1.1** & **sign_in_with_apple: ^7.0.1**
- **Purpose**: Third-party authentication providers
- **Usage Location**: `lib/features/user/data/datasources/auth_providers/`
- **Pattern Integration**: Abstract Factory for authentication providers
- **Implementation**:
  ```dart
  // lib/features/user/data/datasources/auth_providers/auth_provider_factory.dart
  abstract class AuthProviderFactory {
    static AuthProvider createProvider(AuthType type);
  }
  ```

---

## 🗄️ **LOCAL DATABASE AND CONFIGURATION**

### **sqflite: ^2.4.2**
- **Purpose**: SQLite local database for app configuration
- **Usage Location**: `lib/features/config/data/datasources/config_local_datasource.dart`
- **Pattern Integration**: Repository + Memento patterns
- **Implementation**: Store language preferences, app settings
- **Schema**: Configuration tables with pattern-based structure

### **shared_preferences: ^2.5.3**
- **Purpose**: Simple key-value local storage
- **Usage Location**: `lib/core/storage/local_storage_service.dart`
- **Pattern Integration**: Singleton pattern
- **Implementation**: Cache user preferences, temporary data

### **path_provider: ^2.1.5**
- **Purpose**: File system paths for different platforms
- **Usage Location**: `lib/core/storage/path_service.dart`
- **Pattern Integration**: Abstract Factory for platform-specific paths
- **Implementation**: Cross-platform file storage paths

---

## 🌍 **INTERNATIONALIZATION AND LOCALIZATION**

### **flutter_localizations** (SDK)
- **Purpose**: Flutter's built-in localization support
- **Usage Location**: `lib/main.dart` (MaterialApp configuration)
- **Pattern Integration**: Strategy pattern for locale switching

### **intl: ^0.20.2**
- **Purpose**: Internationalization utilities (date, number formatting)
- **Usage Location**: `lib/features/multilang/`
- **Pattern Integration**: Observer + Memento + Singleton patterns
- **Implementation**:
  ```dart
  // lib/features/multilang/domain/services/translation_service.dart
  class TranslationService { // Singleton
    // Observer pattern for language changes
    // Memento pattern for language state persistence
  }
  ```
- **Supported Languages**: English, Spanish, French, German

---

## 🔧 **DEPENDENCY INJECTION AND PATTERNS**

### **get_it: ^8.2.0**
- **Purpose**: Service locator implementing Singleton pattern
- **Usage Location**: `lib/core/injection/injection_container.dart`
- **Pattern Integration**: Singleton + Factory patterns
- **Implementation**:
  ```dart
  // lib/core/injection/injection_container.dart
  final sl = GetIt.instance; // Singleton instance
  
  void init() {
    // Factory registrations for all services
    sl.registerFactory(() => PatternExampleUseCase(sl()));
  }
  ```

### **injectable: ^2.5.1**
- **Purpose**: Code generation for dependency injection
- **Usage Location**: Throughout the project with @injectable annotations
- **Pattern Integration**: Factory pattern automation
- **Implementation**: Generates factory methods automatically

---

## 🎨 **UI COMPONENTS AND EFFECTS**

### **flutter_glass_morphism: ^1.0.1**
- **Purpose**: Glassmorphism UI effects for modern design
- **Usage Location**: 
  - `lib/core/ui/glassmorphism/` - Reusable components
  - `lib/features/*/presentation/widgets/` - Feature-specific usage
- **Pattern Integration**: Builder + Prototype patterns
- **Implementation**:
  ```dart
  // lib/core/ui/glassmorphism/glass_card_builder.dart
  class GlassCardBuilder { // Builder pattern
    GlassCardBuilder setBlur(double blur);
    GlassCardBuilder setOpacity(double opacity);
    Widget build();
  }
  ```

### **mesh_gradient: ^1.3.8**
- **Purpose**: Mesh gradient backgrounds (green/cream theme)
- **Usage Location**: `lib/core/ui/backgrounds/mesh_background.dart`
- **Pattern Integration**: Strategy pattern for different gradient types
- **Implementation**: Background variations for different app sections

### **animated_background: ^2.0.0**
- **Purpose**: Animated gradient backgrounds for enhanced UX
- **Usage Location**: `lib/core/ui/backgrounds/animated_background.dart`
- **Pattern Integration**: State pattern for animation states

### **flutter_staggered_animations: ^1.1.1**
- **Purpose**: Staggered animations for list items and cards
- **Usage Location**: Pattern list views, navigation transitions
- **Pattern Integration**: Template Method for animation sequences

### **lottie: ^3.3.1**
- **Purpose**: Lottie animations for loading states and transitions
- **Usage Location**: `lib/core/ui/animations/` - Loading indicators, pattern icons
- **Pattern Integration**: Factory pattern for animation creation

---

## 🛠️ **UTILITY PACKAGES**

### **flutter_svg: ^2.2.0**
- **Purpose**: SVG support for pattern diagrams and icons
- **Usage Location**: 
  - `lib/features/*/presentation/widgets/pattern_diagram.dart`
  - `docs/generated/*.svg` - PlantUML generated diagrams
- **Pattern Integration**: Factory pattern for SVG creation

### **cached_network_image: ^3.4.1**
- **Purpose**: Network image caching with placeholder support
- **Usage Location**: User profile images, pattern illustrations
- **Pattern Integration**: Proxy pattern for image loading

### **image_picker: ^1.2.0**
- **Purpose**: Camera/gallery image selection for profile photos
- **Usage Location**: `lib/features/user/presentation/widgets/profile_image_picker.dart`
- **Pattern Integration**: Strategy pattern for image source selection

### **permission_handler: ^12.0.1**
- **Purpose**: Device permissions management (camera, storage)
- **Usage Location**: `lib/core/permissions/permission_service.dart`
- **Pattern Integration**: Chain of Responsibility for permission requests

### **device_info_plus: ^11.5.0** & **package_info_plus: ^8.3.1**
- **Purpose**: Device and app information for analytics and debugging
- **Usage Location**: `lib/core/device/device_info_service.dart`
- **Pattern Integration**: Facade pattern for device info complexity

---

## 📝 **CODE DISPLAY AND COPY FUNCTIONALITY**

### **re_highlight: ^0.0.3**
- **Purpose**: Syntax highlighting for multi-language code examples
- **Usage Location**: `lib/features/*/presentation/widgets/code_display_widget.dart`
- **Pattern Integration**: Strategy pattern for different languages
- **Supported Languages**: Flutter, TypeScript, Kotlin, Swift, Java, C#
- **Implementation**:
  ```dart
  // lib/features/*/presentation/widgets/code_display_widget.dart
  class CodeDisplayWidget extends StatelessWidget {
    // Strategy pattern for syntax highlighting
    final SyntaxHighlighter highlighter;
  }
  ```

### **clipboard: ^2.0.2**
- **Purpose**: Copy to clipboard functionality for code examples
- **Usage Location**: Code display widgets across all pattern demonstrations
- **Pattern Integration**: Command pattern for copy actions

### **flutter_code_editor: ^0.3.4**
- **Purpose**: Code editor widget for interactive pattern examples
- **Usage Location**: Advanced pattern demonstrations with editable code
- **Pattern Integration**: Observer pattern for code changes

---

## 🌐 **NETWORK AND HTTP**

### **dio: ^5.9.0**
- **Purpose**: HTTP client with interceptors for API communication
- **Usage Location**: `lib/core/network/api_client.dart`
- **Pattern Integration**: Decorator pattern for request/response interceptors
- **Implementation**: Firebase API communication, external resources

### **connectivity_plus: ^6.1.5**
- **Purpose**: Network connectivity detection
- **Usage Location**: `lib/core/network/connectivity_service.dart`
- **Pattern Integration**: Observer pattern for connectivity changes

---

## ⚡ **APP LIFECYCLE AND STATE PERSISTENCE**

### **lifecycle: ^0.10.0**
- **Purpose**: App lifecycle management (pause/resume without data loss)
- **Usage Location**: `lib/core/lifecycle/lifecycle_manager.dart`
- **Pattern Integration**: Memento + Observer patterns
- **Implementation**:
  ```dart
  // lib/core/lifecycle/lifecycle_manager.dart
  class LifecycleManager with WidgetsBindingObserver {
    // Memento pattern for state persistence
    // Observer pattern for lifecycle events
  }
  ```

### **hydrated_bloc: ^10.1.1**
- **Purpose**: State persistence for Bloc/Cubit (automatic save/restore)
- **Usage Location**: Structural patterns (MVP + Blocs)
- **Pattern Integration**: Memento pattern for state persistence
- **Implementation**: Automatic state hydration on app restart

---

## 🛡️ **SECURITY AND INPUT VALIDATION**

### **crypto: ^3.0.6**
- **Purpose**: Cryptographic algorithms for data security
- **Usage Location**: `lib/core/security/crypto_service.dart`
- **Pattern Integration**: Facade pattern for cryptographic operations
- **Implementation**: Data encryption, hashing, secure storage

### **form_validator: ^2.1.1**
- **Purpose**: Input validation utilities (modern, Flutter-specific)
- **Usage Location**: 
  - `lib/core/validation/input_validator.dart`
  - Form widgets throughout the app
- **Pattern Integration**: Chain of Responsibility for validation rules
- **Implementation**:
  ```dart
  // lib/core/validation/input_validator.dart
  class InputValidator {
    // Chain of Responsibility for validation rules
    ValidationChain emailValidation();
    ValidationChain passwordValidation();
  }
  ```

---

## 🧭 **NAVIGATION AND ROUTING**

### **go_router: ^16.2.1**
- **Purpose**: Declarative routing for complex navigation
- **Usage Location**: `lib/core/routing/app_router.dart`
- **Pattern Integration**: Strategy pattern for different navigation flows
- **Implementation**:
  ```dart
  // lib/core/routing/app_router.dart
  final router = GoRouter(
    routes: [
      // Pattern-specific routes with different architectures
      GoRoute(path: '/creational', builder: (context, state) => CreationalPage()), // MVC
      GoRoute(path: '/structural', builder: (context, state) => StructuralPage()), // MVP
      GoRoute(path: '/behavioral', builder: (context, state) => BehavioralPage()), // MVVM-C
    ],
  );
  ```

---

## 🔨 **FUNCTIONAL PROGRAMMING AND UTILITIES**

### **fpdart: ^1.1.0**
- **Purpose**: Functional programming (Either, Option) - modern alternative to dartz
- **Usage Location**: Error handling throughout the application
- **Pattern Integration**: Strategy pattern for error handling
- **Implementation**:
  ```dart
  // lib/core/error/either.dart
  import 'package:fpdart/fpdart.dart';
  
  typedef EitherFailure<T> = Either<Failure, T>;
  
  // Usage in use cases
  EitherFailure<PatternExample> getPatternExample();
  ```

### **equatable: ^2.0.7**
- **Purpose**: Value equality without boilerplate code
- **Usage Location**: Entity classes, value objects
- **Pattern Integration**: Used in all entity and value object implementations

### **freezed: ^3.2.0** & **json_annotation: ^4.9.0**
- **Purpose**: Code generation for immutable classes and JSON serialization
- **Usage Location**: Data models, entities, DTOs
- **Pattern Integration**: Factory pattern for object creation
- **Implementation**: Auto-generated copyWith, equality, JSON methods

---

## 🧪 **TESTING UTILITIES (TDD SUPPORT)**

### **mockito: ^5.5.0** & **build_runner: ^2.7.0**
- **Purpose**: Mock objects for testing with code generation
- **Usage Location**: `test/` directory structure mirroring `lib/`
- **Pattern Integration**: Proxy pattern for test doubles
- **Implementation**: Mock all external dependencies for unit tests

---

## 🧪 **DEV DEPENDENCIES - TESTING FRAMEWORK**

### **flutter_test** (SDK) & **test: ^1.25.15**
- **Purpose**: Core testing framework for TDD approach
- **Usage Location**: All test files following TDD methodology
- **Coverage Requirement**: Minimum 80% across all layers

### **flutter_lints: ^6.0.0** & **very_good_analysis: ^9.0.0**
- **Purpose**: Code quality and linting rules
- **Usage Location**: Applied project-wide for code quality
- **Implementation**: Ensures consistent code style and best practices

### **mocktail: ^1.0.4**
- **Purpose**: Mock library for testing (modern alternative to mockito)
- **Usage Location**: Unit and integration tests
- **Pattern Integration**: Test doubles for dependencies

### **bloc_test: ^10.0.0**
- **Purpose**: Testing utilities specifically for Bloc/Cubit
- **Usage Location**: Testing state management in Structural and Creational features
- **Implementation**: Test state changes and emissions

### **patrol: ^3.19.0**
- **Purpose**: Integration testing framework
- **Usage Location**: `integration_test/` directory
- **Implementation**: End-to-end user journey testing

### **alchemist: ^0.12.1**
- **Purpose**: Golden file testing (modern alternative to discontinued golden_toolkit)
- **Usage Location**: Widget appearance testing
- **Implementation**: Visual regression testing for UI components

---

## 🔧 **CODE GENERATION AND BUILD TOOLS**

### **injectable_generator: ^2.8.1**
- **Purpose**: Dependency injection code generation
- **Usage Location**: Generates registration code for GetIt
- **Command**: `flutter packages pub run build_runner build`

### **json_serializable: ^6.11.0**
- **Purpose**: JSON serialization code generation
- **Usage Location**: Data models requiring JSON conversion
- **Integration**: Works with freezed for complete model generation

---

## 🛠️ **DEVELOPMENT AND DEBUGGING TOOLS**

### **flutter_launcher_icons: ^0.14.4**
- **Purpose**: App icon generation for all platforms
- **Usage Location**: `assets/icons/` + configuration in pubspec.yaml
- **Implementation**: Single source icon → platform-specific icons

### **flutter_native_splash: ^2.4.6**
- **Purpose**: Native splash screen generation
- **Usage Location**: Customizable splash screen with branding
- **Pattern Integration**: Template Method for splash configuration

### **import_sorter: ^4.6.0**
- **Purpose**: Automatic import statement organization
- **Usage Location**: Project-wide import organization
- **Command**: `flutter packages pub run import_sorter:main`

---

## 📊 **PERFORMANCE AND ANALYSIS**

### **dart_code_metrics_presets: ^2.25.1**
- **Purpose**: Code metrics and quality analysis (updated alternative)
- **Usage Location**: CI/CD pipeline and development analysis
- **Implementation**: Monitors code complexity, maintainability
- **Integration**: Ensures adherence to clean code principles

---

## 🗂️ **USAGE SUMMARY BY ARCHITECTURE LAYER**

### **Presentation Layer**
- **State Management**: flutter_riverpod, flutter_bloc, get (by category)
- **UI Components**: flutter_glass_morphism, mesh_gradient, animated_background
- **Code Display**: re_highlight, clipboard, flutter_code_editor
- **Images/Media**: flutter_svg, cached_network_image, image_picker

### **Domain Layer**  
- **Patterns**: All design patterns implementation
- **Use Cases**: Business logic with fpdart for error handling
- **Entities**: equatable, freezed for immutable objects

### **Data Layer**
- **Remote**: Firebase services (auth, firestore, storage)
- **Local**: sqflite, shared_preferences
- **Network**: dio, connectivity_plus

### **Core Layer**
- **Injection**: get_it, injectable
- **Security**: crypto, form_validator
- **Lifecycle**: lifecycle, hydrated_bloc
- **Analytics**: firebase_analytics with privacy compliance

---

## 🎯 **IMPLEMENTATION PRIORITY**

### **Phase 1**: Core Infrastructure
- get_it (Dependency Injection)
- flutter_localizations + intl (Multilanguage)
- sqflite (Local Configuration)
- lifecycle (App Lifecycle)

### **Phase 2**: Firebase Integration
- firebase_core, firebase_auth, cloud_firestore
- firebase_analytics, firebase_performance, firebase_crashlytics

### **Phase 3**: State Management
- flutter_riverpod (Global)
- flutter_bloc (Creational + Structural)
- get (Behavioral)

### **Phase 4**: UI Components
- flutter_glass_morphism, mesh_gradient
- re_highlight, clipboard
- image_picker, cached_network_image

This comprehensive mapping ensures every dependency has a clear purpose, location, and integration strategy within our Clean Architecture + Design Patterns approach.
