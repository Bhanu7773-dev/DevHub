import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/output_field.dart';
import '../../widgets/action_button.dart';
import '../../utils/app_theme.dart';

class PasswordGeneratorTool extends StatefulWidget {
  final Tool tool;

  const PasswordGeneratorTool({super.key, required this.tool});

  @override
  State<PasswordGeneratorTool> createState() => _PasswordGeneratorToolState();
}

class _PasswordGeneratorToolState extends State<PasswordGeneratorTool> {
  final TextEditingController _outputController = TextEditingController();
  int _length = 16;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;

  @override
  void dispose() {
    _outputController.dispose();
    super.dispose();
  }

  void _generate() {
    final random = Random.secure();
    String chars = '';

    if (_includeLowercase) chars += 'abcdefghijklmnopqrstuvwxyz';
    if (_includeUppercase) chars += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (_includeNumbers) chars += '0123456789';
    if (_includeSymbols) chars += '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    if (chars.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one option')),
      );
      return;
    }

    setState(() {
      _outputController.text = List.generate(
        _length,
        (_) => chars[random.nextInt(chars.length)],
      ).join();
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
          // Length Selector
          _buildLengthSelector(),
          const SizedBox(height: 24),

          // Options
          _buildOptions(),
          const SizedBox(height: 24),

          // Strength Indicator
          _buildStrengthIndicator(),
          const SizedBox(height: 24),

          ActionButton(
            label: 'Generate Password',
            icon: Icons.vpn_key,
            onPressed: _generate,
            isPrimary: true,
          ),

          const SizedBox(height: 16),

          OutputField(
            label: 'Generated Password',
            controller: _outputController,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildLengthSelector() {
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
            'Password Length: $_length',
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
                  value: _length.toDouble(),
                  min: 8,
                  max: 128,
                  divisions: 120,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    setState(() => _length = value.toInt());
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
                  '$_length',
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

  Widget _buildOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Include:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildCheckbox('Uppercase (A-Z)', _includeUppercase, (val) {
            setState(() => _includeUppercase = val!);
          }),
          _buildCheckbox('Lowercase (a-z)', _includeLowercase, (val) {
            setState(() => _includeLowercase = val!);
          }),
          _buildCheckbox('Numbers (0-9)', _includeNumbers, (val) {
            setState(() => _includeNumbers = val!);
          }),
          _buildCheckbox('Symbols (!@#\$%)', _includeSymbols, (val) {
            setState(() => _includeSymbols = val!);
          }),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildStrengthIndicator() {
    int strength = 0;
    if (_includeUppercase) strength++;
    if (_includeLowercase) strength++;
    if (_includeNumbers) strength++;
    if (_includeSymbols) strength++;

    final isStrong = strength >= 3 && _length >= 12;
    final isMedium = strength >= 2 && _length >= 8;

    String strengthText = isStrong ? 'Strong' : (isMedium ? 'Medium' : 'Weak');
    Color strengthColor = isStrong
        ? Colors.green
        : (isMedium ? Colors.orange : Colors.red);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: strengthColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: strengthColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield, color: strengthColor),
          const SizedBox(width: 12),
          Text(
            'Password Strength: $strengthText',
            style: TextStyle(color: strengthColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }
}
