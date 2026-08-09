import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TtsState {
  idle,
  speaking,
  paused,
  stopped,
  error,
}

class TtsService extends ChangeNotifier {
  static final TtsService _instance = TtsService._internal();
  static TtsService get instance => _instance;

  TtsService._internal();
  factory TtsService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();

  TtsState _state = TtsState.idle;
  TtsState get state => _state;

  String? _currentText;
  String? get currentText => _currentText;

  String _currentWord = '';
  String get currentWord => _currentWord;

  int _wordStart = 0;
  int get wordStart => _wordStart;

  int _wordEnd = 0;
  int get wordEnd => _wordEnd;

  final String _language = 'en-US';
  String get language => _language;

  double _speechRate = 0.5;
  double get speechRate => _speechRate;

  double _pitch = 1.0;
  double get pitch => _pitch;

  double _volume = 1.0;
  double get volume => _volume;

  bool _autoNarrate = true;
  bool get autoNarrate => _autoNarrate;

  List<Map<String, String>> _availableVoices = [];
  List<Map<String, String>> get availableVoices => List.unmodifiable(_availableVoices);

  Map<String, String>? _selectedVoice;
  Map<String, String>? get selectedVoice => _selectedVoice;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    _autoNarrate = prefs.getBool('tts_auto_narrate') ?? true;
    _speechRate = prefs.getDouble('tts_speech_rate') ?? 0.5;
    _pitch = prefs.getDouble('tts_pitch') ?? 1.0;
    _volume = prefs.getDouble('tts_volume') ?? 1.0;

    _flutterTts.setStartHandler(() {
      _state = TtsState.speaking;
      notifyListeners();
    });

    _flutterTts.setCompletionHandler(() {
      _state = TtsState.idle;
      _currentText = null;
      _currentWord = '';
      _wordStart = 0;
      _wordEnd = 0;
      notifyListeners();
    });

    _flutterTts.setCancelHandler(() {
      _state = TtsState.stopped;
      _currentText = null;
      _currentWord = '';
      _wordStart = 0;
      _wordEnd = 0;
      notifyListeners();
    });

    _flutterTts.setPauseHandler(() {
      _state = TtsState.paused;
      notifyListeners();
    });

    _flutterTts.setContinueHandler(() {
      _state = TtsState.speaking;
      notifyListeners();
    });

    _flutterTts.setErrorHandler((msg) {
      _state = TtsState.error;
      _currentText = null;
      _currentWord = '';
      _wordStart = 0;
      _wordEnd = 0;
      notifyListeners();
    });

    _flutterTts.setProgressHandler((String text, int start, int end, String word) {
      _wordStart = start;
      _wordEnd = end;
      _currentWord = word;
      notifyListeners();
    });

    try {
      await _flutterTts.setLanguage(_language);
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setPitch(_pitch);
      await _flutterTts.setVolume(_volume);
      await _flutterTts.awaitSpeakCompletion(true);

      final voices = await _flutterTts.getVoices;
      if (voices is List) {
        final allVoices = voices
            .whereType<Map>()
            .map((v) => <String, String>{
                  'name': (v['name'] ?? '').toString(),
                  'locale': (v['locale'] ?? '').toString(),
                })
            .where((v) => v['name']!.isNotEmpty)
            .toList();

        // Keep only English voices
        final englishVoices = allVoices
            .where((v) =>
                v['locale']!.toLowerCase().startsWith('en'))
            .toList();

        // Separate by gender hints in voice name
        String lowerName(Map<String, String> v) => v['name']!.toLowerCase();
        final femaleVoices = englishVoices
            .where((v) =>
                lowerName(v).contains('female') ||
                lowerName(v).contains('woman'))
            .take(2)
            .toList();
        final maleVoices = englishVoices
            .where((v) =>
                lowerName(v).contains('male') &&
                !lowerName(v).contains('female') ||
                lowerName(v).contains('#male'))
            .take(2)
            .toList();

        if (femaleVoices.isNotEmpty || maleVoices.isNotEmpty) {
          _availableVoices = [...maleVoices, ...femaleVoices];
        } else {
          // Fallback: take first 4 English voices if no gender info
          _availableVoices = englishVoices.take(4).toList();
        }
      }


      final savedVoiceName = prefs.getString('tts_voice_name');
      final savedVoiceLocale = prefs.getString('tts_voice_locale');
      if (savedVoiceName != null && savedVoiceLocale != null) {
        _selectedVoice = {'name': savedVoiceName, 'locale': savedVoiceLocale};
        await _flutterTts.setVoice(_selectedVoice!);
      }
    } catch (e) {
      debugPrint('Error initializing FlutterTts: $e');
    }

    _isInitialized = true;
  }

  String _sanitizeForSpeech(String markdown) {
    String text = markdown;
    text = text.replaceAll(RegExp(r'#{1,6}\s*'), '');
    text = text.replaceAllMapped(RegExp(r'\*\*([^*]+)\*\*'), (match) => match[1] ?? '');
    text = text.replaceAllMapped(RegExp(r'\*([^*]+)\*'), (match) => match[1] ?? '');
    text = text.replaceAllMapped(RegExp(r'__([^_]+)__'), (match) => match[1] ?? '');
    text = text.replaceAllMapped(RegExp(r'_([^_]+)_'), (match) => match[1] ?? '');
    text = text.replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^)]+\)'), (match) => match[1] ?? '');
    text = text.replaceAll(RegExp(r'`{1,3}[^`]*`{1,3}'), '');
    text = text.replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '');
    text = text.replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '');
    return text.trim();
  }

  Future<void> speak(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    if (_state == TtsState.speaking || _state == TtsState.paused) {
      await stop();
    }

    _currentText = trimmedText;
    _currentWord = '';
    _wordStart = 0;
    _wordEnd = 0;
    _state = TtsState.speaking;
    notifyListeners();

    final plainText = _sanitizeForSpeech(trimmedText);
    try {
      await _flutterTts.speak(plainText);
    } catch (e) {
      _state = TtsState.error;
      _currentText = null;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
    }
    _state = TtsState.stopped;
    _currentText = null;
    _currentWord = '';
    _wordStart = 0;
    _wordEnd = 0;
    notifyListeners();
  }

  Future<void> pause() async {
    if (_state == TtsState.speaking) {
      try {
        await _flutterTts.pause();
        _state = TtsState.paused;
        notifyListeners();
      } catch (e) {
        debugPrint('Error pausing TTS: $e');
      }
    }
  }

  Future<void> resume() async {
    if (_state == TtsState.paused && _currentText != null) {
      final plainText = _sanitizeForSpeech(_currentText!);
      try {
        await _flutterTts.speak(plainText);
        _state = TtsState.speaking;
        notifyListeners();
      } catch (e) {
        _state = TtsState.error;
        notifyListeners();
      }
    }
  }

  Future<void> togglePlayPause(String text) async {
    if (isSpeakingText(text)) {
      await pause();
    } else if (isPausedText(text)) {
      await resume();
    } else {
      await speak(text);
    }
  }

  Future<void> setVoice(Map<String, String> voice) async {
    _selectedVoice = voice;
    await _flutterTts.setVoice({'name': voice['name']!, 'locale': voice['locale']!});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tts_voice_name', voice['name']!);
    await prefs.setString('tts_voice_locale', voice['locale']!);
    notifyListeners();
  }

  Future<void> setAutoNarrate(bool value) async {
    _autoNarrate = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tts_auto_narrate', value);
    notifyListeners();
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    await _flutterTts.setSpeechRate(rate);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_speech_rate', rate);
    notifyListeners();
  }

  Future<void> setPitch(double pitch) async {
    _pitch = pitch;
    await _flutterTts.setPitch(pitch);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_pitch', pitch);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _flutterTts.setVolume(volume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_volume', volume);
    notifyListeners();
  }

  bool isSpeakingText(String text) {
    return _state == TtsState.speaking && _currentText == text.trim();
  }

  bool isPausedText(String text) {
    return _state == TtsState.paused && _currentText == text.trim();
  }

  bool isTextActive(String text) {
    return (_state == TtsState.speaking || _state == TtsState.paused) &&
        _currentText == text.trim();
  }
}
