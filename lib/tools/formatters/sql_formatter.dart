import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    // Keywords ordered by length (longest first) to avoid partial matches
    final keywords = [
      'LEFT OUTER JOIN',
      'RIGHT OUTER JOIN',
      'FULL OUTER JOIN',
      'CROSS JOIN',
      'INNER JOIN',
      'RIGHT JOIN',
      'LEFT JOIN',
      'ORDER BY',
      'GROUP BY',
      'DISTINCT',
      'BETWEEN',
      'SELECT',
      'INSERT',
      'UPDATE',
      'DELETE',
      'HAVING',
      'VALUES',
      'WHERE',
      'LIMIT',
      'FROM',
      'JOIN',
      'INTO',
      'SET',
      'AND',
      'OR',
      'ON',
    ];

    String result = input;
    for (final keyword in keywords) {
      // Use word boundaries to avoid matching partial words like "ANDROID"
      result = result.replaceAllMapped(
        RegExp('\\b$keyword\\b', caseSensitive: false),
        (match) => '\n${keyword.toUpperCase()}',
      );
    }

    result = result.replaceAll(',', ',\n  ').trim();
    // Remove leading newline if present
    if (result.startsWith('\n')) result = result.substring(1);

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
