import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/action_button.dart';
import '../../utils/app_theme.dart';

class NumberBaseConverterTool extends StatefulWidget {
  final Tool tool;

  const NumberBaseConverterTool({super.key, required this.tool});

  @override
  State<NumberBaseConverterTool> createState() =>
      _NumberBaseConverterToolState();
}

class _NumberBaseConverterToolState extends State<NumberBaseConverterTool> {
  final TextEditingController _inputController = TextEditingController();
  final Map<String, TextEditingController> _outputControllers = {
    'Binary': TextEditingController(),
    'Octal': TextEditingController(),
    'Decimal': TextEditingController(),
    'Hexadecimal': TextEditingController(),
  };
  String _inputBase = 'Decimal';

  @override
  void dispose() {
    _inputController.dispose();
    _outputControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  void _convert() {
    try {
      final input = _inputController.text.trim();
      if (input.isEmpty) return;

      int decimal;
      switch (_inputBase) {
        case 'Binary':
          decimal = int.parse(input, radix: 2);
          break;
        case 'Octal':
          decimal = int.parse(input, radix: 8);
          break;
        case 'Decimal':
          decimal = int.parse(input);
          break;
        case 'Hexadecimal':
          decimal = int.parse(input, radix: 16);
          break;
        default:
          return;
      }

      setState(() {
        _outputControllers['Binary']!.text = decimal.toRadixString(2);
        _outputControllers['Octal']!.text = decimal.toRadixString(8);
        _outputControllers['Decimal']!.text = decimal.toString();
        _outputControllers['Hexadecimal']!.text = decimal
            .toRadixString(16)
            .toUpperCase();
      });
      HapticFeedback.mediumImpact();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid $_inputBase number')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolDetailScreen(
      tool: widget.tool,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBaseSelector(),
          const SizedBox(height: 16),
          InputField(
            label: 'Input ($_inputBase)',
            hint: 'Enter number...',
            controller: _inputController,
            maxLines: 1,
          ),
          const SizedBox(height: 16),
          ActionButton(
            label: 'Convert',
            icon: Icons.calculate,
            onPressed: _convert,
            isPrimary: true,
          ),
          const SizedBox(height: 24),
          ..._outputControllers.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildOutput(e.key, e.value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          'Binary',
          'Octal',
          'Decimal',
          'Hexadecimal',
        ].map((base) => Expanded(child: _buildBaseButton(base))).toList(),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildBaseButton(String base) {
    final isSelected = _inputBase == base;
    return GestureDetector(
      onTap: () {
        setState(() => _inputBase = base);
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                )
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          base.substring(0, 3),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildOutput(String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  controller.text.isEmpty ? '-' : controller.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: controller.text));
                if (context.mounted) {
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$label copied!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              color: AppTheme.primaryColor,
            ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }
}
