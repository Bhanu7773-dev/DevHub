import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/output_field.dart';
import '../../widgets/action_button.dart';
import '../../utils/app_theme.dart';

class CssUnitConverterTool extends StatefulWidget {
  final Tool tool;

  const CssUnitConverterTool({super.key, required this.tool});

  @override
  State<CssUnitConverterTool> createState() => _CssUnitConverterToolState();
}

class _CssUnitConverterToolState extends State<CssUnitConverterTool> {
  final TextEditingController _inputController = TextEditingController();
  final Map<String, TextEditingController> _outputControllers = {
    'px': TextEditingController(),
    'em': TextEditingController(),
    'rem': TextEditingController(),
    '%': TextEditingController(),
  };
  int _baseFontSize = 16;

  @override
  void dispose() {
    _inputController.dispose();
    _outputControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  void _convert() {
    try {
      final input = double.parse(_inputController.text);
      setState(() {
        _outputControllers['px']!.text = '${input}px';
        _outputControllers['em']!.text =
            '${(input / _baseFontSize).toStringAsFixed(3)}em';
        _outputControllers['rem']!.text =
            '${(input / _baseFontSize).toStringAsFixed(3)}rem';
        _outputControllers['%']!.text =
            '${((input / _baseFontSize) * 100).toStringAsFixed(1)}%';
      });
      HapticFeedback.mediumImpact();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid number')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolDetailScreen(
      tool: widget.tool,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text(
                  'Base Font Size:',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Slider(
                    value: _baseFontSize.toDouble(),
                    min: 12,
                    max: 24,
                    divisions: 12,
                    label: '$_baseFontSize px',
                    activeColor: AppTheme.primaryColor,
                    onChanged: (v) => setState(() => _baseFontSize = v.toInt()),
                  ),
                ),
                Text(
                  '$_baseFontSize px',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
          const SizedBox(height: 16),
          InputField(
            label: 'Pixels',
            hint: '16',
            controller: _inputController,
            maxLines: 1,
          ),
          const SizedBox(height: 16),
          ActionButton(
            label: 'Convert',
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
