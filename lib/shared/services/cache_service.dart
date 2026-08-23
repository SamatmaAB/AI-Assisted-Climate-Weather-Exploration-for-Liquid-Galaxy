import 'package:hive_flutter/hive_flutter.dart';
import 'package:lg_connection/models/qa_item.dart';

class CacheService {
  static const String _qaBoxName = 'qaBox';
  static const String _settingsBoxName = 'settingsBox';
  static const String _climateBoxName = 'climateBox';
  static const String _cityExplorerBoxName = 'cityExplorerBox';
  static const String _phenomenonCardBoxName = 'phenomenonCardBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(QAItemAdapter());

    await Hive.openBox<QAItem>(_qaBoxName);
    await Hive.openBox(_settingsBoxName);
    await Hive.openBox<String>(_climateBoxName);
    await Hive.openBox<String>(_cityExplorerBoxName);
    await Hive.openBox<String>(_phenomenonCardBoxName);
  }

  static Future<void> saveClimateInfo(String phenomenon, String explanation) async {
    final box = Hive.box<String>(_climateBoxName);
    await box.put(phenomenon, explanation);
  }

  static String? getClimateInfo(String phenomenon) {
    final box = Hive.box<String>(_climateBoxName);
    return box.get(phenomenon);
  }

  static Future<void> clearClimateCache() async {
    final box = Hive.box<String>(_climateBoxName);
    await box.clear();
  }

  static Future<void> saveCityLandmark(String city, String jsonString) async {
    final box = Hive.box<String>(_cityExplorerBoxName);
    await box.put(city.trim().toLowerCase(), jsonString);
  }

  static String? getCityLandmark(String city) {
    final box = Hive.box<String>(_cityExplorerBoxName);
    return box.get(city.trim().toLowerCase());
  }

  static Future<void> savePhenomenonCard(String phenomenon, String jsonString) async {
    final box = Hive.box<String>(_phenomenonCardBoxName);
    await box.put(phenomenon.trim().toLowerCase(), jsonString);
  }

  static String? getPhenomenonCard(String phenomenon) {
    final box = Hive.box<String>(_phenomenonCardBoxName);
    return box.get(phenomenon.trim().toLowerCase());
  }

  static Future<void> clearPhenomenonCardCache() async {
    final box = Hive.box<String>(_phenomenonCardBoxName);
    await box.clear();
  }

  static Box get settingsBox => Hive.box(_settingsBoxName);

  static Box<QAItem> get qaBox => Hive.box<QAItem>(_qaBoxName);
}
