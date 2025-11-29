import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/output_field.dart';
import '../../widgets/action_button.dart';

class SqlFormatterTool extends StatefulWidget {
  final Tool tool;

  const SqlFormatterTool({super.key, required this.tool});

  @override
  State<SqlFormatterTool> createState() => _SqlFormatterToolState();
}

class _SqlFormatterToolState extends State<SqlFormatterTool> {
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

    final keywords = [
      'SELECT',
      'FROM',
      'WHERE',
      'JOIN',
      'LEFT JOIN',
      'RIGHT JOIN',
      'INNER JOIN',
      'ON',
      'AND',
      'OR',
      'ORDER BY',
      'GROUP BY',
      'HAVING',
      'LIMIT',
    ];

    String result = input;
    for (final keyword in keywords) {
      result = result.replaceAll(
        RegExp(keyword, caseSensitive: false),
        '\n$keyword',
      );
    }

    result = result.replaceAll(',', ',\n  ').trim();

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
            label: 'SQL Input',
            hint: 'SELECT * FROM users WHERE id=1',
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
            label: 'Formatted SQL',
            controller: _outputController,
            maxLines: 10,
          ),
        ],
      ),
    );
  }
}
