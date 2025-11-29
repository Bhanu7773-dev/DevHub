import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/output_field.dart';
import '../../widgets/action_button.dart';

class XmlFormatterTool extends StatefulWidget {
  final Tool tool;

  const XmlFormatterTool({super.key, required this.tool});

  @override
  State<XmlFormatterTool> createState() => _XmlFormatterToolState();
}

class _XmlFormatterToolState extends State<XmlFormatterTool> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _format() {
    // Simple XML formatting (basic indentation)
    final input = _inputController.text.trim();
    if (input.isEmpty) return;

    String result = '';
    int indent = 0;
    final lines = input.replaceAll('><', '>\n<').split('\n');

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.startsWith('</')) indent--;
      result += '  ' * indent + trimmed + '\n';
      if (trimmed.startsWith('<') &&
          !trimmed.startsWith('</') &&
          !trimmed.startsWith('<?') &&
          !trimmed.endsWith('/>') &&
          !trimmed.contains('</')) {
        indent++;
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
            label: 'XML Input',
            hint: '<root><item>value</item></root>',
            controller: _inputController,
            maxLines: 8,
          ),
          const SizedBox(height: 16),
          ActionButton(
            label: 'Format',
            icon: Icons.code,
            onPressed: _format,
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          OutputField(
            label: 'Formatted XML',
            controller: _outputController,
            maxLines: 10,
          ),
        ],
      ),
    );
  }
}
