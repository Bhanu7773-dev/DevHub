import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/output_field.dart';
import '../../widgets/action_button.dart';

class TimestampConverterTool extends StatefulWidget {
  final Tool tool;

  const TimestampConverterTool({super.key, required this.tool});

  @override
  State<TimestampConverterTool> createState() => _TimestampConverterToolState();
}

class _TimestampConverterToolState extends State<TimestampConverterTool> {
  final TextEditingController _timestampController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void dispose() {
    _timestampController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _toDate() {
    try {
      final timestamp = int.parse(_timestampController.text);
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
      });
      HapticFeedback.mediumImpact();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid timestamp')));
    }
  }

  void _getCurrentTimestamp() {
    final now = DateTime.now();
    setState(() {
      _timestampController.text = (now.millisecondsSinceEpoch ~/ 1000)
          .toString();
      _dateController.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return ToolDetailScreen(
      tool: widget.tool,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ActionButton(
            label: 'Current Timestamp',
            icon: Icons.access_time,
            onPressed: _getCurrentTimestamp,
            isPrimary: true,
          ),
          const SizedBox(height: 24),
          InputField(
            label: 'Unix Timestamp',
            hint: '1234567890',
            controller: _timestampController,
            maxLines: 1,
          ),
          const SizedBox(height: 16),
          ActionButton(
            label: 'Convert to Date',
            icon: Icons.calendar_today,
            onPressed: _toDate,
          ),
          const SizedBox(height: 16),
          OutputField(
            label: 'Date & Time',
            controller: _dateController,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
