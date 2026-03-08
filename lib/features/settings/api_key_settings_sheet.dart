import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/ai_provider.dart';

class ApiKeySettingsSheet extends ConsumerStatefulWidget {
  const ApiKeySettingsSheet({super.key});

  @override
  ConsumerState<ApiKeySettingsSheet> createState() => _ApiKeySettingsSheetState();
}

class _ApiKeySettingsSheetState extends ConsumerState<ApiKeySettingsSheet> {
  final _googleController = TextEditingController();
  final _openAiController = TextEditingController();
  final _claudeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  Future<void> _loadKeys() async {
    final storage = ref.read(secureStorageProvider);
    _googleController.text = (await storage.getGoogleApiKey()) ?? '';
    _openAiController.text = (await storage.getOpenAiKey()) ?? '';
    _claudeController.text = (await storage.getClaudeKey()) ?? '';
  }

  Future<void> _saveKeys() async {
    // Validate: warn if all fields are empty
    final googleKey = _googleController.text.trim();
    final openAiKey = _openAiController.text.trim();
    final claudeKey = _claudeController.text.trim();

    if (googleKey.isEmpty && openAiKey.isEmpty && claudeKey.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('최소 하나의 API 키를 입력해 주세요.', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Validate key formats (basic length check)
    if (openAiKey.isNotEmpty && (!openAiKey.startsWith('sk-') || openAiKey.length < 20)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OpenAI API 키 형식이 올바르지 않습니다. (sk- 로 시작해야 합니다)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final storage = ref.read(secureStorageProvider);
    await storage.saveGoogleApiKey(googleKey);
    await storage.saveOpenAiKey(openAiKey);
    await storage.saveClaudeKey(claudeKey);

    if (mounted) {
      ref.invalidate(currentApiKeyProvider);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API 키가 안전하게 저장되었습니다.', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Color(0xFF00FFD1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: Colors.white24),
      ),
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white38, borderRadius: BorderRadius.circular(2)))
            ),
            const SizedBox(height: 16),
            const Center(child: Text("AI API Keys", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
            _buildKeyField("Google Gemini API Key", _googleController, Icons.auto_awesome),
            const SizedBox(height: 16),
            _buildKeyField("OpenAI API Key", _openAiController, Icons.psychology),
            const SizedBox(height: 16),
            _buildKeyField("Claude API Key", _claudeController, Icons.memory),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FFD1),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                ),
                onPressed: _saveKeys,
                child: const Text("Save Keys & Apply", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        prefixIcon: Icon(icon, color: const Color(0xFF00FFD1)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF00FFD1)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
