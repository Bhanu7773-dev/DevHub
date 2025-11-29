import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/output_field.dart';
import '../../widgets/action_button.dart';

class TextDiffTool extends StatefulWidget {
  final Tool tool;

  const TextDiffTool({super.key, required this.tool});

  @override
  State<TextDiffTool> createState() => _TextDiffToolState();
}

class _TextDiffToolState extends State<TextDiffTool> {
  final TextEditingController _text1Controller = TextEditingController();
  final TextEditingController _text2Controller = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  @override
  void dispose() {
    _text1Controller.dispose();
    _text2Controller.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _compare() {
    final text1 = _text1Controller.text.split('\n');
    final text2 = _text2Controller.text.split('\n');
    final maxLines = text1.length > text2.length ? text1.length : text2.length;

    String result = '';
    for (int i = 0; i < maxLines; i++) {
      final line1 = i < text1.length ? text1[i] : '';
      final line2 = i < text2.length ? text2[i] : '';

      if (line1 == line2) {
        result += '  $line1\n';
      } else {
        if (line1.isNotEmpty) result += '- $line1\n';
        if (line2.isNotEmpty) result += '+ $line2\n';
      }
    }

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
            label: 'Text 1',
            hint: 'Enter first text...',
            controller: _text1Controller,
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          InputField(
            label: 'Text 2',
            hint: 'Enter second text...',
            controller: _text2Controller,
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          ActionButton(
            label: 'Compare',
            icon: Icons.compare_arrows,
            onPressed: _compare,
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          OutputField(
            label: 'Differences',
            controller: _outputController,
            maxLines: 10,
          ),
        ],
      ),
    );
  }
}
