import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_selector/file_selector.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/output_field.dart';
import '../../widgets/action_button.dart';
import '../../utils/app_theme.dart';

class Base64Tool extends StatefulWidget {
  final Tool tool;

  const Base64Tool({super.key, required this.tool});

  @override
  State<Base64Tool> createState() => _Base64ToolState();
}

class _Base64ToolState extends State<Base64Tool> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  bool _isEncoding = true;
  String _errorMessage = '';
  
  // For image handling
  String _mode = 'text'; // 'text' or 'image'
  Uint8List? _decodedImageBytes;
  String? _encodedImageBase64;
  String? _selectedImageName;

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _encode() {
    setState(() {
      _errorMessage = '';
      try {
        final input = _inputController.text;
        if (input.isEmpty) {
          _errorMessage = 'Please enter text to encode';
          _outputController.clear();
          return;
        }
        final bytes = utf8.encode(input);
        final encoded = base64.encode(bytes);
        _outputController.text = encoded;
        HapticFeedback.mediumImpact();
      } catch (e) {
        _errorMessage = 'Error encoding: ${e.toString()}';
        _outputController.clear();
      }
    });
  }

  void _decode() {
    setState(() {
      _errorMessage = '';
      _decodedImageBytes = null;
      
      try {
        String input = _inputController.text.trim();
        if (input.isEmpty) {
          _errorMessage = 'Please enter Base64 text to decode';
          _outputController.clear();
          return;
        }
        
        // Remove data URL prefix if present
        if (input.contains(',')) {
          input = input.split(',').last;
        }
        
        // Clean up the base64 string
        input = input.replaceAll(RegExp(r'\s'), '');
        
        final decoded = base64.decode(input);
        
        // Check if it's an image by looking at magic bytes
        if (_isImage(decoded)) {
          _decodedImageBytes = decoded;
          _outputController.text = '[Image decoded - ${_getImageType(decoded).toUpperCase()} - ${_formatBytes(decoded.length)}]';
        } else {
          // Try to decode as text
          final text = utf8.decode(decoded);
          _outputController.text = text;
        }
        HapticFeedback.mediumImpact();
      } catch (e) {
        _errorMessage = 'Invalid Base64 string';
        _outputController.clear();
      }
    });
  }

  bool _isImage(Uint8List bytes) {
    if (bytes.length < 8) return false;
    
    // PNG: 89 50 4E 47
    if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
      return true;
    }
    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return true;
    }
    // GIF: 47 49 46 38
    if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x38) {
      return true;
    }
    // WebP: 52 49 46 46 ... 57 45 42 50
    if (bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 &&
        bytes.length > 11 && bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50) {
      return true;
    }
    // BMP: 42 4D
    if (bytes[0] == 0x42 && bytes[1] == 0x4D) {
      return true;
    }
    
    return false;
  }

  String _getImageType(Uint8List bytes) {
    if (bytes[0] == 0x89 && bytes[1] == 0x50) return 'png';
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) return 'jpeg';
    if (bytes[0] == 0x47 && bytes[1] == 0x49) return 'gif';
    if (bytes[0] == 0x52 && bytes[1] == 0x49) return 'webp';
    if (bytes[0] == 0x42 && bytes[1] == 0x4D) return 'bmp';
    return 'unknown';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _pickImage() async {
    try {
      const typeGroup = XTypeGroup(
        label: 'Images',
        extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'],
      );
      
      final file = await openFile(acceptedTypeGroups: [typeGroup]);
      
      if (file != null) {
        final bytes = await file.readAsBytes();
        final encoded = base64.encode(bytes);
        
        setState(() {
          _selectedImageName = file.name;
          _encodedImageBase64 = encoded;
          _outputController.text = encoded;
          _errorMessage = '';
        });
        
        HapticFeedback.mediumImpact();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Encoded ${file.name} (${_formatBytes(bytes.length)})'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error reading image: ${e.toString()}';
      });
    }
  }

  Future<void> _saveImage() async {
    if (_decodedImageBytes == null) return;
    
    try {
      final imageType = _getImageType(_decodedImageBytes!);
      final fileName = 'decoded_image.$imageType';
      
      final result = await getSaveLocation(
        suggestedName: fileName,
        acceptedTypeGroups: [
          XTypeGroup(
            label: 'Image',
            extensions: [imageType],
          ),
        ],
      );
      
      if (result != null) {
        final file = File(result.path);
        await file.writeAsBytes(_decodedImageBytes!);
        
        HapticFeedback.mediumImpact();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image saved to ${result.path}'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clear() {
    setState(() {
      _inputController.clear();
      _outputController.clear();
      _errorMessage = '';
      _decodedImageBytes = null;
      _encodedImageBase64 = null;
      _selectedImageName = null;
    });
    HapticFeedback.lightImpact();
  }

  void _swap() {
    setState(() {
      final temp = _inputController.text;
      _inputController.text = _outputController.text;
      _outputController.text = temp;
      _errorMessage = '';
      _decodedImageBytes = null;
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
          // Mode Toggle (Encode/Decode)
          _buildModeToggle(),
          const SizedBox(height: 16),
          
          // Type Toggle (Text/Image)
          _buildTypeToggle(),
          const SizedBox(height: 24),

          // Content based on mode and type
          if (_mode == 'text') ...[
            // Text Input Field
            InputField(
              label: _isEncoding ? 'Text to Encode' : 'Base64 to Decode',
              hint: _isEncoding
                  ? 'Enter your text here...'
                  : 'Enter Base64 string here (supports text & images)...',
              controller: _inputController,
              errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              onChanged: (_) {
                if (_errorMessage.isNotEmpty) {
                  setState(() => _errorMessage = '');
                }
              },
            ),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ] else ...[
            // Image mode
            if (_isEncoding) ...[
              _buildImagePickerCard(),
            ] else ...[
              InputField(
                label: 'Base64 Image String',
                hint: 'Paste Base64 encoded image here...',
                controller: _inputController,
                maxLines: 6,
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                onChanged: (_) {
                  if (_errorMessage.isNotEmpty) {
                    setState(() {
                      _errorMessage = '';
                      _decodedImageBytes = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              ActionButton(
                label: 'Decode Image',
                icon: Icons.image,
                onPressed: _decode,
                isPrimary: true,
              ),
            ],
          ],

          const SizedBox(height: 16),

          // Output section
          if (_mode == 'text') ...[
            OutputField(
              label: _isEncoding ? 'Encoded Base64' : 'Decoded Output',
              controller: _outputController,
            ),
            
            // Show decoded image preview if available
            if (_decodedImageBytes != null) ...[
              const SizedBox(height: 16),
              _buildImagePreview(),
            ],
          ] else ...[
            if (_isEncoding && _encodedImageBase64 != null) ...[
              OutputField(
                label: 'Encoded Base64',
                controller: _outputController,
                maxLines: 8,
              ),
            ],
            if (!_isEncoding && _decodedImageBytes != null) ...[
              _buildImagePreview(),
            ],
          ],

          const SizedBox(height: 16),

          // Swap Button (only for text mode)
          if (_mode == 'text' && _outputController.text.isNotEmpty && _decodedImageBytes == null)
            _buildSwapButton(),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(child: _buildModeButton('Encode', true)),
          Expanded(child: _buildModeButton('Decode', false)),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(child: _buildTypeButton('Text', 'text', Icons.text_fields)),
          Expanded(child: _buildTypeButton('Image', 'image', Icons.image)),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildModeButton(String label, bool isEncode) {
    final isSelected = _isEncoding == isEncode;
    return GestureDetector(
      onTap: () {
        if (_isEncoding != isEncode) {
          setState(() {
            _isEncoding = isEncode;
            _errorMessage = '';
            _decodedImageBytes = null;
          });
          HapticFeedback.selectionClick();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                )
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, String type, IconData icon) {
    final isSelected = _mode == type;
    return GestureDetector(
      onTap: () {
        if (_mode != type) {
          setState(() {
            _mode = type;
            _errorMessage = '';
            _decodedImageBytes = null;
            _encodedImageBase64 = null;
            _selectedImageName = null;
          });
          HapticFeedback.selectionClick();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.3) : null,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? Border.all(color: AppTheme.primaryColor, width: 1) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _selectedImageName != null 
              ? AppTheme.primaryColor.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            _selectedImageName != null ? Icons.check_circle : Icons.cloud_upload,
            size: 48,
            color: _selectedImageName != null ? AppTheme.primaryColor : Colors.white54,
          ),
          const SizedBox(height: 12),
          Text(
            _selectedImageName ?? 'Select an image to encode',
            style: TextStyle(
              color: _selectedImageName != null ? Colors.white : Colors.white54,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ActionButton(
            label: _selectedImageName != null ? 'Change Image' : 'Pick Image',
            icon: Icons.folder_open,
            onPressed: _pickImage,
            isPrimary: true,
          ),
          if (_selectedImageName != null) ...[
            const SizedBox(height: 12),
            ActionButton(
              label: 'Clear',
              icon: Icons.clear,
              onPressed: _clear,
            ),
          ],
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildImagePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Decoded Image Preview',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              TextButton.icon(
                onPressed: _saveImage,
                icon: const Icon(Icons.save, size: 18),
                label: const Text('Save'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              _decodedImageBytes!,
              fit: BoxFit.contain,
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.red.withOpacity(0.1),
                  child: const Center(
                    child: Text(
                      'Error displaying image',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_getImageType(_decodedImageBytes!).toUpperCase()} • ${_formatBytes(_decodedImageBytes!.length)}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ActionButton(
            label: _isEncoding ? 'Encode' : 'Decode',
            icon: _isEncoding ? Icons.lock : Icons.lock_open,
            onPressed: _isEncoding ? _encode : _decode,
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 12),
        ActionButton(label: 'Clear', icon: Icons.clear, onPressed: _clear),
      ],
    );
  }

  Widget _buildSwapButton() {
    return Center(
      child: TextButton.icon(
        onPressed: _swap,
        icon: const Icon(Icons.swap_vert),
        label: const Text('Swap Input/Output'),
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF667eea)),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }
}
