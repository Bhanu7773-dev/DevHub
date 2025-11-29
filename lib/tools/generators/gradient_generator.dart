import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/output_field.dart';
import '../../widgets/action_button.dart';

class GradientGeneratorTool extends StatefulWidget {
  final Tool tool;

  const GradientGeneratorTool({super.key, required this.tool});

  @override
  State<GradientGeneratorTool> createState() => _GradientGeneratorToolState();
}

class _GradientGeneratorToolState extends State<GradientGeneratorTool> {
  Color _color1 = const Color(0xFF667eea);
  Color _color2 = const Color(0xFF764ba2);
  final TextEditingController _hex1Controller = TextEditingController();
  final TextEditingController _hex2Controller = TextEditingController();
  final TextEditingController _cssController = TextEditingController();
  final TextEditingController _flutterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _hex1Controller.text = _toHex(_color1);
    _hex2Controller.text = _toHex(_color2);
    _updateCode();
  }

  @override
  void dispose() {
    _hex1Controller.dispose();
    _hex2Controller.dispose();
    _cssController.dispose();
    _flutterController.dispose();
    super.dispose();
  }

  String _toHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _updateCode() {
    final hex1 = _toHex(_color1);
    final hex2 = _toHex(_color2);

    _cssController.text =
        'background: linear-gradient(to right, $hex1, $hex2);';
    _flutterController.text =
        'BoxDecoration(\n  gradient: LinearGradient(\n    colors: [Color(0xFF${hex1.substring(1)}), Color(0xFF${hex2.substring(1)})],\n  ),\n)';
  }

  void _onHexChanged(String value, bool isFirst) {
    if (value.length != 7 || !value.startsWith('#')) return;
    try {
      final color = Color(int.parse('0xFF${value.substring(1)}'));
      setState(() {
        if (isFirst) {
          _color1 = color;
        } else {
          _color2 = color;
        }
        _updateCode();
      });
    } catch (e) {
      // Ignore invalid hex
    }
  }

  void _randomize() {
    final random = Random();
    setState(() {
      _color1 = Color(0xFF000000 | random.nextInt(0xFFFFFF));
      _color2 = Color(0xFF000000 | random.nextInt(0xFFFFFF));
      _hex1Controller.text = _toHex(_color1);
      _hex2Controller.text = _toHex(_color2);
      _updateCode();
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
          Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_color1, _color2]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: InputField(
                  label: 'Color 1 (Hex)',
                  hint: '#RRGGBB',
                  controller: _hex1Controller,
                  onChanged: (v) => _onHexChanged(v, true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InputField(
                  label: 'Color 2 (Hex)',
                  hint: '#RRGGBB',
                  controller: _hex2Controller,
                  onChanged: (v) => _onHexChanged(v, false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ActionButton(
            label: 'Randomize Colors',
            icon: Icons.shuffle,
            onPressed: _randomize,
            isPrimary: true,
          ),
          const SizedBox(height: 24),
          OutputField(
            label: 'CSS Code',
            controller: _cssController,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          OutputField(
            label: 'Flutter Code',
            controller: _flutterController,
            maxLines: 5,
          ),
        ],
      ),
    );
  }
}
