/// Embedded Translations Data Source - Tower Defense Context
///
/// PATTERN: Factory + Singleton - Centralized translation data provision
/// WHERE: Data layer providing built-in translation data
/// HOW: Static maps with Tower Defense game translations
/// WHY: Ensures offline functionality and consistent game text
library;

import 'package:design_patterns/features/localization/data/models/translation_model.dart';

/// Embedded translations for the Tower Defense app
///
/// PATTERN: Factory - Creates translation models for different languages
/// Contains all game text in English, Spanish, French, and German
/// for towers, enemies, UI elements, and game mechanics.
class EmbeddedTranslationsDataSource {
  // PATTERN: Singleton - Ensure single source of embedded translations
  static const EmbeddedTranslationsDataSource _instance =
      EmbeddedTranslationsDataSource._();

  factory EmbeddedTranslationsDataSource() => _instance;

  const EmbeddedTranslationsDataSource._();

  /// English translations (base language)
  static const Map<String, String> _englishTranslations = {
    // App Core
    'app_name': 'Design Patterns Tower Defense',
    'app_subtitle': 'Learn Design Patterns Through Gaming',
    'version': 'Version',
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',
    'warning': 'Warning',
    'info': 'Information',

    // Game Core
    'game_start': 'Start Game',
    'game_pause': 'Pause',
    'game_resume': 'Resume',
    'game_over': 'Game Over',
    'game_won': 'Victory!',
    'game_lost': 'Defeat!',
    'next_wave': 'Next Wave',
    'wave': 'Wave',
    'score': 'Score',
    'lives': 'Lives',
    'gold': 'Gold',
    'experience': 'Experience',
    'level': 'Level',

    // Towers
    'tower_archer': 'Archer Tower',
    'tower_stone': 'Stone Thrower',
    'tower_archer_desc': 'Fast arrows, medium damage',
    'tower_stone_desc': 'Slow stones, high damage',
    'build_tower': 'Build Tower',
    'upgrade_tower': 'Upgrade Tower',
    'sell_tower': 'Sell Tower',
    'tower_range': 'Range',
    'tower_damage': 'Damage',
    'tower_speed': 'Attack Speed',
    'tower_cost': 'Cost',

    // Enemies
    'enemy_ant': 'Ant',
    'enemy_grasshopper': 'Grasshopper',
    'enemy_cockroach': 'Cockroach',
    'enemy_ant_desc': 'Fast and numerous',
    'enemy_grasshopper_desc': 'Jumps over traps',
    'enemy_cockroach_desc': 'Tough and resistant',
    'enemy_health': 'Health',
    'enemy_speed': 'Speed',
    'enemy_reward': 'Gold Reward',

    // UI Elements
    'menu': 'Menu',
    'settings': 'Settings',
    'profile': 'Profile',
    'help': 'Help',
    'about': 'About',
    'back': 'Back',
    'next': 'Next',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'save': 'Save',
    'load': 'Load',
    'delete': 'Delete',
    'edit': 'Edit',
    'close': 'Close',

    // Pattern Categories
    'creational_patterns': 'Creational Patterns',
    'structural_patterns': 'Structural Patterns',
    'behavioral_patterns': 'Behavioral Patterns',
    'creational_desc': 'Object creation mechanisms',
    'structural_desc': 'Object composition and relationships',
    'behavioral_desc': 'Communication between objects',

    // Language Settings
    'language': 'Language',
    'change_language': 'Change Language',
    'language_changed': 'Language changed successfully',
    'auto_detect': 'Auto-detect',
    'system_language': 'System Language',

    // User Profile
    'login': 'Login',
    'logout': 'Logout',
    'register': 'Register',
    'email': 'Email',
    'password': 'Password',
    'confirm_password': 'Confirm Password',
    'forgot_password': 'Forgot Password',
    'user_name': 'Name',
    'user_photo': 'Profile Photo',

    // Buy Me Coffee
    'support_title': 'Support Development',
    'coffee_message': 'If you enjoyed this app, you can buy me a coffee',
    'support_help': 'Your support helps me keep creating',
    'not_required': 'Not required, but greatly appreciated',
    'buy_coffee': 'Buy Me a Coffee',
  };

  /// Spanish translations
  static const Map<String, String> _spanishTranslations = {
    // App Core
    'app_name': 'Torre de Defensa Patrones de Diseño',
    'app_subtitle': 'Aprende Patrones de Diseño a Través del Juego',
    'version': 'Versión',
    'loading': 'Cargando...',
    'error': 'Error',
    'success': 'Éxito',
    'warning': 'Advertencia',
    'info': 'Información',

    // Game Core
    'game_start': 'Iniciar Juego',
    'game_pause': 'Pausar',
    'game_resume': 'Reanudar',
    'game_over': 'Juego Terminado',
    'game_won': '¡Victoria!',
    'game_lost': '¡Derrota!',
    'next_wave': 'Siguiente Oleada',
    'wave': 'Oleada',
    'score': 'Puntuación',
    'lives': 'Vidas',
    'gold': 'Oro',
    'experience': 'Experiencia',
    'level': 'Nivel',

    // Towers
    'tower_archer': 'Torre Arquero',
    'tower_stone': 'Lanza Piedras',
    'tower_archer_desc': 'Flechas rápidas, daño medio',
    'tower_stone_desc': 'Piedras lentas, daño alto',
    'build_tower': 'Construir Torre',
    'upgrade_tower': 'Mejorar Torre',
    'sell_tower': 'Vender Torre',
    'tower_range': 'Alcance',
    'tower_damage': 'Daño',
    'tower_speed': 'Velocidad de Ataque',
    'tower_cost': 'Coste',

    // Enemies
    'enemy_ant': 'Hormiga',
    'enemy_grasshopper': 'Saltamontes',
    'enemy_cockroach': 'Cucaracha',
    'enemy_ant_desc': 'Rápida y numerosa',
    'enemy_grasshopper_desc': 'Salta sobre trampas',
    'enemy_cockroach_desc': 'Resistente y dura',
    'enemy_health': 'Salud',
    'enemy_speed': 'Velocidad',
    'enemy_reward': 'Recompensa de Oro',

    // UI Elements
    'menu': 'Menú',
    'settings': 'Configuración',
    'profile': 'Perfil',
    'help': 'Ayuda',
    'about': 'Acerca de',
    'back': 'Atrás',
    'next': 'Siguiente',
    'cancel': 'Cancelar',
    'confirm': 'Confirmar',
    'save': 'Guardar',
    'load': 'Cargar',
    'delete': 'Eliminar',
    'edit': 'Editar',
    'close': 'Cerrar',

    // Pattern Categories
    'creational_patterns': 'Patrones Creacionales',
    'structural_patterns': 'Patrones Estructurales',
    'behavioral_patterns': 'Patrones de Comportamiento',
    'creational_desc': 'Mecanismos de creación de objetos',
    'structural_desc': 'Composición y relaciones de objetos',
    'behavioral_desc': 'Comunicación entre objetos',

    // Language Settings
    'language': 'Idioma',
    'change_language': 'Cambiar Idioma',
    'language_changed': 'Idioma cambiado exitosamente',
    'auto_detect': 'Detectar automáticamente',
    'system_language': 'Idioma del Sistema',

    // User Profile
    'login': 'Iniciar Sesión',
    'logout': 'Cerrar Sesión',
    'register': 'Registrarse',
    'email': 'Correo Electrónico',
    'password': 'Contraseña',
    'confirm_password': 'Confirmar Contraseña',
    'forgot_password': 'Olvidé mi Contraseña',
    'user_name': 'Nombre',
    'user_photo': 'Foto de Perfil',

    // Buy Me Coffee
    'support_title': 'Apoyar el Desarrollo',
    'coffee_message': 'Si te gustó esta app, puedes invitarme un café',
    'support_help': 'Tu apoyo me ayuda a seguir creando',
    'not_required': 'No es necesario, pero se agradece mucho',
    'buy_coffee': 'Invítame un Café',
  };

  /// French translations
  static const Map<String, String> _frenchTranslations = {
    // App Core
    'app_name': 'Tour de Défense Modèles de Conception',
    'app_subtitle': 'Apprenez les Modèles de Conception par le Jeu',
    'version': 'Version',
    'loading': 'Chargement...',
    'error': 'Erreur',
    'success': 'Succès',
    'warning': 'Avertissement',
    'info': 'Information',

    // Game Core
    'game_start': 'Commencer le Jeu',
    'game_pause': 'Pause',
    'game_resume': 'Reprendre',
    'game_over': 'Jeu Terminé',
    'game_won': 'Victoire !',
    'game_lost': 'Défaite !',
    'next_wave': 'Vague Suivante',
    'wave': 'Vague',
    'score': 'Score',
    'lives': 'Vies',
    'gold': 'Or',
    'experience': 'Expérience',
    'level': 'Niveau',

    // Towers
    'tower_archer': 'Tour d\'Archer',
    'tower_stone': 'Lance-Pierre',
    'tower_archer_desc': 'Flèches rapides, dégâts moyens',
    'tower_stone_desc': 'Pierres lentes, gros dégâts',
    'build_tower': 'Construire Tour',
    'upgrade_tower': 'Améliorer Tour',
    'sell_tower': 'Vendre Tour',
    'tower_range': 'Portée',
    'tower_damage': 'Dégâts',
    'tower_speed': 'Vitesse d\'Attaque',
    'tower_cost': 'Coût',

    // Enemies
    'enemy_ant': 'Fourmi',
    'enemy_grasshopper': 'Sauterelle',
    'enemy_cockroach': 'Cafard',
    'enemy_ant_desc': 'Rapide et nombreuse',
    'enemy_grasshopper_desc': 'Saute par-dessus les pièges',
    'enemy_cockroach_desc': 'Coriace et résistante',
    'enemy_health': 'Santé',
    'enemy_speed': 'Vitesse',
    'enemy_reward': 'Récompense en Or',

    // UI Elements
    'menu': 'Menu',
    'settings': 'Paramètres',
    'profile': 'Profil',
    'help': 'Aide',
    'about': 'À Propos',
    'back': 'Retour',
    'next': 'Suivant',
    'cancel': 'Annuler',
    'confirm': 'Confirmer',
    'save': 'Sauvegarder',
    'load': 'Charger',
    'delete': 'Supprimer',
    'edit': 'Modifier',
    'close': 'Fermer',

    // Pattern Categories
    'creational_patterns': 'Modèles de Création',
    'structural_patterns': 'Modèles Structurels',
    'behavioral_patterns': 'Modèles Comportementaux',
    'creational_desc': 'Mécanismes de création d\'objets',
    'structural_desc': 'Composition et relations d\'objets',
    'behavioral_desc': 'Communication entre objets',

    // Language Settings
    'language': 'Langue',
    'change_language': 'Changer la Langue',
    'language_changed': 'Langue changée avec succès',
    'auto_detect': 'Détection automatique',
    'system_language': 'Langue du Système',

    // User Profile
    'login': 'Connexion',
    'logout': 'Déconnexion',
    'register': 'S\'inscrire',
    'email': 'E-mail',
    'password': 'Mot de Passe',
    'confirm_password': 'Confirmer le Mot de Passe',
    'forgot_password': 'Mot de Passe Oublié',
    'user_name': 'Nom',
    'user_photo': 'Photo de Profil',

    // Buy Me Coffee
    'support_title': 'Soutenir le Développement',
    'coffee_message':
        'Si vous avez aimé cette app, vous pouvez m\'offrir un café',
    'support_help': 'Votre soutien m\'aide à continuer à créer',
    'not_required': 'Pas obligatoire, mais très apprécié',
    'buy_coffee': 'Offrez-moi un Café',
  };

  /// German translations
  static const Map<String, String> _germanTranslations = {
    // App Core
    'app_name': 'Tower Defense Entwurfsmuster',
    'app_subtitle': 'Lerne Entwurfsmuster durch Spielen',
    'version': 'Version',
    'loading': 'Lädt...',
    'error': 'Fehler',
    'success': 'Erfolg',
    'warning': 'Warnung',
    'info': 'Information',

    // Game Core
    'game_start': 'Spiel Starten',
    'game_pause': 'Pausieren',
    'game_resume': 'Fortsetzen',
    'game_over': 'Spiel Beendet',
    'game_won': 'Sieg!',
    'game_lost': 'Niederlage!',
    'next_wave': 'Nächste Welle',
    'wave': 'Welle',
    'score': 'Punkte',
    'lives': 'Leben',
    'gold': 'Gold',
    'experience': 'Erfahrung',
    'level': 'Level',

    // Towers
    'tower_archer': 'Bogenschützenturm',
    'tower_stone': 'Steinwerfer',
    'tower_archer_desc': 'Schnelle Pfeile, mittlerer Schaden',
    'tower_stone_desc': 'Langsame Steine, hoher Schaden',
    'build_tower': 'Turm Bauen',
    'upgrade_tower': 'Turm Verbessern',
    'sell_tower': 'Turm Verkaufen',
    'tower_range': 'Reichweite',
    'tower_damage': 'Schaden',
    'tower_speed': 'Angriffsgeschwindigkeit',
    'tower_cost': 'Kosten',

    // Enemies
    'enemy_ant': 'Ameise',
    'enemy_grasshopper': 'Heuschrecke',
    'enemy_cockroach': 'Kakerlake',
    'enemy_ant_desc': 'Schnell und zahlreich',
    'enemy_grasshopper_desc': 'Springt über Fallen',
    'enemy_cockroach_desc': 'Zäh und widerstandsfähig',
    'enemy_health': 'Gesundheit',
    'enemy_speed': 'Geschwindigkeit',
    'enemy_reward': 'Gold-Belohnung',

    // UI Elements
    'menu': 'Menü',
    'settings': 'Einstellungen',
    'profile': 'Profil',
    'help': 'Hilfe',
    'about': 'Über',
    'back': 'Zurück',
    'next': 'Weiter',
    'cancel': 'Abbrechen',
    'confirm': 'Bestätigen',
    'save': 'Speichern',
    'load': 'Laden',
    'delete': 'Löschen',
    'edit': 'Bearbeiten',
    'close': 'Schließen',

    // Pattern Categories
    'creational_patterns': 'Erzeugungsmuster',
    'structural_patterns': 'Strukturmuster',
    'behavioral_patterns': 'Verhaltensmuster',
    'creational_desc': 'Objekterstellungsmechanismen',
    'structural_desc': 'Objektkomposition und -beziehungen',
    'behavioral_desc': 'Kommunikation zwischen Objekten',

    // Language Settings
    'language': 'Sprache',
    'change_language': 'Sprache Ändern',
    'language_changed': 'Sprache erfolgreich geändert',
    'auto_detect': 'Automatisch Erkennen',
    'system_language': 'Systemsprache',

    // User Profile
    'login': 'Anmelden',
    'logout': 'Abmelden',
    'register': 'Registrieren',
    'email': 'E-Mail',
    'password': 'Passwort',
    'confirm_password': 'Passwort Bestätigen',
    'forgot_password': 'Passwort Vergessen',
    'user_name': 'Name',
    'user_photo': 'Profilfoto',

    // Buy Me Coffee
    'support_title': 'Entwicklung Unterstützen',
    'coffee_message':
        'Wenn dir diese App gefällt, kannst du mir einen Kaffee spendieren',
    'support_help': 'Deine Unterstützung hilft mir beim Weiterarbeiten',
    'not_required': 'Nicht erforderlich, aber sehr geschätzt',
    'buy_coffee': 'Spendier mir einen Kaffee',
  };

  /// Get translation model for specified language code
  TranslationModel? getTranslation(String languageCode) {
    final version = '1.0.0';

    switch (languageCode.toLowerCase()) {
      case 'en':
        return TranslationModel(
          languageCode: 'en',
          translations: _englishTranslations,
          version: version,
        );
      case 'es':
        return TranslationModel(
          languageCode: 'es',
          translations: _spanishTranslations,
          version: version,
        );
      case 'fr':
        return TranslationModel(
          languageCode: 'fr',
          translations: _frenchTranslations,
          version: version,
        );
      case 'de':
        return TranslationModel(
          languageCode: 'de',
          translations: _germanTranslations,
          version: version,
        );
      default:
        return null;
    }
  }

  /// Get all supported language codes
  List<String> getSupportedLanguages() {
    return ['en', 'es', 'fr', 'de'];
  }

  /// Check if language code is supported
  bool isLanguageSupported(String languageCode) {
    return getSupportedLanguages().contains(languageCode.toLowerCase());
  }

  /// Get all available translations
  Map<String, TranslationModel> getAllTranslations() {
    return {
      'en': getTranslation('en')!,
      'es': getTranslation('es')!,
      'fr': getTranslation('fr')!,
      'de': getTranslation('de')!,
    };
  }
}
