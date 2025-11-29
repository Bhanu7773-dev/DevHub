import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/output_field.dart';
import '../../widgets/action_button.dart';

class JsonFormatterTool extends StatefulWidget {
  final Tool tool;

  const JsonFormatterTool({super.key, required this.tool});

  @override
  State<JsonFormatterTool> createState() => _JsonFormatterToolState();
}

class _JsonFormatterToolState extends State<JsonFormatterTool> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  String _errorMessage = '';
  int _indentSpaces = 2;

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _format() {
    setState(() {
      _errorMessage = '';
      try {
        final input = _inputController.text.trim();
        if (input.isEmpty) {
          _errorMessage = 'Please enter JSON to format';
          _outputController.clear();
          return;
        }
        final decoded = jsonDecode(input);
        final encoder = JsonEncoder.withIndent(' ' * _indentSpaces);
        _outputController.text = encoder.convert(decoded);
        HapticFeedback.mediumImpact();
      } catch (e) {
        _errorMessage = 'Invalid JSON: ${e.toString()}';
        _outputController.clear();
      }
    });
  }

  void _minify() {
    setState(() {
      _errorMessage = '';
      try {
        final input = _inputController.text.trim();
        if (input.isEmpty) {
          _errorMessage = 'Please enter JSON to minify';
          _outputController.clear();
          return;
        }
        final decoded = jsonDecode(input);
        _outputController.text = jsonEncode(decoded);
        HapticFeedback.mediumImpact();
      } catch (e) {
        _errorMessage = 'Invalid JSON: ${e.toString()}';
        _outputController.clear();
      }
    });
  }

  void _validate() {
    setState(() {
      _errorMessage = '';
      try {
        final input = _inputController.text.trim();
        if (input.isEmpty) {
          _errorMessage = 'Please enter JSON to validate';
          return;
        }
        jsonDecode(input);
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Valid JSON! ✓'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        _errorMessage = 'Invalid JSON: ${e.toString()}';
      }
    });
  }

  void _clear() {
    setState(() {
      _inputController.clear();
      _outputController.clear();
      _errorMessage = '';
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
          // Indent Selector
          _buildIndentSelector(),
          const SizedBox(height: 24),

          InputField(
            label: 'JSON Input',
            hint: '{"key": "value"}',
            controller: _inputController,
            maxLines: 8,
            errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
            onChanged: (_) {
              if (_errorMessage.isNotEmpty) {
                setState(() => _errorMessage = '');
              }
            },
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionButton(
                label: 'Format',
                icon: Icons.code,
                onPressed: _format,
                isPrimary: true,
              ),
              ActionButton(
                label: 'Minify',
                icon: Icons.compress,
                onPressed: _minify,
              ),
              ActionButton(
                label: 'Validate',
                icon: Icons.check_circle_outline,
                onPressed: _validate,
              ),
              ActionButton(
                label: 'Clear',
                icon: Icons.clear,
                onPressed: _clear,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Error Message
          // Error Message removed as it's now in InputField

          // Output Field
          OutputField(
            label: 'Formatted JSON',
            controller: _outputController,
            maxLines: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildIndentSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text(
            'Indent:',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(width: 16),
          ...List.generate(4, (index) {
            final spaces = (index + 1) * 2;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildIndentButton(spaces),
            );
          }),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildIndentButton(int spaces) {
    final isSelected = _indentSpaces == spaces;
    return GestureDetector(
      onTap: () {
        setState(() => _indentSpaces = spaces);
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$spaces',
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // _buildErrorMessage removed
}
