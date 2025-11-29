import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/output_field.dart';
import '../../widgets/action_button.dart';

class JwtDecoderTool extends StatefulWidget {
  final Tool tool;

  const JwtDecoderTool({super.key, required this.tool});

  @override
  State<JwtDecoderTool> createState() => _JwtDecoderToolState();
}

class _JwtDecoderToolState extends State<JwtDecoderTool> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _headerController = TextEditingController();
  final TextEditingController _payloadController = TextEditingController();
  String _errorMessage = '';

  @override
  void dispose() {
    _inputController.dispose();
    _headerController.dispose();
    _payloadController.dispose();
    super.dispose();
  }

  void _decode() {
    setState(() {
      _errorMessage = '';
      try {
        final jwt = _inputController.text.trim();
        if (jwt.isEmpty) {
          _errorMessage = 'Please enter a JWT token';
          return;
        }

        final parts = jwt.split('.');
        if (parts.length != 3) {
          _errorMessage = 'Invalid JWT format';
          return;
        }

        // Decode header
        final header = _decodeBase64(parts[0]);
        final headerJson = jsonDecode(header);
        _headerController.text = const JsonEncoder.withIndent('  ').convert(headerJson);

        // Decode payload
        final payload = _decodeBase64(parts[1]);
        final payloadJson = jsonDecode(payload);
        _payloadController.text = const JsonEncoder.withIndent('  ').convert(payloadJson);

        HapticFeedback.mediumImpact();
      } catch (e) {
        _errorMessage = 'Invalid JWT token: ${e.toString()}';
        _headerController.clear();
        _payloadController.clear();
      }
    });
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Invalid base64 string');
    }
    return utf8.decode(base64.decode(output));
  }

  void _clear() {
    setState(() {
      _inputController.clear();
      _headerController.clear();
      _payloadController.clear();
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ToolDetailScreen(
      tool: widget.tool,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputField(
            label: 'JWT Token',
            hint: 'Paste your JWT token here...',
            controller: _inputController,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: 'Decode',
                  icon: Icons.lock_open,
                  onPressed: _decode,
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 12),
              ActionButton(label: 'Clear', icon: Icons.clear, onPressed: _clear),
            ],
          ),
          const SizedBox(height: 16),
          if (_errorMessage.isNotEmpty) _buildErrorMessage(),
          OutputField(label: 'Header', controller: _headerController, maxLines: 5),
          const SizedBox(height: 16),
          OutputField(label: 'Payload', controller: _payloadController, maxLines: 8),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(_errorMessage, style: const TextStyle(color: Colors.red))),
        ],
      ),
    ).animate().shake(duration: 400.ms).fadeIn();
  }
}
