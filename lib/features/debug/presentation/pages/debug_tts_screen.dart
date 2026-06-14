import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/gemini_service.dart';
import '../../../../services/tts_service.dart';

class DebugTtsScreen extends StatefulWidget {
  const DebugTtsScreen({super.key});

  @override
  State<DebugTtsScreen> createState() => _DebugTtsScreenState();
}

class _DebugTtsScreenState extends State<DebugTtsScreen> {
  final GeminiService _geminiService = GeminiService();
  final TtsService _ttsService = TtsService();

  String _geminiStatus = 'Idle';
  String _ttsStatus = 'Idle';
  String _lastResponse = 'None';
  bool _isLoading = false;

  Future<void> _testGeminiOnly() async {
    setState(() {
      _isLoading = true;
      _geminiStatus = 'Calling Gemini...';
      _lastResponse = '';
    });

    try {
      final response = await _geminiService.generateMotivationalMessage(
        remainingTime: const Duration(seconds: 10),
        checkpointType: '10seconds',
        sessionType: 'Debug',
      );
      setState(() {
        _lastResponse = response;
        _geminiStatus = 'Success';
      });
    } catch (e) {
      setState(() {
        _geminiStatus = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testTtsOnly() async {
    setState(() {
      _isLoading = true;
      _ttsStatus = 'Speaking...';
    });

    try {
      final text = _lastResponse.isNotEmpty && _lastResponse != 'None' 
          ? _lastResponse 
          : "This is a TTS test. Your engine is working perfectly.";
      
      await _ttsService.speak(text);
      setState(() {
        _ttsStatus = 'Finished Speaking';
      });
    } catch (e) {
      setState(() {
        _ttsStatus = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testFullPipeline() async {
    setState(() {
      _isLoading = true;
      _geminiStatus = 'Generating...';
      _ttsStatus = 'Waiting...';
    });

    try {
      final response = await _geminiService.generateMotivationalMessage(
        remainingTime: const Duration(seconds: 0),
        checkpointType: 'completed',
        sessionType: 'Debug',
      );
      
      setState(() {
        _lastResponse = response;
        _geminiStatus = 'Success';
        _ttsStatus = 'Speaking...';
      });

      await _ttsService.speak(response);

      setState(() {
        _ttsStatus = 'Finished Speaking';
      });
    } catch (e) {
      setState(() {
        _geminiStatus = 'Pipeline Error';
        _ttsStatus = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('TTS & Gemini Debug'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Diagnostics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('TTS Engine Available: ${_ttsService.isEngineAvailable ? "Yes" : "No / Checking..."}', style: TextStyle(color: _ttsService.isEngineAvailable ? Colors.green : Colors.orange)),
                  const Divider(),
                  Text('Gemini Status: $_geminiStatus'),
                  Text('TTS Status: $_ttsStatus'),
                  const SizedBox(height: 8),
                  Text('Latest Response:', style: TextStyle(color: Colors.white70)),
                  Text(_lastResponse, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _testGeminiOnly,
              child: const Text('Test Gemini API Only'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _testTtsOnly,
              child: const Text('Test TTS Only'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              onPressed: _isLoading ? null : _testFullPipeline,
              child: const Text('Test Full Pipeline (Gemini → TTS)', style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold)),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: CircularProgressIndicator()),
              )
          ],
        ),
      ),
    );
  }
}
