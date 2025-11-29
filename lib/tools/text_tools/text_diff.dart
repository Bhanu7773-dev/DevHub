import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/action_button.dart';
import '../../utils/app_theme.dart';

class TextDiffTool extends StatefulWidget {
  final Tool tool;

  const TextDiffTool({super.key, required this.tool});

  @override
  State<TextDiffTool> createState() => _TextDiffToolState();
}

class _TextDiffToolState extends State<TextDiffTool> {
  final TextEditingController _text1Controller = TextEditingController();
  final TextEditingController _text2Controller = TextEditingController();
  List<DiffLine> _diffLines = [];
  int _additions = 0;
  int _deletions = 0;
  int _unchanged = 0;

  @override
  void dispose() {
    _text1Controller.dispose();
    _text2Controller.dispose();
    super.dispose();
  }

  void _compare() {
    final lines1 = _text1Controller.text.split('\n');
    final lines2 = _text2Controller.text.split('\n');
    
    // Compute LCS-based diff
    final diff = _computeDiff(lines1, lines2);
    
    int adds = 0, dels = 0, same = 0;
    for (final line in diff) {
      if (line.type == DiffType.added) {
        adds++;
      } else if (line.type == DiffType.removed) {
        dels++;
      } else {
        same++;
      }
    }

    setState(() {
      _diffLines = diff;
      _additions = adds;
      _deletions = dels;
      _unchanged = same;
      HapticFeedback.mediumImpact();
    });
  }

  List<DiffLine> _computeDiff(List<String> lines1, List<String> lines2) {
    // Simple but effective diff using longest common subsequence approach
    final result = <DiffLine>[];
    int i = 0, j = 0;
    
    while (i < lines1.length || j < lines2.length) {
      if (i >= lines1.length) {
        // Remaining lines in text2 are additions
        result.add(DiffLine(lines2[j], DiffType.added, j + 1));
        j++;
      } else if (j >= lines2.length) {
        // Remaining lines in text1 are deletions
        result.add(DiffLine(lines1[i], DiffType.removed, i + 1));
        i++;
      } else if (lines1[i] == lines2[j]) {
        // Lines match
        result.add(DiffLine(lines1[i], DiffType.unchanged, i + 1));
        i++;
        j++;
      } else {
        // Look ahead to find best match
        final matchInText2 = _findNextMatch(lines1[i], lines2, j);
        final matchInText1 = _findNextMatch(lines2[j], lines1, i);
        
        if (matchInText2 != -1 && (matchInText1 == -1 || matchInText2 - j <= matchInText1 - i)) {
          // Add lines from text2 until we find the match
          while (j < matchInText2) {
            result.add(DiffLine(lines2[j], DiffType.added, j + 1));
            j++;
          }
        } else if (matchInText1 != -1) {
          // Remove lines from text1 until we find the match
          while (i < matchInText1) {
            result.add(DiffLine(lines1[i], DiffType.removed, i + 1));
            i++;
          }
        } else {
          // No match found - remove from text1, add from text2
          result.add(DiffLine(lines1[i], DiffType.removed, i + 1));
          result.add(DiffLine(lines2[j], DiffType.added, j + 1));
          i++;
          j++;
        }
      }
    }
    
    return result;
  }

  int _findNextMatch(String line, List<String> lines, int startFrom) {
    for (int k = startFrom; k < lines.length && k < startFrom + 5; k++) {
      if (lines[k] == line) return k;
    }
    return -1;
  }

  void _clear() {
    setState(() {
      _text1Controller.clear();
      _text2Controller.clear();
      _diffLines = [];
      _additions = 0;
      _deletions = 0;
      _unchanged = 0;
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
            label: 'Original Text',
            hint: 'Enter original text...',
            controller: _text1Controller,
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          InputField(
            label: 'Modified Text',
            hint: 'Enter modified text...',
            controller: _text2Controller,
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: 'Compare',
                  icon: Icons.compare_arrows,
                  onPressed: _compare,
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 12),
              ActionButton(
                label: 'Clear',
                icon: Icons.clear,
                onPressed: _clear,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_diffLines.isNotEmpty) ...[
            _buildStats(),
            const SizedBox(height: 16),
            _buildDiffView(),
          ],
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatChip('+$_additions', Colors.green, 'Added'),
          _buildStatChip('-$_deletions', Colors.red, 'Removed'),
          _buildStatChip('=$_unchanged', Colors.grey, 'Unchanged'),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildStatChip(String value, Color color, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDiffView() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _diffLines.length,
          itemBuilder: (context, index) {
            final line = _diffLines[index];
            return _buildDiffLine(line);
          },
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDiffLine(DiffLine line) {
    Color bgColor;
    Color textColor;
    String prefix;
    
    switch (line.type) {
      case DiffType.added:
        bgColor = Colors.green.withOpacity(0.15);
        textColor = Colors.green;
        prefix = '+';
        break;
      case DiffType.removed:
        bgColor = Colors.red.withOpacity(0.15);
        textColor = Colors.red;
        prefix = '-';
        break;
      case DiffType.unchanged:
        bgColor = Colors.transparent;
        textColor = Colors.white.withOpacity(0.7);
        prefix = ' ';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: bgColor,
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '${line.lineNumber}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
          Text(
            prefix,
            style: TextStyle(
              color: textColor,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              line.content.isEmpty ? ' ' : line.content,
              style: TextStyle(
                color: textColor,
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum DiffType { added, removed, unchanged }

class DiffLine {
  final String content;
  final DiffType type;
  final int lineNumber;
  
  DiffLine(this.content, this.type, this.lineNumber);
}
