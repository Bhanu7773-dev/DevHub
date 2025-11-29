import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/output_field.dart';
import '../../widgets/action_button.dart';

class IpInfoTool extends StatefulWidget {
  final Tool tool;

  const IpInfoTool({super.key, required this.tool});

  @override
  State<IpInfoTool> createState() => _IpInfoToolState();
}

class _IpInfoToolState extends State<IpInfoTool> {
  final TextEditingController _outputController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _outputController.dispose();
    super.dispose();
  }

  void _getIpInfo() async {
    setState(() => _loading = true);
    try {
      String result = 'Local Network Interfaces:\n\n';
      for (var interface in await NetworkInterface.list()) {
        result += 'Interface: ${interface.name}\n';
        for (var addr in interface.addresses) {
          result += '  IP: ${addr.address}\n';
          result += '  Type: ${addr.type.name}\n';
          result += '  Loopback: ${addr.isLoopback}\n';
        }
        result += '\n';
      }

      setState(() {
        _outputController.text = result;
        HapticFeedback.mediumImpact();
      });
    } catch (e) {
      setState(() => _outputController.text = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolDetailScreen(
      tool: widget.tool,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ActionButton(
            label: _loading ? 'Scanning...' : 'Get Local IP Info',
            icon: Icons.network_check,
            onPressed: _loading ? () {} : _getIpInfo,
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          OutputField(
            label: 'Network Info',
            controller: _outputController,
            maxLines: 15,
          ),
        ],
      ),
    );
  }
}
