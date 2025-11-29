import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/output_field.dart';
import '../../widgets/action_button.dart';
import '../../utils/app_theme.dart';

class UuidGeneratorTool extends StatefulWidget {
  final Tool tool;

  const UuidGeneratorTool({super.key, required this.tool});

  @override
  State<UuidGeneratorTool> createState() => _UuidGeneratorToolState();
}

class _UuidGeneratorToolState extends State<UuidGeneratorTool> {
  final TextEditingController _outputController = TextEditingController();
  final Uuid _uuid = const Uuid();
  int _count = 1;

  @override
  void dispose() {
    _outputController.dispose();
    super.dispose();
  }

  void _generate() {
    setState(() {
      if (_count == 1) {
        _outputController.text = _uuid.v4();
      } else {
        final uuids = List.generate(_count, (_) => _uuid.v4());
        _outputController.text = uuids.join('\n');
      }
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
          // Count Selector
          _buildCountSelector(),
          const SizedBox(height: 24),

          ActionButton(
            label: 'Generate UUID${_count > 1 ? 's' : ''}',
            icon: Icons.refresh,
            onPressed: _generate,
            isPrimary: true,
          ),

          const SizedBox(height: 16),

          OutputField(
            label: 'Generated UUID${_count > 1 ? 's' : ''}',
            controller: _outputController,
            maxLines: _count > 5 ? 10 : 5,
          ),
        ],
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
            'Number of UUIDs: $_count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _count.toDouble(),
                  min: 1,
                  max: 100,
                  divisions: 99,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    setState(() => _count = value.toInt());
                    HapticFeedback.selectionClick();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}
