import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._internal();
  static final TtsService instance = TtsService._internal();
  factory TtsService() => instance;

  late FlutterTts _flutterTts;
  bool _isInitialized = false;
  bool isEngineAvailable = false;
  bool _isSpeaking = false;

  Future<void>? _initFuture;

  Future<void> init() async {
    if (_isInitialized) return;
    _initFuture ??= _initTts();
    await _initFuture;
  }

  Future<void> _initTts() async {
    debugPrint('TTS: Initializing engine...');
    _flutterTts = FlutterTts();
    
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.48);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);
    
    _isInitialized = true;

    try {
      final engines = await _flutterTts.getEngines;
      if (engines == null || engines.isEmpty) {
        debugPrint('TTS Warning: No TTS engines detected. This is common on emulators.');
        isEngineAvailable = false;
      } else {
        isEngineAvailable = true;
        debugPrint('TTS: Available engines: $engines');
        
        final engineStrings = engines.cast<String>();
        const googleEngine = 'com.google.android.tts';
        if (engineStrings.contains(googleEngine)) {
           await _flutterTts.setEngine(googleEngine);
           debugPrint('TTS: Engine Used: $googleEngine');
        } else {
           debugPrint('TTS: Google engine not found. Using default engine.');
        }
      }
    } catch (e) {
      debugPrint('TTS Warning: Could not check engines: $e');
      isEngineAvailable = true; // Optimistic fallback
    }
    debugPrint('TTS Initialized');
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      debugPrint('TTS Error: Service not initialized yet. Call init() first.');
      return;
    }
    if (text.isEmpty) {
      debugPrint('TTS Warning: Received empty text. Nothing to speak.');
      return;
    }
    
    if (_isSpeaking) {
      debugPrint('TTS: Already speaking, stopping previous speech...');
      await stop();
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    try {
      _isSpeaking = true;
      debugPrint('TTS Speech Started: "$text"');
      final result = await _flutterTts.speak(text);
      if (result == 1) {
        debugPrint('TTS Speech Completed: "$text"');
      } else {
        debugPrint('TTS Speech Failed (speak() returned $result)');
      }
    } catch (e) {
      debugPrint('TTS Speech Failed: $e');
    } finally {
      _isSpeaking = false;
    }
  }

  Future<void> stop() async {
    if (!_isInitialized) return;
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      // Ignore
    }
  }
}
