import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/output_field.dart';
import '../../widgets/action_button.dart';
import '../../utils/app_theme.dart';

class RandomDataTool extends StatefulWidget {
  final Tool tool;

  const RandomDataTool({super.key, required this.tool});

  @override
  State<RandomDataTool> createState() => _RandomDataToolState();
}

class _RandomDataToolState extends State<RandomDataTool> {
  final TextEditingController _outputController = TextEditingController();
  String _type = 'Number';
  int _count = 10;

  @override
  void dispose() {
    _outputController.dispose();
    super.dispose();
  }

  void _generate() {
    final random = Random();
    String result = '';

    switch (_type) {
      case 'Number':
        result = List.generate(_count, (_) => random.nextInt(1000)).join(', ');
        break;
      case 'String':
        const chars =
            'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        result = List.generate(
          _count,
          (_) => List.generate(
            8,
            (_) => chars[random.nextInt(chars.length)],
          ).join(),
        ).join(', ');
        break;
      case 'Color':
        result = List.generate(
          _count,
          (_) =>
              '#${random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
        ).join(', ');
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
          _buildTypeSelector(),
          const SizedBox(height: 16),
          _buildCountSelector(),
          const SizedBox(height: 24),
          ActionButton(
            label: 'Generate',
            icon: Icons.casino,
            onPressed: _generate,
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          OutputField(
            label: 'Generated Data',
            controller: _outputController,
            maxLines: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          'Number',
          'String',
          'Color',
        ].map((t) => Expanded(child: _buildTypeButton(t))).toList(),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildTypeButton(String type) {
    final isSelected = _type == type;
    return GestureDetector(
      onTap: () {
        setState(() => _type = type);
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
          type,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCountSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Count: $_count',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Slider(
            value: _count.toDouble(),
            min: 1,
            max: 50,
            divisions: 49,
            activeColor: AppTheme.primaryColor,
            onChanged: (v) {
              setState(() => _count = v.toInt());
              HapticFeedback.selectionClick();
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }
}
