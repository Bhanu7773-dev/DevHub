import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/output_field.dart';
import '../../widgets/action_button.dart';

class HtmlEncoderTool extends StatefulWidget {
  final Tool tool;

  const HtmlEncoderTool({super.key, required this.tool});

  @override
  State<HtmlEncoderTool> createState() => _HtmlEncoderToolState();
}

class _HtmlEncoderToolState extends State<HtmlEncoderTool> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  bool _isEncoding = true;

  final Map<String, String> _htmlEntities = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#39;',
  };

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _encode() {
    setState(() {
      String result = _inputController.text;
      _htmlEntities.forEach((char, entity) {
        result = result.replaceAll(char, entity);
      });
      _outputController.text = result;
      HapticFeedback.mediumImpact();
    });
  }

  void _decode() {
    setState(() {
      String result = _inputController.text;
      // Decode in reverse order - &amp; must be decoded LAST
      // to avoid double-decoding issues like &amp;lt; -> &lt; -> <
      final reverseEntities = {
        '&#39;': "'",
        '&quot;': '"',
        '&gt;': '>',
        '&lt;': '<',
        '&amp;': '&',
      };
      reverseEntities.forEach((entity, char) {
        result = result.replaceAll(entity, char);
      });
      _outputController.text = result;
      HapticFeedback.mediumImpact();
    });
  }

  void _clear() {
    setState(() {
      _inputController.clear();
      _outputController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ToolDetailScreen(
      tool: widget.tool,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildModeToggle(),
          const SizedBox(height: 24),
          InputField(
            label: _isEncoding ? 'Text to Encode' : 'HTML to Decode',
            hint: _isEncoding ? 'Enter text...' : 'Enter HTML entities...',
            controller: _inputController,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: _isEncoding ? 'Encode' : 'Decode',
                  icon: Icons.code,
                  onPressed: _isEncoding ? _encode : _decode,
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
          const SizedBox(height: 16),
          OutputField(
            label: _isEncoding ? 'Encoded HTML' : 'Decoded Text',
            controller: _outputController,
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(child: _buildModeButton('Encode', true)),
          Expanded(child: _buildModeButton('Decode', false)),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildModeButton(String label, bool isEncode) {
    final isSelected = _isEncoding == isEncode;
    return GestureDetector(
      onTap: () {
        if (_isEncoding != isEncode) {
          setState(() => _isEncoding = isEncode);
          HapticFeedback.selectionClick();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                )
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
