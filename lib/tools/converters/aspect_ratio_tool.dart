import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/output_field.dart';
import '../../widgets/action_button.dart';

class AspectRatioTool extends StatefulWidget {
  final Tool tool;

  const AspectRatioTool({super.key, required this.tool});

  @override
  State<AspectRatioTool> createState() => _AspectRatioToolState();
}

class _AspectRatioToolState extends State<AspectRatioTool> {
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ratioController = TextEditingController();

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    _ratioController.dispose();
    super.dispose();
  }

  void _calculate() {
    final w = double.tryParse(_widthController.text);
    final h = double.tryParse(_heightController.text);

    if (w != null && h != null && h != 0) {
      final gcd = _gcd(w.toInt(), h.toInt());
      final rw = w / gcd;
      final rh = h / gcd;
      setState(() {
        _ratioController.text = '${rw.toInt()}:${rh.toInt()}';
        HapticFeedback.mediumImpact();
      });
    }
  }

  int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  @override
  Widget build(BuildContext context) {
    return ToolDetailScreen(
      tool: widget.tool,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: InputField(
                  label: 'Width',
                  hint: '1920',
                  controller: _widthController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InputField(
                  label: 'Height',
                  hint: '1080',
                  controller: _heightController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ActionButton(
            label: 'Calculate Ratio',
            icon: Icons.calculate,
            onPressed: _calculate,
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          OutputField(label: 'Aspect Ratio', controller: _ratioController),
        ],
      ),
    );
  }
}
