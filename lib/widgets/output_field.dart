import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clipboard/clipboard.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/app_theme.dart';

class OutputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;

  const OutputField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleMedium),
                if (controller.text.isNotEmpty)
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Share.share(controller.text);
                          HapticFeedback.selectionClick();
                        },
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('Share'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () async {
                          await FlutterClipboard.copy(controller.text);
                          if (context.mounted) {
                            HapticFeedback.mediumImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Copied to clipboard!'),
                                  ],
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppTheme.primaryColor,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Copy'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                        ),
                      ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: controller.text.isNotEmpty
                      ? AppTheme.primaryColor.withOpacity(0.3)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: controller,
                maxLines: maxLines,
                readOnly: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }
}
