import 'package:flutter/foundation.dart';
import '../services/deepgram_service.dart';
import '../services/claude_service.dart';
import 'settings_provider.dart';

class TranscriptionProvider extends ChangeNotifier {
  DeepgramService? _deepgramService;
  ClaudeService? _claudeService;

  String _transcriptionText = '';
  String _explanationText = '';
  bool _isRecording = false;
  bool _isExplaining = false;
  String _error = '';

  String get transcriptionText => _transcriptionText;
  String get explanationText => _explanationText;
  bool get isRecording => _isRecording;
  bool get isExplaining => _isExplaining;
  String get error => _error;

  void updateSettings(SettingsProvider settings) {
    if (!settings.isLoaded) return;

    if (settings.deepgramApiKey.isNotEmpty) {
      _deepgramService = DeepgramService(
        apiKey: settings.deepgramApiKey,
        language: settings.language,
        onTranscript: _onTranscriptReceived,
        onError: _onError,
      );
    }

    if (settings.claudeApiKey.isNotEmpty) {
      _claudeService = ClaudeService(apiKey: settings.claudeApiKey);
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  void _onTranscriptReceived(String text) {
    if (text.trim().isEmpty) return;
    _transcriptionText += '$text\n';
    notifyListeners();
    _requestExplanation(text);
  }

  void _onError(String error) {
    _error = error;
    notifyListeners();
  }

  Future<void> _requestExplanation(String latestText) async {
    if (_claudeService == null || _isExplaining) return;
    _isExplaining = true;
    notifyListeners();

    try {
      final explanation = await _claudeService!.getExplanation(
        transcription: _transcriptionText,
        latestSegment: latestText,
      );
      _explanationText = explanation;
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('Failed to Fetch') ||
          errorMsg.contains('XMLHttpRequest')) {
        _error =
            'CORSエラー: ブラウザからClaude APIに直接アクセスできません。\n'
            'iOS/Androidネイティブアプリでは正常に動作します。';
      } else {
        _error = 'Claude API error: $e';
      }
    } finally {
      _isExplaining = false;
      notifyListeners();
    }
  }

  Future<void> startRecording() async {
    if (_deepgramService == null) {
      _error = 'Deepgram APIキーが設定されていません';
      notifyListeners();
      return;
    }

    _error = '';
    _transcriptionText = '';
    _explanationText = '';

    try {
      await _deepgramService!.startStreaming();
      _isRecording = true;
    } catch (e) {
      _error = 'Recording error: $e';
    }
    notifyListeners();
  }

  Future<void> stopRecording() async {
    await _deepgramService?.stopStreaming();
    _isRecording = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _deepgramService?.stopStreaming();
    super.dispose();
  }
}
