import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/output_field.dart';
import '../../widgets/action_button.dart';

class CaseConverterTool extends StatefulWidget {
  final Tool tool;

  const CaseConverterTool({super.key, required this.tool});

  @override
  State<CaseConverterTool> createState() => _CaseConverterToolState();
}

class _CaseConverterToolState extends State<CaseConverterTool> {
  final TextEditingController _inputController = TextEditingController();
  final Map<String, TextEditingController> _outputControllers = {
    'camelCase': TextEditingController(),
    'PascalCase': TextEditingController(),
    'snake_case': TextEditingController(),
    'kebab-case': TextEditingController(),
    'UPPER_CASE': TextEditingController(),
  };

  @override
  void dispose() {
    _inputController.dispose();
    _outputControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  void _convert() {
    final input = _inputController.text;
    if (input.isEmpty) return;

    final words = input
        .replaceAll(RegExp(r'[^a-zA-Z0-9]+'), ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();

    setState(() {
      // camelCase
      _outputControllers['camelCase']!.text = words.isEmpty
          ? ''
          : words[0].toLowerCase() +
                words
                    .skip(1)
                    .map(
                      (w) => w[0].toUpperCase() + w.substring(1).toLowerCase(),
                    )
                    .join();

      // PascalCase
      _outputControllers['PascalCase']!.text = words
          .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
          .join();

      // snake_case
      _outputControllers['snake_case']!.text = words
          .map((w) => w.toLowerCase())
          .join('_');

      // kebab-case
      _outputControllers['kebab-case']!.text = words
          .map((w) => w.toLowerCase())
          .join('-');

      // UPPER_CASE
      _outputControllers['UPPER_CASE']!.text = words
          .map((w) => w.toUpperCase())
          .join('_');
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return ToolDetailScreen(
      tool: widget.tool,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputField(
            label: 'Input Text',
            hint: 'Enter text to convert...',
            controller: _inputController,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          ActionButton(
            label: 'Convert All',
            icon: Icons.transform,
            onPressed: _convert,
            isPrimary: true,
          ),
          const SizedBox(height: 24),
          ..._outputControllers.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OutputField(
                label: e.key,
                controller: e.value,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
