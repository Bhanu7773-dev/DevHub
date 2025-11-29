import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/action_button.dart';
import '../../utils/app_theme.dart';

class ColorConverterTool extends StatefulWidget {
  final Tool tool;

  const ColorConverterTool({super.key, required this.tool});

  @override
  State<ColorConverterTool> createState() => _ColorConverterToolState();
}

class _ColorConverterToolState extends State<ColorConverterTool> {
  final TextEditingController _hexController = TextEditingController();
  final TextEditingController _rgbController = TextEditingController();
  final TextEditingController _hslController = TextEditingController();
  Color _currentColor = Colors.blue;

  @override
  void dispose() {
    _hexController.dispose();
    _rgbController.dispose();
    _hslController.dispose();
    super.dispose();
  }

  void _convertFromHex() {
    try {
      final hex = _hexController.text.replaceAll('#', '');
      final color = Color(int.parse('FF$hex', radix: 16));
      setState(() {
        _currentColor = color;
        _updateRGB(color);
        _updateHSL(color);
      });
      HapticFeedback.mediumImpact();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid HEX color')));
    }
  }

  void _updateRGB(Color color) {
    _rgbController.text = 'rgb(${color.red}, ${color.green}, ${color.blue})';
  }

  void _updateHSL(Color color) {
    final hsl = HSLColor.fromColor(color);
    _hslController.text =
        'hsl(${hsl.hue.round()}°, ${(hsl.saturation * 100).round()}%, ${(hsl.lightness * 100).round()}%)';
  }

  @override
  Widget build(BuildContext context) {
    return ToolDetailScreen(
      tool: widget.tool,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Color Preview
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: _currentColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24, width: 2),
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
          const SizedBox(height: 24),

          InputField(
            label: 'HEX',
            hint: '#667eea',
            controller: _hexController,
            maxLines: 1,
          ),
          const SizedBox(height: 12),
          ActionButton(
            label: 'Convert from HEX',
            icon: Icons.palette,
            onPressed: _convertFromHex,
            isPrimary: true,
          ),
          const SizedBox(height: 24),

          _buildOutputField('RGB', _rgbController),
          const SizedBox(height: 16),
          _buildOutputField('HSL', _hslController),
        ],
      ),
    );
  }

  Widget _buildOutputField(String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: controller.text),
                    );
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
          const SizedBox(height: 8),
          SelectableText(
            controller.text.isEmpty
                ? 'Convert a color to see $label'
                : controller.text,
            style: TextStyle(
              color: controller.text.isEmpty ? Colors.white38 : Colors.white,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }
}
