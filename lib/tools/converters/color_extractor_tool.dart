import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../screens/tool_detail_screen.dart';
import '../../models/tool_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/action_button.dart';

class ColorExtractorTool extends StatefulWidget {
  final Tool tool;

  const ColorExtractorTool({super.key, required this.tool});

  @override
  State<ColorExtractorTool> createState() => _ColorExtractorToolState();
}

class _ColorExtractorToolState extends State<ColorExtractorTool> {
  final TextEditingController _urlController = TextEditingController();
  late final WebViewController _webViewController;
  bool _isLoading = false;
  String _errorMessage = '';
  Set<String> _extractedColors = {};
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _progress = progress / 100;
              });
            }
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            _runExtraction();
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint(
              'WebView Error: ${error.description} (${error.errorCode})',
            );
            // Don't show error to user for resource failures (ads, trackers, etc.)
            // unless it's the main page failing (which is hard to distinguish here reliably without logic)
            // We'll rely on the extraction failing or timing out if it's critical.
          },
        ),
      );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _startExtraction() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _extractedColors.clear();
      _progress = 0;
    });

    try {
      String url = _urlController.text.trim();
      if (url.isEmpty) {
        throw Exception('Please enter a URL');
      }
      if (!url.startsWith('http')) {
        url = 'https://$url';
      }

      await _webViewController.loadRequest(Uri.parse(url));
      // The extraction continues in onPageFinished
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _runExtraction() async {
    try {
      const jsCode = """
      (function() {
        const colors = new Set();
        const elements = document.querySelectorAll('*');
        
        function addColor(c) {
          if (!c) return;
          if (c === 'rgba(0, 0, 0, 0)' || c === 'transparent') return;
          colors.add(c);
        }

        for (let el of elements) {
          const style = window.getComputedStyle(el);
          addColor(style.color);
          addColor(style.backgroundColor);
          addColor(style.borderColor);
        }
        return JSON.stringify(Array.from(colors));
      })();
      """;

      final result = await _webViewController.runJavaScriptReturningResult(
        jsCode,
      );
      String jsonString = result.toString();

      // Unquote if it's double-quoted by the bridge
      if (jsonString.startsWith('"') && jsonString.endsWith('"')) {
        jsonString = jsonString.substring(1, jsonString.length - 1);
      }
      // Unescape quotes
      jsonString = jsonString.replaceAll(r'\"', '"');

      // Simple manual parse since we know it's a flat string array
      // or we could use dart:convert but let's just regex it to be safe
      // Actually, let's just use regex to find rgb/rgba patterns in the massive string

      final Set<String> uniqueHexColors = {};

      // Regex to find rgb/rgba in the JSON string
      final regex = RegExp(r'(rgb|rgba|hsl|hsla)\([^)]+\)');
      final matches = regex.allMatches(jsonString);

      for (final match in matches) {
        final colorStr = match.group(0);
        if (colorStr != null) {
          final color = _parseColor(colorStr);
          if (color != null && color.opacity > 0) {
            String hex =
                '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
            uniqueHexColors.add(hex);
          }
        }
      }

      if (mounted) {
        setState(() {
          _extractedColors = uniqueHexColors;
          _isLoading = false;
          if (_extractedColors.isEmpty) {
            _errorMessage = 'No visible colors found.';
          } else {
            HapticFeedback.mediumImpact();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Extraction failed: $e';
          _isLoading = false;
        });
      }
    }
  }

  Color? _parseColor(String colorString) {
    try {
      String s = colorString.trim().toLowerCase();

      // Hex
      if (s.startsWith('#')) {
        String hex = s.replaceAll('#', '');
        if (hex.length == 3) {
          hex = hex.split('').map((c) => '$c$c').join();
        }
        if (hex.length == 6) {
          hex = 'FF$hex';
        }
        return Color(int.parse('0x$hex'));
      }

      // RGB / RGBA
      if (s.startsWith('rgb')) {
        final values = s.replaceAll(RegExp(r'[rgba() ]'), '').split(',');
        if (values.length >= 3) {
          int r = int.parse(values[0]);
          int g = int.parse(values[1]);
          int b = int.parse(values[2]);
          double a = 1.0;
          if (values.length > 3) {
            a = double.parse(values[3]);
          }
          return Color.fromRGBO(r, g, b, a);
        }
      }

      // HSL
      if (s.startsWith('hsl')) {
        final values = s.replaceAll(RegExp(r'[hsl() %]'), '').split(',');
        if (values.length >= 3) {
          double h = double.parse(values[0]);
          double s = double.parse(values[1]) / 100;
          double l = double.parse(values[2]) / 100;
          return HSLColor.fromAHSL(1.0, h, s, l).toColor();
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolDetailScreen(
      tool: widget.tool,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputField(
            label: 'Website URL',
            hint: 'example.com',
            controller: _urlController,
            maxLines: 1,
            errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
            onChanged: (_) {
              if (_errorMessage.isNotEmpty) setState(() => _errorMessage = '');
            },
          ),
          const SizedBox(height: 16),
          ActionButton(
            label: _isLoading
                ? 'Loading Site (${(_progress * 100).toInt()}%)'
                : 'Extract Visible Colors',
            icon: _isLoading ? Icons.hourglass_empty : Icons.visibility,
            onPressed: _isLoading ? () {} : _startExtraction,
            isPrimary: true,
          ),

          // Hidden WebView (must be in tree to work)
          SizedBox(
            height: 1,
            child: WebViewWidget(controller: _webViewController),
          ),

          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_extractedColors.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: _extractedColors.length,
              itemBuilder: (context, index) {
                final colorStr = _extractedColors.elementAt(index);
                final color = _parseColor(colorStr) ?? Colors.grey;

                // Format display string (prefer Hex for consistency)
                String displayStr =
                    '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
                if (color.opacity < 1) {
                  displayStr =
                      'rgba(${color.red},${color.green},${color.blue},${color.opacity.toStringAsFixed(2)})';
                }

                return GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: displayStr));
                    HapticFeedback.selectionClick();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied $displayStr'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: color,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              displayStr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale(delay: (index * 50).ms, duration: 300.ms),
                );
              },
            ),
        ],
      ),
    );
  }
}
