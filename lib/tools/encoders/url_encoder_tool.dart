import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/output_field.dart';
import '../../widgets/action_button.dart';

class UrlEncoderTool extends StatefulWidget {
  final Tool tool;

  const UrlEncoderTool({super.key, required this.tool});

  @override
  State<UrlEncoderTool> createState() => _UrlEncoderToolState();
}

class _UrlEncoderToolState extends State<UrlEncoderTool> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  bool _isEncoding = true;

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _encode() {
    setState(() {
      final input = _inputController.text;
      if (input.isEmpty) {
        _outputController.clear();
        return;
      }
      _outputController.text = Uri.encodeComponent(input);
      HapticFeedback.mediumImpact();
    });
  }

  void _decode() {
    setState(() {
      try {
        final input = _inputController.text;
        if (input.isEmpty) {
          _outputController.clear();
          return;
        }
        _outputController.text = Uri.decodeComponent(input);
        HapticFeedback.mediumImpact();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid URL encoded string')),
        );
      }
    });
  }

  void _clear() {
    setState(() {
      _inputController.clear();
      _outputController.clear();
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
          // Mode Toggle
          _buildModeToggle(),
          const SizedBox(height: 24),

          InputField(
            label: _isEncoding ? 'Text to Encode' : 'URL to Decode',
            hint: _isEncoding
                ? 'Enter text to URL encode...'
                : 'Enter URL encoded string...',
            controller: _inputController,
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: _isEncoding ? 'Encode' : 'Decode',
                  icon: _isEncoding ? Icons.link : Icons.link_off,
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
            label: _isEncoding ? 'Encoded URL' : 'Decoded Text',
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
