import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/output_field.dart';
import '../../widgets/action_button.dart';

class EmailValidatorTool extends StatefulWidget {
  final Tool tool;

  const EmailValidatorTool({super.key, required this.tool});

  @override
  State<EmailValidatorTool> createState() => _EmailValidatorToolState();
}

class _EmailValidatorToolState extends State<EmailValidatorTool> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  bool _isValid = false;

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _validate() {
    final email = _inputController.text.trim();
    if (email.isEmpty) return;

    // More comprehensive email regex that handles:
    // - Plus addressing (user+tag@domain.com)
    // - Longer TLDs (.technology, .company, etc.)
    // - Subdomains (user@mail.example.com)
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
    );
    _isValid = emailRegex.hasMatch(email);

    String result = 'Status: ${_isValid ? "Valid ✓" : "Invalid ✗"}\n\n';
    if (_isValid) {
      final parts = email.split('@');
      final username = parts[0];
      final domain = parts[1];
      result += 'Username: $username\n';
      result += 'Domain: $domain\n';
      
      // Additional info
      if (username.contains('+')) {
        result += '\nNote: Contains plus addressing (alias)';
      }
    } else {
      // Provide specific feedback
      final List<String> issues = [];
      if (!email.contains('@')) {
        issues.add('Missing @ symbol');
      } else {
        final parts = email.split('@');
        if (parts[0].isEmpty) issues.add('Missing username before @');
        if (parts.length > 1 && parts[1].isEmpty) issues.add('Missing domain after @');
        if (parts.length > 1 && !parts[1].contains('.')) issues.add('Domain missing extension (.com, .org, etc.)');
      }
      result += 'Issues:\n${issues.map((i) => '• $i').join('\n')}';
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
          InputField(
            label: 'Email Address',
            hint: 'example@domain.com',
            controller: _inputController,
          ),
          const SizedBox(height: 16),
          ActionButton(
            label: 'Validate',
            icon: Icons.check_circle,
            onPressed: _validate,
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          OutputField(
            label: 'Validation Result',
            controller: _outputController,
          ),
        ],
      ),
    );
  }
}
