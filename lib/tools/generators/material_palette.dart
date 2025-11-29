import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../utils/app_theme.dart';

class MaterialPaletteTool extends StatelessWidget {
  final Tool tool;

  const MaterialPaletteTool({super.key, required this.tool});

  final Map<String, MaterialColor> _colors = const {
    'Red': Colors.red,
    'Pink': Colors.pink,
    'Purple': Colors.purple,
    'Deep Purple': Colors.deepPurple,
    'Indigo': Colors.indigo,
    'Blue': Colors.blue,
    'Light Blue': Colors.lightBlue,
    'Cyan': Colors.cyan,
    'Teal': Colors.teal,
    'Green': Colors.green,
    'Light Green': Colors.lightGreen,
    'Lime': Colors.lime,
    'Yellow': Colors.yellow,
    'Amber': Colors.amber,
    'Orange': Colors.orange,
    'Deep Orange': Colors.deepOrange,
    'Brown': Colors.brown,
    'Grey': Colors.grey,
    'Blue Grey': Colors.blueGrey,
  };

  @override
  Widget build(BuildContext context) {
    return ToolDetailScreen(
      tool: tool,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _colors.length,
        itemBuilder: (context, index) {
          final name = _colors.keys.elementAt(index);
          final color = _colors.values.elementAt(index);
          return _buildColorRow(context, name, color);
        },
      ),
    );
  }

  Widget _buildColorRow(
    BuildContext context,
    String name,
    MaterialColor color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [50, 100, 200, 300, 400, 500, 600, 700, 800, 900].map((
              shade,
            ) {
              final c = color[shade]!;
              return GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: '0x${c.value.toRadixString(16).toUpperCase()}',
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied ${name} $shade')),
                  );
                  HapticFeedback.selectionClick();
                },
                child: Container(
                  width: 50,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$shade',
                      style: TextStyle(
                        color:
                            ThemeData.estimateBrightnessForColor(c) ==
                                Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    ).animate().fadeIn(delay: (100).ms);
  }
}
