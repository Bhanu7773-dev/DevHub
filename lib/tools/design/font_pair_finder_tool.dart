import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';

class FontPair {
  final String heading;
  final String body;
  final String category;

  const FontPair({
    required this.heading,
    required this.body,
    required this.category,
  });
}

class FontPairFinderTool extends StatefulWidget {
  final Tool tool;

  const FontPairFinderTool({super.key, required this.tool});

  @override
  State<FontPairFinderTool> createState() => _FontPairFinderToolState();
}

class _FontPairFinderToolState extends State<FontPairFinderTool> {
  final List<FontPair> _pairs = [
    const FontPair(
      heading: 'Montserrat',
      body: 'Open Sans',
      category: 'Modern',
    ),
    const FontPair(
      heading: 'Playfair Display',
      body: 'Lato',
      category: 'Elegant',
    ),
    const FontPair(heading: 'Roboto Slab', body: 'Roboto', category: 'Tech'),
    const FontPair(
      heading: 'Merriweather',
      body: 'Source Sans Pro',
      category: 'Classic',
    ),
    const FontPair(heading: 'Oswald', body: 'Quattrocento', category: 'Bold'),
    const FontPair(heading: 'Raleway', body: 'Merriweather', category: 'Clean'),
    const FontPair(
      heading: 'Abril Fatface',
      body: 'Poppins',
      category: 'Display',
    ),
    const FontPair(heading: 'Ubuntu', body: 'Lora', category: 'Unique'),
    const FontPair(heading: 'Nunito', body: 'Nunito Sans', category: 'Soft'),
    const FontPair(heading: 'Space Mono', body: 'Work Sans', category: 'Code'),
  ];

  TextStyle _getStyle(String fontName) {
    try {
      return GoogleFonts.getFont(fontName);
    } catch (e) {
      return const TextStyle();
    }
  }

  void _copyPair(FontPair pair) {
    final text = '${pair.heading} + ${pair.body}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "$text"'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ToolDetailScreen(
      tool: widget.tool,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _pairs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final pair = _pairs[index];
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with names
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${pair.heading} + ${pair.body}',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            pair.category,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () => _copyPair(pair),
                        tooltip: 'Copy Names',
                      ),
                    ],
                  ),
                ),

                // Preview Area
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'The Quick Brown Fox',
                        style: _getStyle(pair.heading).copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Jumped over the lazy dog. This is how your body text will look like when paired with this heading font. It creates a harmonious visual hierarchy.',
                        style: _getStyle(pair.body).copyWith(
                          fontSize: 16,
                          height: 1.5,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
