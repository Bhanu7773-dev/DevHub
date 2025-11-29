import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/output_field.dart';
import '../../widgets/action_button.dart';

class UrlValidatorTool extends StatefulWidget {
  final Tool tool;

  const UrlValidatorTool({super.key, required this.tool});

  @override
  State<UrlValidatorTool> createState() => _UrlValidatorToolState();
}

class _UrlValidatorToolState extends State<UrlValidatorTool> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _validate() {
    final urlString = _inputController.text.trim();
    if (urlString.isEmpty) return;

    try {
      final uri = Uri.parse(urlString);
      if (!uri.hasScheme) {
        throw FormatException('Missing scheme');
      }

      String result = 'Status: Valid\n\n';
      result += 'Scheme: ${uri.scheme}\n';
      result += 'Host: ${uri.host}\n';
      result += 'Path: ${uri.path}\n';
      if (uri.hasQuery) result += 'Query: ${uri.query}\n';
      if (uri.hasFragment) result += 'Fragment: ${uri.fragment}\n';
      if (uri.hasPort) result += 'Port: ${uri.port}\n';

      setState(() {
        _outputController.text = result;
        HapticFeedback.mediumImpact();
      });
    } catch (e) {
      setState(() {
        _outputController.text =
            'Status: Invalid\n\nReason: Malformed URL or missing scheme (e.g., https://)';
        HapticFeedback.mediumImpact();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolDetailScreen(
      tool: widget.tool,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputField(
            label: 'URL',
            hint: 'https://example.com/path?query=1',
            controller: _inputController,
          ),
          const SizedBox(height: 16),
          ActionButton(
            label: 'Validate & Parse',
            icon: Icons.link,
            onPressed: _validate,
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          OutputField(
            label: 'Result',
            controller: _outputController,
            maxLines: 8,
          ),
        ],
      ),
    );
  }
}
