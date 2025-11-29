import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/action_button.dart';
import '../../utils/app_theme.dart';

class TimestampConverterTool extends StatefulWidget {
  final Tool tool;

  const TimestampConverterTool({super.key, required this.tool});

  @override
  State<TimestampConverterTool> createState() => _TimestampConverterToolState();
}

class _TimestampConverterToolState extends State<TimestampConverterTool> {
  final TextEditingController _timestampController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  
  bool _isMilliseconds = false; // Toggle between seconds and milliseconds
  String _timezone = 'Local';
  DateTime? _currentDateTime;

  @override
  void dispose() {
    _timestampController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _timestampToDate() {
    try {
      final input = _timestampController.text.trim();
      if (input.isEmpty) {
        _showError('Please enter a timestamp');
        return;
      }
      
      final timestamp = int.parse(input);
      DateTime date;
      
      // Auto-detect if it's milliseconds or seconds based on length
      // Timestamps after year 2001 in seconds are 10 digits
      // Timestamps in milliseconds are 13 digits
      if (timestamp > 9999999999) {
        // It's milliseconds
        date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        setState(() => _isMilliseconds = true);
      } else {
        // It's seconds
        date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        setState(() => _isMilliseconds = false);
      }
      
      if (_timezone == 'UTC') {
        date = date.toUtc();
      }
      
      setState(() {
        _currentDateTime = date;
        _dateController.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
      });
      HapticFeedback.mediumImpact();
    } catch (e) {
      _showError('Invalid timestamp');
    }
  }

  void _dateToTimestamp() {
    try {
      final input = _dateController.text.trim();
      if (input.isEmpty) {
        _showError('Please enter a date');
        return;
      }
      
      // Try multiple date formats
      DateTime? date;
      final formats = [
        'yyyy-MM-dd HH:mm:ss',
        'yyyy-MM-dd HH:mm',
        'yyyy-MM-dd',
        'dd/MM/yyyy HH:mm:ss',
        'dd/MM/yyyy',
        'MM/dd/yyyy HH:mm:ss',
        'MM/dd/yyyy',
      ];
      
      for (final format in formats) {
        try {
          date = DateFormat(format).parse(input);
          break;
        } catch (_) {
          continue;
        }
      }
      
      if (date == null) {
        _showError('Invalid date format. Use: yyyy-MM-dd HH:mm:ss');
        return;
      }
      
      setState(() {
        _currentDateTime = date;
        if (_isMilliseconds) {
          _timestampController.text = date!.millisecondsSinceEpoch.toString();
        } else {
          _timestampController.text = (date!.millisecondsSinceEpoch ~/ 1000).toString();
        }
      });
      HapticFeedback.mediumImpact();
    } catch (e) {
      _showError('Invalid date format');
    }
  }

  void _getCurrentTimestamp() {
    final now = DateTime.now();
    setState(() {
      _currentDateTime = now;
      if (_isMilliseconds) {
        _timestampController.text = now.millisecondsSinceEpoch.toString();
      } else {
        _timestampController.text = (now.millisecondsSinceEpoch ~/ 1000).toString();
      }
      _dateController.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    });
    HapticFeedback.mediumImpact();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ToolDetailScreen(
      tool: widget.tool,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Current Timestamp Button
          ActionButton(
            label: 'Get Current Time',
            icon: Icons.access_time,
            onPressed: _getCurrentTimestamp,
            isPrimary: true,
          ),
          const SizedBox(height: 20),
          
          // Options Row
          _buildOptionsRow(),
          const SizedBox(height: 20),
          
          // Timestamp Input
          InputField(
            label: 'Unix Timestamp ${_isMilliseconds ? "(ms)" : "(sec)"}',
            hint: _isMilliseconds ? '1732900000000' : '1732900000',
            controller: _timestampController,
            maxLines: 1,
          ),
          const SizedBox(height: 12),
          
          // Convert Buttons
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: 'To Date ↓',
                  icon: Icons.arrow_downward,
                  onPressed: _timestampToDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActionButton(
                  label: 'To Timestamp ↑',
                  icon: Icons.arrow_upward,
                  onPressed: _dateToTimestamp,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Date Input
          InputField(
            label: 'Date & Time',
            hint: 'yyyy-MM-dd HH:mm:ss',
            controller: _dateController,
            maxLines: 1,
          ),
          
          // Additional Info
          if (_currentDateTime != null) ...[
            const SizedBox(height: 24),
            _buildInfoCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionsRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Seconds/Milliseconds Toggle
          Expanded(
            child: Row(
              children: [
                const Text('Unit:', style: TextStyle(color: Colors.white70)),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Seconds'),
                  selected: !_isMilliseconds,
                  onSelected: (selected) {
                    setState(() => _isMilliseconds = false);
                  },
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: !_isMilliseconds ? Colors.white : Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                ChoiceChip(
                  label: const Text('ms'),
                  selected: _isMilliseconds,
                  onSelected: (selected) {
                    setState(() => _isMilliseconds = true);
                  },
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: _isMilliseconds ? Colors.white : Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Timezone Toggle
          Row(
            children: [
              const Text('TZ:', style: TextStyle(color: Colors.white70)),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Local'),
                selected: _timezone == 'Local',
                onSelected: (selected) {
                  setState(() => _timezone = 'Local');
                },
                selectedColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: _timezone == 'Local' ? Colors.white : Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              ChoiceChip(
                label: const Text('UTC'),
                selected: _timezone == 'UTC',
                onSelected: (selected) {
                  setState(() => _timezone = 'UTC');
                },
                selectedColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: _timezone == 'UTC' ? Colors.white : Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final date = _currentDateTime!;
    final utcDate = date.toUtc();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Formats',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('ISO 8601', date.toIso8601String()),
          _buildInfoRow('UTC', DateFormat('yyyy-MM-dd HH:mm:ss').format(utcDate) + ' UTC'),
          _buildInfoRow('RFC 2822', DateFormat('EEE, dd MMM yyyy HH:mm:ss').format(date)),
          _buildInfoRow('Relative', _getRelativeTime(date)),
          _buildInfoRow('Day of Year', '${_getDayOfYear(date)}'),
          _buildInfoRow('Week of Year', '${_getWeekOfYear(date)}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                HapticFeedback.selectionClick();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied: $value'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.isNegative) {
      final futureDiff = date.difference(now);
      if (futureDiff.inDays > 365) return 'in ${futureDiff.inDays ~/ 365} years';
      if (futureDiff.inDays > 30) return 'in ${futureDiff.inDays ~/ 30} months';
      if (futureDiff.inDays > 0) return 'in ${futureDiff.inDays} days';
      if (futureDiff.inHours > 0) return 'in ${futureDiff.inHours} hours';
      if (futureDiff.inMinutes > 0) return 'in ${futureDiff.inMinutes} minutes';
      return 'in a few seconds';
    }
    
    if (diff.inDays > 365) return '${diff.inDays ~/ 365} years ago';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30} months ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
    return 'just now';
  }

  int _getDayOfYear(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    return date.difference(firstDay).inDays + 1;
  }

  int _getWeekOfYear(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    final days = date.difference(firstDay).inDays;
    return (days / 7).ceil() + 1;
  }
}
