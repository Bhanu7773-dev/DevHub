import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crypto/crypto.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/action_button.dart';
import '../../utils/app_theme.dart';

class HashGeneratorTool extends StatefulWidget {
  final Tool tool;

  const HashGeneratorTool({super.key, required this.tool});

  @override
  State<HashGeneratorTool> createState() => _HashGeneratorToolState();
}

class _HashGeneratorToolState extends State<HashGeneratorTool> {
  final TextEditingController _inputController = TextEditingController();
  final Map<String, TextEditingController> _outputControllers = {
    'MD5': TextEditingController(),
    'SHA-1': TextEditingController(),
    'SHA-256': TextEditingController(),
    'SHA-512': TextEditingController(),
  };

  @override
  void dispose() {
    _inputController.dispose();
    _outputControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _generateHashes() {
    final input = _inputController.text;
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text to hash')),
      );
      return;
    }

    final bytes = utf8.encode(input);

    setState(() {
      _outputControllers['MD5']!.text = md5.convert(bytes).toString();
      _outputControllers['SHA-1']!.text = sha1.convert(bytes).toString();
      _outputControllers['SHA-256']!.text = sha256.convert(bytes).toString();
      _outputControllers['SHA-512']!.text = sha512.convert(bytes).toString();
      HapticFeedback.mediumImpact();
    });
  }

  void _clear() {
    setState(() {
      _inputController.clear();
      _outputControllers.values.forEach((controller) => controller.clear());
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return ToolDetailScreen(
      tool: widget.tool,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputField(
            label: 'Text to Hash',
            hint: 'Enter your text here...',
            controller: _inputController,
            maxLines: 4,
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: 'Generate Hashes',
                  icon: Icons.tag,
                  onPressed: _generateHashes,
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 12),
              ActionButton(
                label: 'Clear',
                icon: Icons.clear,
                onPressed: _clear,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Hash Outputs
          ..._outputControllers.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildHashOutput(entry.key, entry.value),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHashOutput(String algorithm, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: controller.text.isNotEmpty
              ? AppTheme.primaryColor.withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                algorithm,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (controller.text.isNotEmpty)
                TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: controller.text),
                    );
                    if (context.mounted) {
                      HapticFeedback.mediumImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$algorithm hash copied!'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppTheme.primaryColor,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            controller.text.isEmpty ? 'Hash will appear here' : controller.text,
            style: TextStyle(
              color: controller.text.isEmpty ? Colors.white38 : Colors.white,
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }
}
