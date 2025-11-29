import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/output_field.dart';
import '../../widgets/action_button.dart';
import '../../utils/app_theme.dart';

class LoremIpsumTool extends StatefulWidget {
  final Tool tool;

  const LoremIpsumTool({super.key, required this.tool});

  @override
  State<LoremIpsumTool> createState() => _LoremIpsumToolState();
}

class _LoremIpsumToolState extends State<LoremIpsumTool> {
  final TextEditingController _outputController = TextEditingController();
  int _count = 3;
  String _type = 'paragraphs';

  final List<String> _words = [
    'lorem',
    'ipsum',
    'dolor',
    'sit',
    'amet',
    'consectetur',
    'adipiscing',
    'elit',
    'sed',
    'do',
    'eiusmod',
    'tempor',
    'incididunt',
    'ut',
    'labore',
    'et',
    'dolore',
    'magna',
    'aliqua',
    'enim',
    'ad',
    'minim',
    'veniam',
    'quis',
    'nostrud',
    'exercitation',
    'ullamco',
    'laboris',
    'nisi',
    'aliquip',
    'ex',
    'ea',
    'commodo',
  ];

  @override
  void dispose() {
    _outputController.dispose();
    super.dispose();
  }

  void _generate() {
    final random = Random();
    String result = '';

    if (_type == 'paragraphs') {
      for (int i = 0; i < _count; i++) {
        final sentences = 3 + random.nextInt(4);
        for (int j = 0; j < sentences; j++) {
          final wordCount = 8 + random.nextInt(8);
          final sentence = List.generate(
            wordCount,
            (_) => _words[random.nextInt(_words.length)],
          ).join(' ');
          result += sentence[0].toUpperCase() + sentence.substring(1) + '. ';
        }
        result += '\n\n';
      }
    } else if (_type == 'sentences') {
      for (int i = 0; i < _count; i++) {
        final wordCount = 8 + random.nextInt(8);
        final sentence = List.generate(
          wordCount,
          (_) => _words[random.nextInt(_words.length)],
        ).join(' ');
        result += sentence[0].toUpperCase() + sentence.substring(1) + '. ';
      }
    } else {
      result = List.generate(
        _count,
        (_) => _words[random.nextInt(_words.length)],
      ).join(' ');
    }

    setState(() {
      _outputController.text = result.trim();
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
            icon: Icons.refresh,
            onPressed: _generate,
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          OutputField(
            label: 'Generated Text',
            controller: _outputController,
            maxLines: 15,
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
          Expanded(child: _buildTypeButton('Paragraphs', 'paragraphs')),
          Expanded(child: _buildTypeButton('Sentences', 'sentences')),
          Expanded(child: _buildTypeButton('Words', 'words')),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildTypeButton(String label, String type) {
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
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
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
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Slider(
            value: _count.toDouble(),
            min: 1,
            max: _type == 'words' ? 100 : 10,
            divisions: _type == 'words' ? 99 : 9,
            activeColor: AppTheme.primaryColor,
            onChanged: (value) {
              setState(() => _count = value.toInt());
              HapticFeedback.selectionClick();
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }
}
