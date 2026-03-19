import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _deepgramController;
  late TextEditingController _claudeController;

  @override
  void initState() {
    super.initState();
    _deepgramController = TextEditingController();
    _claudeController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<SettingsProvider>();
      _deepgramController.text = settings.deepgramApiKey;
      _claudeController.text = settings.claudeApiKey;
    });
  }

  @override
  void dispose() {
    _deepgramController.dispose();
    _claudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Deepgram API Key
          const Text(
            'Deepgram API Key',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _deepgramController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Deepgram APIキーを入力',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.key),
            ),
            onChanged: (value) => settings.setDeepgramApiKey(value),
          ),

          const SizedBox(height: 24),

          // Claude API Key
          const Text(
            'Claude API Key',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _claudeController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Claude APIキーを入力',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.key),
            ),
            onChanged: (value) => settings.setClaudeApiKey(value),
          ),

          const SizedBox(height: 24),

          // Language Selection
          const Text(
            '言語 / Language',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'ja', label: Text('日本語')),
              ButtonSegment(value: 'en', label: Text('English')),
            ],
            selected: {settings.language},
            onSelectionChanged: (selected) {
              settings.setLanguage(selected.first);
            },
          ),

          const SizedBox(height: 32),

          // Status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ステータス',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _StatusRow(
                    label: 'Deepgram',
                    isSet: settings.deepgramApiKey.isNotEmpty,
                  ),
                  _StatusRow(
                    label: 'Claude',
                    isSet: settings.claudeApiKey.isNotEmpty,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final bool isSet;

  const _StatusRow({required this.label, required this.isSet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isSet ? Icons.check_circle : Icons.cancel,
            color: isSet ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text('$label APIキー: ${isSet ? "設定済み" : "未設定"}'),
        ],
      ),
    );
  }
}
