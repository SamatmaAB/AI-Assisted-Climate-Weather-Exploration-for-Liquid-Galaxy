import 'package:hive_flutter/hive_flutter.dart';
import 'package:lg_connection/models/qa_item.dart';

/// A unified caching service using Hive for local data persistence.
class CacheService {
  static const String _qaBoxName = 'qaBox';
  static const String _settingsBoxName = 'settingsBox';
  static const String _climateBoxName = 'climateBox';

  /// Initializes all Hive boxes required for the application.
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(QAItemAdapter());
    
    await Hive.openBox<QAItem>(_qaBoxName);
    await Hive.openBox(_settingsBoxName);
    await Hive.openBox<String>(_climateBoxName);
  }

  /// Saves a climate phenomenon explanation to the cache.
  static Future<void> saveClimateInfo(String phenomenon, String explanation) async {
    final box = Hive.box<String>(_climateBoxName);
    await box.put(phenomenon, explanation);
  }

  /// Retrieves a climate phenomenon explanation from the cache.
  static String? getClimateInfo(String phenomenon) {
    final box = Hive.box<String>(_climateBoxName);
    return box.get(phenomenon);
  }

  /// Clears all cached climate information.
  static Future<void> clearClimateCache() async {
    final box = Hive.box<String>(_climateBoxName);
    await box.clear();
  }

  /// Gets the settings box for general preferences.
  static Box get settingsBox => Hive.box(_settingsBoxName);

  /// Gets the QA box for chatbot history.
  static Box<QAItem> get qaBox => Hive.box<QAItem>(_qaBoxName);
}
