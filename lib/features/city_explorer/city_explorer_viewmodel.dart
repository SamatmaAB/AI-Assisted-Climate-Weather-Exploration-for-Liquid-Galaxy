import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/features/city_explorer/models/city_landmark.dart';
import 'package:lg_connection/features/city_explorer/models/weather_data.dart';
import 'package:lg_connection/features/city_explorer/services/city_explorer_balloon_service.dart';
import 'package:lg_connection/features/city_explorer/services/geocoding_service.dart';
import 'package:lg_connection/features/city_explorer/services/weather_service.dart';
import 'package:lg_connection/models/lookat_model.dart';
import 'package:lg_connection/services/ai/api_key_storage.dart';
import 'package:lg_connection/services/ai/prompts/ai_prompts.dart';
import 'package:lg_connection/services/tts/tts_service.dart';
import 'package:lg_connection/shared/services/cache_service.dart';
import 'package:lg_connection/shared/services/map_sync_service.dart';
import 'package:lg_connection/shared/services/orbit_service.dart';

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

enum CityExplorerStatus { idle, loading, success, error }

class CityExplorerViewModel extends ChangeNotifier {
  final LGSSHClient _sshClient = LGSSHClient();
  final MapSyncService _mapSyncService = MapSyncService();
  final WeatherService _weatherService = WeatherService();
  final GeocodingService _geocodingService = GeocodingService();
  final CityExplorerBalloonService _balloonService = CityExplorerBalloonService();
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

  Future<void> exploreCity(String city) async {
    final trimmed = city.trim();
    if (trimmed.isEmpty) {
      _setError('Please enter a city name.');
      return;
    }

    await _tts.stop();

    _status = CityExplorerStatus.loading;
    _errorMessage = '';
    _narration = '';
    notifyListeners();

    _balloonService.clearBalloon(_sshClient);

    if (OrbitService().isOrbiting) {
      await OrbitService().stopOrbit();
      notifyListeners();
    }

    try {
      
      final resolved = await _resolveLandmark(trimmed);
      if (resolved == null) return; 
      _landmark = resolved;
      notifyListeners();

      _cinematicFlyTo(resolved);

      WeatherData? weather;
      try {
        weather = await _weatherService.fetchWeather(resolved.latitude, resolved.longitude);
        _weather = weather;
        notifyListeners();
      } catch (e) {
        debugPrint('CityExplorer: Weather fetch failed: $e');
      }

      _status = CityExplorerStatus.success;
      notifyListeners();

      _fetchAndNarrate(resolved, weather);
    } catch (e) {
      debugPrint('CityExplorer: Unexpected error: $e');
      _setError('Something went wrong. Please try again.');
    }
  }

  Future<CityLandmark?> _resolveLandmark(String city) async {
    
    final cached = CacheService.getCityLandmark(city);
    if (cached != null) {
      try {
        final map = json.decode(cached) as Map<String, dynamic>;
        return CityLandmark.fromJson(map);
      } catch (_) {
        
      }
    }

    final apiKey = await _apiKeyStorage.getGeminiApiKey();
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final modelName = await _apiKeyStorage.getSelectedModel();
        final model = GenerativeModel(
          model: modelName,
          apiKey: apiKey,
          systemInstruction: Content.system(AIPrompts.cityLandmark),
        );
        final response = await model
            .generateContent([Content.text('City: $city')])
            .timeout(const Duration(seconds: 4));
        final text = (response.text ?? '').trim();

        final cleaned = _stripCodeFences(text);
        final jsonMap = json.decode(cleaned) as Map<String, dynamic>;

        if (!jsonMap.containsKey('error')) {
          final resolved = CityLandmark.fromJson(jsonMap);
          await CacheService.saveCityLandmark(city, json.encode(jsonMap));
          return resolved;
        }
      } catch (e) {
        debugPrint(
          'CityExplorer: Gemini landmark resolution slow or failed ($e). Falling back to OpenStreetMap.',
        );
      }
    } else {
      debugPrint(
        'CityExplorer: Gemini API key not configured. Using OpenStreetMap Nominatim geocoding...',
      );
    }

    final fallback = await _geocodingService.geocodeCity(city);
    if (fallback != null) {
      await CacheService.saveCityLandmark(city, json.encode(fallback.toJson()));
      return fallback;
    }

    _setError('City not found. Try a different spelling or city.');
    return null;
  }

  String _stripCodeFences(String text) {
    var s = text.trim();
    if (s.startsWith('```')) {
      s = s.replaceFirst(RegExp(r'^```[a-z]*\n?'), '');
      s = s.replaceFirst(RegExp(r'```$'), '');
    }
    return s.trim();
  }

  Future<void> _cinematicFlyTo(CityLandmark resolved) async {
    try {
      
      await _mapSyncService.flyTo(LookAt(
        latitude: resolved.latitude,
        longitude: resolved.longitude,
        zoom: _rangeToZoom(LandmarkCameraPreset.overview.range),
        tilt: LandmarkCameraPreset.overview.tilt,
        bearing: LandmarkCameraPreset.overview.heading,
      ));
      await Future.delayed(const Duration(milliseconds: 3500));

      await _mapSyncService.flyTo(LookAt(
        latitude: resolved.latitude,
        longitude: resolved.longitude,
        zoom: _rangeToZoom(LandmarkCameraPreset.approach.range),
        tilt: LandmarkCameraPreset.approach.tilt,
        bearing: LandmarkCameraPreset.approach.heading,
      ));
      await Future.delayed(const Duration(milliseconds: 3500));

      await _mapSyncService.flyTo(LookAt(
        latitude: resolved.latitude,
        longitude: resolved.longitude,
        zoom: _rangeToZoom(LandmarkCameraPreset.groundLevel.range),
        tilt: LandmarkCameraPreset.groundLevel.tilt,
        bearing: LandmarkCameraPreset.groundLevel.heading,
      ));

      await _startOrbit();
    } catch (e) {
      debugPrint('CityExplorer: Fly-to failed: $e');
    }
  }

  bool get isOrbiting => OrbitService().isOrbiting;

  Future<void> _startOrbit() async {
    await OrbitService().startOrbit();
    notifyListeners();
  }

  Future<void> stopOrbit() async {
    await OrbitService().stopOrbit();
    notifyListeners();
  }

  Future<void> toggleOrbit() async {
    if (OrbitService().isOrbiting) {
      await stopOrbit();
    } else {
      await _startOrbit();
    }
  }

  double _rangeToZoom(double rangeMeters) {
    final zoom = (math.log(591657550.5 / rangeMeters) / math.log(2)) + 1.0 - 3.8;
    return zoom.clamp(1.0, 21.0);
  }

  Future<void> _fetchAndNarrate(CityLandmark resolved, WeatherData? weather) async {
    String narration = '';
    try {
      final apiKey = await _apiKeyStorage.getGeminiApiKey();
      if (apiKey != null && apiKey.isNotEmpty) {
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
        final response = await model
            .generateContent([Content.text(prompt)])
            .timeout(const Duration(seconds: 10));
        narration = (response.text ?? '').trim();
      }
    } catch (e) {
      debugPrint('CityExplorer: Narration failed or timed out: $e');
    }

    if (narration.isEmpty) {
      narration = 'Welcome to ${resolved.city}! Currently experiencing '
          '${weather?.condition ?? 'clear conditions'} with a temperature of '
          '${weather?.temperature.toStringAsFixed(1) ?? '20'}°C near ${resolved.landmark}.';
    }

    _narration = narration;
    notifyListeners();
    try {
      await _tts.stop();
      await _tts.speak(narration);
    } catch (e) {
      debugPrint('CityExplorer: TTS speak error: $e');
    }

    if (weather != null) {
      _balloonService.deployBalloon(
        landmark: resolved,
        weather: weather,
        narration: narration,
        lgClient: _sshClient,
      );
    }
  }

  void _setError(String message) {
    _status = CityExplorerStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    OrbitService().dispose();
    _tts.stop();
    super.dispose();
  }
}
