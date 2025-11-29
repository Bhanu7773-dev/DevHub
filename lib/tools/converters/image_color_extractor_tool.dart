import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/action_button.dart';

class ImageColorExtractorTool extends StatefulWidget {
  final Tool tool;

  const ImageColorExtractorTool({super.key, required this.tool});

  @override
  State<ImageColorExtractorTool> createState() =>
      _ImageColorExtractorToolState();
}

class _ImageColorExtractorToolState extends State<ImageColorExtractorTool> {
  File? _imageFile;
  PaletteGenerator? _paletteGenerator;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isLoading = true;
      });
      _generatePalette();
    }
  }

  Future<void> _generatePalette() async {
    if (_imageFile == null) return;

    // Resize image for faster processing (max 500px width/height)
    // We use ResizeImage provider which is efficient
    final imageProvider = ResizeImage(
      FileImage(_imageFile!),
      width: 500,
      allowUpscaling: false,
    );

    final paletteGenerator = await PaletteGenerator.fromImageProvider(
      imageProvider,
      maximumColorCount: 20,
    );

    if (mounted) {
      setState(() {
        _paletteGenerator = paletteGenerator;
        _isLoading = false;
      });
    }
  }

  void _copyColor(Color color) {
    final hex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
    Clipboard.setData(ClipboardData(text: hex));
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $hex'),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildColorItem(String label, Color? color) {
    if (color == null) return const SizedBox.shrink();

    final hex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
    final isLight = color.computeLuminance() > 0.5;

    return GestureDetector(
      onTap: () => _copyColor(color),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isLight ? Colors.black54 : Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              hex,
              style: TextStyle(
                color: isLight ? Colors.black : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ToolDetailScreen(
      tool: widget.tool,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ActionButton(
            label: 'Pick Image',
            icon: Icons.add_photo_alternate,
            onPressed: _pickImage,
            isPrimary: true,
          ),
          const SizedBox(height: 24),

          if (_imageFile != null) ...[
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _imageFile!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (_isLoading)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 16),
                        const Text(
                          'Analyzing Colors...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            if (!_isLoading && _paletteGenerator != null) ...[
              Text(
                'Dominant Colors',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: [
                  _buildColorItem(
                    'Dominant',
                    _paletteGenerator!.dominantColor?.color,
                  ),
                  _buildColorItem(
                    'Vibrant',
                    _paletteGenerator!.vibrantColor?.color,
                  ),
                  _buildColorItem(
                    'Muted',
                    _paletteGenerator!.mutedColor?.color,
                  ),
                  _buildColorItem(
                    'Light Vibrant',
                    _paletteGenerator!.lightVibrantColor?.color,
                  ),
                  _buildColorItem(
                    'Dark Vibrant',
                    _paletteGenerator!.darkVibrantColor?.color,
                  ),
                  _buildColorItem(
                    'Light Muted',
                    _paletteGenerator!.lightMutedColor?.color,
                  ),
                  _buildColorItem(
                    'Dark Muted',
                    _paletteGenerator!.darkMutedColor?.color,
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Text(
                'Full Palette',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _paletteGenerator!.colors.length,
                itemBuilder: (context, index) {
                  final color = _paletteGenerator!.colors.elementAt(index);
                  return GestureDetector(
                    onTap: () => _copyColor(color),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                    ),
                  );
                },
              ),
            ],
          ] else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  style: BorderStyle.none,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No image selected',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
