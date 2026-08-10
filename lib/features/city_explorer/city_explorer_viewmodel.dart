import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/features/city_explorer/models/city_landmark.dart';
import 'package:lg_connection/features/city_explorer/models/weather_data.dart';
import 'package:lg_connection/features/city_explorer/services/weather_service.dart';
import 'package:lg_connection/models/lookat_model.dart';
import 'package:lg_connection/services/ai/api_key_storage.dart';
import 'package:lg_connection/services/ai/prompts/ai_prompts.dart';
import 'package:lg_connection/services/tts/tts_service.dart';
import 'package:lg_connection/shared/services/cache_service.dart';
import 'package:lg_connection/shared/services/map_sync_service.dart';

// ─── Camera Presets ──────────────────────────────────────────────────────────

/// Configurable camera parameters for the cinematic landmark approach.
/// Tune these values on the physical Liquid Galaxy rig as needed.
class LandmarkCameraPreset {
  final double range;
  final double tilt;
  final double heading;

  const LandmarkCameraPreset({
    required this.range,
    required this.tilt,
    required this.heading,
  });

  static const overview    = LandmarkCameraPreset(range: 8000,  tilt: 30, heading: 0);
  static const approach    = LandmarkCameraPreset(range: 800,   tilt: 65, heading: 30);
  static const groundLevel = LandmarkCameraPreset(range: 200,   tilt: 72, heading: 30);
}

// ─── Explorer State ──────────────────────────────────────────────────────────

enum CityExplorerStatus { idle, loading, success, error }

// ─── ViewModel ───────────────────────────────────────────────────────────────

class CityExplorerViewModel extends ChangeNotifier {
  final LGSSHClient _sshClient = LGSSHClient();
  final MapSyncService _mapSyncService = MapSyncService();
  final WeatherService _weatherService = WeatherService();
  final TtsService _tts = TtsService.instance;
  final ApiKeyStorage _apiKeyStorage = const ApiKeyStorage();

  CityExplorerStatus _status = CityExplorerStatus.idle;
  CityExplorerStatus get status => _status;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  CityLandmark? _landmark;
  CityLandmark? get landmark => _landmark;

  WeatherData? _weather;
  WeatherData? get weather => _weather;

  String _narration = '';
  String get narration => _narration;

  ValueListenable<bool> get isConnected => _sshClient.isConnected;

  // ── Public entry point ────────────────────────────────────────────────────

  Future<void> exploreCity(String city) async {
    final trimmed = city.trim();
    if (trimmed.isEmpty) {
      _setError('Please enter a city name.');
      return;
    }

    // Auto-stop ongoing narration when a new city/effect is searched
    await _tts.stop();

    _status = CityExplorerStatus.loading;
    _errorMessage = '';
    _narration = '';
    notifyListeners();

    try {
      // Step 1: Resolve city landmark (Hive cache → Gemini)
      final resolved = await _resolveLandmark(trimmed);
      if (resolved == null) return; // error already set
      _landmark = resolved;
      notifyListeners();

      // Step 2: Cinematic fly-to (fire-and-forget the slow sequence)
      _cinematicFlyTo(resolved);

      // Step 3: Fetch weather
      WeatherData? weather;
      try {
        weather = await _weatherService.fetchWeather(resolved.latitude, resolved.longitude);
        _weather = weather;
        notifyListeners();
      } catch (e) {
        debugPrint('CityExplorer: Weather fetch failed: $e');
      }

      // Step 4: Gemini narration → TTS (fire-and-forget)
      _status = CityExplorerStatus.success;
      notifyListeners();

      _fetchAndNarrate(resolved, weather);
    } catch (e) {
      debugPrint('CityExplorer: Unexpected error: $e');
      _setError('Something went wrong. Please try again.');
    }
  }

  // ── Step 1: Landmark resolution ───────────────────────────────────────────

  Future<CityLandmark?> _resolveLandmark(String city) async {
    // Check Hive cache first
    final cached = CacheService.getCityLandmark(city);
    if (cached != null) {
      try {
        final map = json.decode(cached) as Map<String, dynamic>;
        return CityLandmark.fromJson(map);
      } catch (_) {
        // Corrupted cache entry — fall through to Gemini
      }
    }

    // Ask Gemini
    final apiKey = await _apiKeyStorage.getGeminiApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      _setError('Gemini API key is not configured. Add your key in Settings.');
      return null;
    }

    try {
      final modelName = await _apiKeyStorage.getSelectedModel();
      final model = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
        systemInstruction: Content.system(AIPrompts.cityLandmark),
      );
      final response = await model.generateContent([Content.text('City: $city')]);
      final text = (response.text ?? '').trim();

      // Strip markdown code fences if Gemini added them
      final cleaned = _stripCodeFences(text);
      final jsonMap = json.decode(cleaned) as Map<String, dynamic>;

      if (jsonMap.containsKey('error')) {
        _setError('City not found. Try a different spelling or city.');
        return null;
      }

      final resolved = CityLandmark.fromJson(jsonMap);

      // Persist to Hive
      await CacheService.saveCityLandmark(city, json.encode(jsonMap));

      return resolved;
    } on FormatException catch (e) {
      debugPrint('CityExplorer: Malformed Gemini JSON: $e');
      _setError('Received an invalid response from AI. Please try again.');
      return null;
    } catch (e) {
      debugPrint('CityExplorer: Gemini error: $e');
      _setError('AI service is unavailable. Please try again.');
      return null;
    }
  }

  String _stripCodeFences(String text) {
    var s = text.trim();
    if (s.startsWith('```')) {
      s = s.replaceFirst(RegExp(r'^```[a-z]*\n?'), '');
      s = s.replaceFirst(RegExp(r'```$'), '');
    }
    return s.trim();
  }

  // ── Step 2: Cinematic fly-to ──────────────────────────────────────────────

  Future<void> _cinematicFlyTo(CityLandmark resolved) async {
    try {
      // Stage 1 – wide overview
      await _mapSyncService.flyTo(LookAt(
        latitude: resolved.latitude,
        longitude: resolved.longitude,
        zoom: _rangeToZoom(LandmarkCameraPreset.overview.range),
        tilt: LandmarkCameraPreset.overview.tilt,
        bearing: LandmarkCameraPreset.overview.heading,
      ));
      await Future.delayed(const Duration(milliseconds: 3500));

      // Stage 2 – approach
      await _mapSyncService.flyTo(LookAt(
        latitude: resolved.latitude,
        longitude: resolved.longitude,
        zoom: _rangeToZoom(LandmarkCameraPreset.approach.range),
        tilt: LandmarkCameraPreset.approach.tilt,
        bearing: LandmarkCameraPreset.approach.heading,
      ));
      await Future.delayed(const Duration(milliseconds: 3500));

      // Stage 3 – near ground level
      await _mapSyncService.flyTo(LookAt(
        latitude: resolved.latitude,
        longitude: resolved.longitude,
        zoom: _rangeToZoom(LandmarkCameraPreset.groundLevel.range),
        tilt: LandmarkCameraPreset.groundLevel.tilt,
        bearing: LandmarkCameraPreset.groundLevel.heading,
      ));
    } catch (e) {
      debugPrint('CityExplorer: Fly-to failed: $e');
    }
  }

  /// Converts a LG range (metres) to a Google Maps zoom level.
  /// Formula mirrors LookAt.fromXml so serialization round-trips correctly.
  double _rangeToZoom(double rangeMeters) {
    final zoom = (math.log(591657550.5 / rangeMeters) / math.log(2)) + 1.0 - 3.8;
    return zoom.clamp(1.0, 21.0);
  }

  // ── Step 4: Gemini narration → TTS ───────────────────────────────────────

  Future<void> _fetchAndNarrate(CityLandmark resolved, WeatherData? weather) async {
    try {
      final apiKey = await _apiKeyStorage.getGeminiApiKey();
      if (apiKey == null || apiKey.isEmpty) return;

      final weatherSummary = weather != null
          ? 'Temperature: ${weather.temperature.toStringAsFixed(1)}°C, '
              'Condition: ${weather.condition}, '
              'Humidity: ${weather.humidity}%, '
              'Wind: ${weather.windSpeed.toStringAsFixed(0)} km/h'
          : 'Weather data unavailable.';

      final prompt = 'City: ${resolved.city}\n'
          'Landmark: ${resolved.landmark}\n'
          '$weatherSummary\n'
          'Climate context: ${resolved.climateContext}';

      final modelName = await _apiKeyStorage.getSelectedModel();
      final model = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
        systemInstruction: Content.system(AIPrompts.cityWeatherNarration),
      );
      final response = await model.generateContent([Content.text(prompt)]);
      final narration = (response.text ?? '').trim();

      if (narration.isNotEmpty) {
        _narration = narration;
        notifyListeners();
        await _tts.stop();
        await _tts.speak(narration);
      }
    } catch (e) {
      debugPrint('CityExplorer: Narration failed: $e');
      // Non-fatal
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _setError(String message) {
    _status = CityExplorerStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
