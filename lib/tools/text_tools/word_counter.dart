import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../utils/app_theme.dart';

class WordCounterTool extends StatefulWidget {
  final Tool tool;

  const WordCounterTool({super.key, required this.tool});

  @override
  State<WordCounterTool> createState() => _WordCounterToolState();
}

class _WordCounterToolState extends State<WordCounterTool> {
  final TextEditingController _inputController = TextEditingController();
  int _characters = 0;
  int _charactersNoSpaces = 0;
  int _words = 0;
  int _lines = 0;
  int _readingTime = 0;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _count(String text) {
    setState(() {
      _characters = text.length;
      _charactersNoSpaces = text.replaceAll(' ', '').length;
      _words = text.isEmpty
          ? 0
          : text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
      _lines = text.isEmpty ? 0 : text.split('\n').length;
      _readingTime = (_words / 200)
          .ceil(); // Average reading speed: 200 words/min
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
            label: 'Text',
            hint: 'Enter or paste your text here...',
            controller: _inputController,
            maxLines: 10,
            onChanged: _count,
          ),
          const SizedBox(height: 24),
          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Characters',
                  _characters.toString(),
                  Icons.text_fields,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'No Spaces',
                  _charactersNoSpaces.toString(),
                  Icons.space_bar,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Words',
                  _words.toString(),
                  Icons.article,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Lines',
                  _lines.toString(),
                  Icons.format_list_numbered,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            'Reading Time',
            '$_readingTime min',
            Icons.access_time,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
