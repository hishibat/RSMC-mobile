import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transcription_provider.dart';
import '../providers/settings_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final transcription = context.watch<TranscriptionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('RSME'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Error banner with dismiss
            if (transcription.error.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Colors.red.shade900,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        transcription.error,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 18),
                      onPressed: () => transcription.clearError(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

            // Not configured banner
            if (!settings.isConfigured && settings.isLoaded)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.orange.shade900,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                  child: const Text(
                    'APIキーが未設定です。設定画面で入力してください。',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

            // Upper half: Transcription
            Expanded(
              flex: 1,
              child: Container(
                color: const Color(0xFF1A1A2E),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.mic, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          '文字起こし',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (transcription.isRecording) const _PulsingDot(),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: SingleChildScrollView(
                        reverse: true,
                        child: SelectableText(
                          transcription.transcriptionText.isEmpty
                              ? '録音を開始すると、ここに文字起こしが表示されます...'
                              : transcription.transcriptionText,
                          style: TextStyle(
                            fontSize: 15,
                            color: transcription.transcriptionText.isEmpty
                                ? Colors.grey
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 1, thickness: 2),

            // Lower half: AI Explanation
            Expanded(
              flex: 1,
              child: Container(
                color: const Color(0xFF16213E),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'AI解説',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (transcription.isExplaining)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: SingleChildScrollView(
                        child: SelectableText(
                          transcription.explanationText.isEmpty
                              ? 'AI解説がここに表示されます...'
                              : transcription.explanationText,
                          style: TextStyle(
                            fontSize: 15,
                            color: transcription.explanationText.isEmpty
                                ? Colors.grey
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: settings.isConfigured
            ? () {
                if (transcription.isRecording) {
                  transcription.stopRecording();
                } else {
                  transcription.startRecording();
                }
              }
            : null,
        backgroundColor: transcription.isRecording
            ? Colors.red
            : Theme.of(context).colorScheme.primary,
        child: Icon(
          transcription.isRecording ? Icons.stop : Icons.mic,
          size: 36,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withValues(alpha: 0.5 + _controller.value * 0.5),
          ),
        );
      },
    );
  }
}
