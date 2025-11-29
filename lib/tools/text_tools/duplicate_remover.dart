import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/output_field.dart';
import '../../widgets/action_button.dart';

class DuplicateRemoverTool extends StatefulWidget {
  final Tool tool;

  const DuplicateRemoverTool({super.key, required this.tool});

  @override
  State<DuplicateRemoverTool> createState() => _DuplicateRemoverToolState();
}

class _DuplicateRemoverToolState extends State<DuplicateRemoverTool> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  bool _caseSensitive = true;

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _removeDuplicates() {
    final lines = _inputController.text.split('\n');
    final seen = <String>{};
    final result = <String>[];

    for (final line in lines) {
      final key = _caseSensitive ? line : line.toLowerCase();
      if (!seen.contains(key)) {
        seen.add(key);
        result.add(line);
      }
    }

    setState(() {
      _outputController.text = result.join('\n');
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
            label: 'Input Lines',
            hint: 'Enter lines...',
            controller: _inputController,
            maxLines: 10,
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text(
              'Case Sensitive',
              style: TextStyle(color: Colors.white),
            ),
            value: _caseSensitive,
            onChanged: (v) => setState(() => _caseSensitive = v!),
            activeColor: const Color(0xFF667eea),
          ),
          const SizedBox(height: 16),
          ActionButton(
            label: 'Remove Duplicates',
            icon: Icons.delete_sweep,
            onPressed: _removeDuplicates,
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          OutputField(
            label: 'Unique Lines',
            controller: _outputController,
            maxLines: 10,
          ),
        ],
      ),
    );
  }
}
