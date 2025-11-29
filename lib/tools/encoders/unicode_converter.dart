import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/output_field.dart';
import '../../widgets/action_button.dart';

class UnicodeConverterTool extends StatefulWidget {
  final Tool tool;

  const UnicodeConverterTool({super.key, required this.tool});

  @override
  State<UnicodeConverterTool> createState() => _UnicodeConverterToolState();
}

class _UnicodeConverterToolState extends State<UnicodeConverterTool> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  bool _isEncoding = true;

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _toUnicode() {
    setState(() {
      final text = _inputController.text;
      final result = text.runes
          .map((r) => '\\u${r.toRadixString(16).padLeft(4, '0')}')
          .join();
      _outputController.text = result;
      HapticFeedback.mediumImpact();
    });
  }

  void _fromUnicode() {
    setState(() {
      try {
        final input = _inputController.text;
        final result = input.replaceAllMapped(
          RegExp(r'\\u([0-9a-fA-F]{4})'),
          (match) => String.fromCharCode(int.parse(match.group(1)!, radix: 16)),
        );
        _outputController.text = result;
        HapticFeedback.mediumImpact();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid Unicode format')));
      }
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
            label: _isEncoding ? 'Text' : 'Unicode',
            hint: _isEncoding
                ? 'Enter text...'
                : 'Enter \\u0048\\u0065\\u006c\\u006c\\u006f',
            controller: _inputController,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: _isEncoding ? 'To Unicode' : 'From Unicode',
                  icon: Icons.transform,
                  onPressed: _isEncoding ? _toUnicode : _fromUnicode,
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 12),
              ActionButton(
                label: 'Clear',
                icon: Icons.clear,
                onPressed: () {
                  setState(() {
                    _inputController.clear();
                    _outputController.clear();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutputField(
            label: _isEncoding ? 'Unicode' : 'Text',
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
          Expanded(child: _buildModeButton('To Unicode', true)),
          Expanded(child: _buildModeButton('From Unicode', false)),
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
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
