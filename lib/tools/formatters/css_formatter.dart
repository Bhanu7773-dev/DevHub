import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/output_field.dart';
import '../../widgets/action_button.dart';

class CssFormatterTool extends StatefulWidget {
  final Tool tool;

  const CssFormatterTool({super.key, required this.tool});

  @override
  State<CssFormatterTool> createState() => _CssFormatterToolState();
}

class _CssFormatterToolState extends State<CssFormatterTool> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _format() {
    final input = _inputController.text.trim();
    if (input.isEmpty) return;

    String result = input
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('{', ' {\n  ')
        .replaceAll('}', '\n}\n')
        .replaceAll(';', ';\n  ')
        .replaceAll(RegExp(r'\n\s+\n'), '\n');

    setState(() {
      _outputController.text = result.trim();
      HapticFeedback.mediumImpact();
    });
  }

  void _minify() {
    final input = _inputController.text.trim();
    if (input.isEmpty) return;

    final result = input
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\s*([{}:;,])\s*'), r'\1');

    setState(() {
      _outputController.text = result;
      HapticFeedback.mediumImpact();
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
            label: 'CSS Input',
            hint: '.class{color:red;}',
            controller: _inputController,
            maxLines: 8,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: 'Format',
                  icon: Icons.code,
                  onPressed: _format,
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActionButton(
                  label: 'Minify',
                  icon: Icons.compress,
                  onPressed: _minify,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutputField(
            label: 'Output',
            controller: _outputController,
            maxLines: 10,
          ),
        ],
      ),
    );
  }
}
