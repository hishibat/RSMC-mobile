import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DeepgramService {
  final String apiKey;
  final String language;
  final void Function(String text) onTranscript;
  final void Function(String error) onError;

  WebSocketChannel? _channel;
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _audioSubscription;

  DeepgramService({
    required this.apiKey,
    required this.language,
    required this.onTranscript,
    required this.onError,
  });

  Future<void> startStreaming() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      onError('マイクのアクセス許可がありません');
      return;
    }

    // Connect to Deepgram WebSocket
    final uri = Uri.parse(
      'wss://api.deepgram.com/v1/listen'
      '?model=nova-2'
      '&language=$language'
      '&encoding=linear16'
      '&sample_rate=16000'
      '&channels=1'
      '&punctuate=true'
      '&interim_results=true',
    );

    _channel = WebSocketChannel.connect(
      uri,
      protocols: ['token', apiKey],
    );

    // Listen for transcription results
    _channel!.stream.listen(
      (data) {
        try {
          final json = jsonDecode(data as String) as Map<String, dynamic>;
          final channel = json['channel'] as Map<String, dynamic>?;
          if (channel == null) return;

          final alternatives =
              (channel['alternatives'] as List<dynamic>?) ?? [];
          if (alternatives.isEmpty) return;

          final transcript = alternatives[0]['transcript'] as String? ?? '';
          final isFinal = json['is_final'] as bool? ?? false;

          if (isFinal && transcript.isNotEmpty) {
            onTranscript(transcript);
          }
        } catch (e) {
          // Ignore parse errors for non-transcript messages
        }
      },
      onError: (error) {
        onError('WebSocket error: $error');
      },
      onDone: () {
        // Connection closed
      },
    );

    // Start recording and stream audio
    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
    );

    _audioSubscription = stream.listen((data) {
      _channel?.sink.add(data);
    });
  }

  Future<void> stopStreaming() async {
    _audioSubscription?.cancel();
    _audioSubscription = null;

    // Send close message to Deepgram
    _channel?.sink.add(jsonEncode({'type': 'CloseStream'}));
    await _channel?.sink.close();
    _channel = null;

    await _recorder.stop();
  }
}
