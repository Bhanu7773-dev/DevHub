import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/action_button.dart';
import '../../utils/app_theme.dart';

class RegexTesterTool extends StatefulWidget {
  final Tool tool;

  const RegexTesterTool({super.key, required this.tool});

  @override
  State<RegexTesterTool> createState() => _RegexTesterToolState();
}

class _RegexTesterToolState extends State<RegexTesterTool> {
  final TextEditingController _patternController = TextEditingController();
  final TextEditingController _testController = TextEditingController();
  List<RegExpMatch> _matches = [];
  String _errorMessage = '';

  @override
  void dispose() {
    _patternController.dispose();
    _testController.dispose();
    super.dispose();
  }

  void _test() {
    setState(() {
      _errorMessage = '';
      _matches = [];
      try {
        final pattern = _patternController.text;
        final test = _testController.text;
        if (pattern.isEmpty || test.isEmpty) return;

        final regex = RegExp(pattern);
        _matches = regex.allMatches(test).toList();
        HapticFeedback.mediumImpact();
      } catch (e) {
        _errorMessage = 'Invalid regex pattern';
      }
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
            label: 'Regex Pattern',
            hint: r'\d+',
            controller: _patternController,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          InputField(
            label: 'Test String',
            hint: 'Enter text to test...',
            controller: _testController,
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          ActionButton(
            label: 'Test Regex',
            icon: Icons.search,
            onPressed: _test,
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          if (_errorMessage.isNotEmpty) _buildErrorMessage(),
          if (_matches.isNotEmpty) _buildMatches(),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ).animate().shake(duration: 400.ms).fadeIn();
  }

  Widget _buildMatches() {
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
            '${_matches.length} Match${_matches.length != 1 ? 'es' : ''} Found',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ..._matches.asMap().entries.map((entry) {
            final index = entry.key;
            final match = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Match ${index + 1}',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      match.group(0) ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }
}
