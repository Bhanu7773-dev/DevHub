import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../utils/app_theme.dart';

class ScreenSizeTool extends StatelessWidget {
  final Tool tool;

  const ScreenSizeTool({super.key, required this.tool});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    return ToolDetailScreen(
      tool: tool,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoCard(context, size, pixelRatio),
          const SizedBox(height: 24),
          Text(
            'Common Breakpoints',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildBreakpointList(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, Size size, double pixelRatio) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.phone_android, size: 48, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            '${size.width.toStringAsFixed(0)} x ${size.height.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Logical Pixels',
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          const Divider(color: Colors.white24, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                'Pixel Ratio',
                '${pixelRatio.toStringAsFixed(1)}x',
              ),
              _buildInfoItem(
                'Orientation',
                size.width > size.height ? 'Landscape' : 'Portrait',
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildBreakpointList() {
    final breakpoints = [
      {'name': 'Mobile Small', 'range': '< 320px'},
      {'name': 'Mobile Medium', 'range': '320px - 375px'},
      {'name': 'Mobile Large', 'range': '375px - 425px'},
      {'name': 'Tablet', 'range': '768px'},
      {'name': 'Laptop', 'range': '1024px'},
      {'name': 'Desktop', 'range': '1440px'},
    ];

    return Column(
      children: breakpoints
          .map(
            (bp) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    bp['name']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    bp['range']!,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    ).animate().fadeIn(delay: 200.ms);
  }
}
