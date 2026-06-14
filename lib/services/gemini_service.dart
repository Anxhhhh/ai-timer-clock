import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  GeminiService() {
    try {
      if (dotenv.isInitialized) {
        final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
        if (apiKey.isNotEmpty) {
          _model = GenerativeModel(
            model: 'gemini-2.5-flash',
            apiKey: apiKey,
          );
        }
      } else {
        debugPrint('Gemini Warning: dotenv not initialized. AI will use fallback.');
      }
    } catch (e) {
      debugPrint('Gemini Warning: Could not read API key: $e');
    }
  }

  GenerativeModel? _model;

  /// Generates a motivational message based on the current checkpoint.
  Future<String> generateMotivationalMessage({
    required Duration remainingTime,
    required String checkpointType,
    required String sessionType,
  }) async {
    // If model couldn't initialize (e.g. no API key), return fallback immediately.
    if (_model == null) {
      debugPrint('Gemini Error: Model not initialized (missing API key). Using fallback.');
      return getFallbackMessage(checkpointType);
    }

    String prompt;
    switch (checkpointType) {
      case 'halfway':
        prompt = 'Generate a short motivational message for someone who is halfway through a $sessionType focus session. Maximum 15 words.';
        break;
      case '10seconds':
        prompt = 'Generate a short message for someone who has only 10 seconds remaining in their $sessionType focus session. Maximum 15 words.';
        break;
      case 'completed':
        prompt = 'Generate a short congratulatory message for someone who completed a $sessionType focus session. Maximum 15 words.';
        break;
      default:
        prompt = 'Say a short motivational sentence. Maximum 15 words.';
    }

    try {
      // Add a timeout to prevent hanging network calls indefinitely.
      final response = await _model!.generateContent([Content.text(prompt)]).timeout(const Duration(seconds: 8));
      final text = response.text?.trim();
      
      if (text != null && text.isNotEmpty) {
        debugPrint('Gemini Response Received: $text');
        return text;
      } else {
        debugPrint('Gemini Error: Received empty or null response. Using fallback.');
      }
    } catch (e) {
      debugPrint('Gemini Error: Exception during generation - $e. Using fallback.');
      // Network error, timeout, or parsing error -> fallback
    }

    return getFallbackMessage(checkpointType);
  }

  String getFallbackMessage(String checkpointType) {
    switch (checkpointType) {
      case 'halfway':
        return "You're halfway there. Keep going.";
      case '10seconds':
        return "10 seconds remaining.";
      case 'completed':
        return "Time's up. Great work.";
      default:
        return "Keep focusing.";
    }
  }
}
