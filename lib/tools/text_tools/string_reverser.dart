import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/output_field.dart';
import '../../widgets/action_button.dart';

class StringReverserTool extends StatefulWidget {
  final Tool tool;

  const StringReverserTool({super.key, required this.tool});

  @override
  State<StringReverserTool> createState() => _StringReverserToolState();
}

class _StringReverserToolState extends State<StringReverserTool> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  String _mode = 'text';

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _reverse() {
    final input = _inputController.text;
    String result = '';

    switch (_mode) {
      case 'text':
        result = input.split('').reversed.join();
        break;
      case 'words':
        result = input.split(' ').reversed.join(' ');
        break;
      case 'lines':
        result = input.split('\n').reversed.join('\n');
        break;
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
          _buildModeSelector(),
          const SizedBox(height: 24),
          InputField(
            label: 'Input',
            hint: 'Enter text...',
            controller: _inputController,
          ),
          const SizedBox(height: 16),
          ActionButton(
            label: 'Reverse',
            icon: Icons.swap_horiz,
            onPressed: _reverse,
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          OutputField(label: 'Reversed', controller: _outputController),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          'text',
          'words',
          'lines',
        ].map((m) => Expanded(child: _buildModeButton(m))).toList(),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildModeButton(String mode) {
    final isSelected = _mode == mode;
    return GestureDetector(
      onTap: () {
        setState(() => _mode = mode);
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                )
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          mode[0].toUpperCase() + mode.substring(1),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
