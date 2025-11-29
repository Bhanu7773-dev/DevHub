import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/tool_model.dart';
import '../models/tool_category.dart';
import '../utils/app_theme.dart';
import '../tools/encoders/base64_tool.dart';
import '../tools/encoders/url_encoder_tool.dart';
import '../tools/generators/uuid_generator.dart';
import '../tools/generators/password_generator.dart';
import '../tools/generators/hash_generator.dart';
import '../tools/formatters/json_formatter.dart';
import '../tools/encoders/html_encoder_tool.dart';
import '../tools/encoders/jwt_decoder_tool.dart';
import '../tools/encoders/unicode_converter.dart';
import '../tools/generators/lorem_ipsum_generator.dart';
import '../tools/converters/color_converter.dart';
import '../tools/converters/number_base_converter.dart';
import '../tools/converters/timestamp_converter.dart';
import '../tools/converters/case_converter.dart';
import '../tools/text_tools/regex_tester.dart';
import '../tools/text_tools/word_counter.dart';
import '../tools/generators/random_data_generator.dart';
import '../tools/text_tools/text_diff.dart';
import '../tools/text_tools/string_reverser.dart';
import '../tools/text_tools/duplicate_remover.dart';
import '../tools/formatters/xml_formatter.dart';
import '../tools/formatters/css_formatter.dart';
import '../tools/formatters/sql_formatter.dart';
import '../tools/converters/css_unit_converter.dart';
import '../tools/formatters/email_validator.dart';
import '../tools/formatters/url_validator.dart';
import '../tools/generators/gradient_generator.dart';
import '../tools/converters/screen_size_tool.dart';
import '../tools/generators/material_palette.dart';
import '../tools/converters/aspect_ratio_tool.dart';
import '../tools/text_tools/ip_info_tool.dart';
import '../tools/converters/color_extractor_tool.dart';
import '../tools/converters/image_color_extractor_tool.dart';
import '../tools/design/font_pair_finder_tool.dart';
import '../tools/generators/mock_data_tool.dart';
import '../services/favorites_service.dart';
import '../services/history_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'all';

  List<Tool> get _filteredTools {
    final favorites = FavoritesService().favoritesNotifier.value;
    final history = HistoryService().historyNotifier.value;

    // For 'recent' category, we want to maintain the order of history
    if (_selectedCategory == 'recent') {
      return history
          .map(
            (id) => availableTools.firstWhere(
              (t) => t.id == id,
              orElse: () => availableTools[0],
            ),
          )
          .where(
            (t) => t.id != 'base64' || history.contains('base64'),
          ) // Hack to filter out fallback if not found
          .where(
            (tool) =>
                tool.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                tool.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return availableTools.where((tool) {
      final matchesSearch =
          tool.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tool.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tool.tags.any(
            (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()),
          );

      bool matchesCategory = true;
      if (_selectedCategory == 'favorites') {
        matchesCategory = favorites.contains(tool.id);
      } else if (_selectedCategory == 'recent') {
        matchesCategory = history.contains(tool.id);
      } else if (_selectedCategory != 'all') {
        matchesCategory = tool.categoryId == _selectedCategory;
      }

      return matchesSearch && matchesCategory;
    }).toList();
  }

  Widget _getToolScreen(Tool tool) {
    // Return actual tool screens
    switch (tool.id) {
      case 'base64':
        return Base64Tool(tool: tool);
      case 'url_encoder':
        return UrlEncoderTool(tool: tool);
      case 'uuid':
        return UuidGeneratorTool(tool: tool);
      case 'password':
        return PasswordGeneratorTool(tool: tool);
      case 'hash':
        return HashGeneratorTool(tool: tool);
      case 'json':
        return JsonFormatterTool(tool: tool);
      case 'html_encoder':
        return HtmlEncoderTool(tool: tool);
      case 'jwt_decoder':
        return JwtDecoderTool(tool: tool);
      case 'unicode':
        return UnicodeConverterTool(tool: tool);
      case 'lorem':
        return LoremIpsumTool(tool: tool);
      case 'color':
        return ColorConverterTool(tool: tool);
      case 'number_base':
        return NumberBaseConverterTool(tool: tool);
      case 'timestamp':
        return TimestampConverterTool(tool: tool);
      case 'case_converter':
        return CaseConverterTool(tool: tool);
      case 'regex':
        return RegexTesterTool(tool: tool);
      case 'word_counter':
        return WordCounterTool(tool: tool);
      case 'random_data':
        return RandomDataTool(tool: tool);
      case 'text_diff':
        return TextDiffTool(tool: tool);
      case 'string_reverser':
        return StringReverserTool(tool: tool);
      case 'duplicate_remover':
        return DuplicateRemoverTool(tool: tool);
      case 'xml':
        return XmlFormatterTool(tool: tool);
      case 'css':
        return CssFormatterTool(tool: tool);
      case 'sql':
        return SqlFormatterTool(tool: tool);
      case 'css_units':
        return CssUnitConverterTool(tool: tool);
      case 'email_validator':
        return EmailValidatorTool(tool: tool);
      case 'url_validator':
        return UrlValidatorTool(tool: tool);
      case 'gradient_generator':
        return GradientGeneratorTool(tool: tool);
      case 'screen_size':
        return ScreenSizeTool(tool: tool);
      case 'material_palette':
        return MaterialPaletteTool(tool: tool);
      case 'aspect_ratio':
        return AspectRatioTool(tool: tool);
      case 'ip_info':
        return IpInfoTool(tool: tool);
      case 'color_extractor':
        return ColorExtractorTool(tool: tool);
      case 'image_color_extractor':
        return ImageColorExtractorTool(tool: tool);
      case 'font_pair_finder':
        return FontPairFinderTool(tool: tool);
      case 'mock_data':
        return MockDataTool(tool: tool);
      default:
        // Placeholder for other tools
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(tool.icon, style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    tool.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Coming soon!',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(),

              // Search Bar
              _buildSearchBar(),

              // Category Chips
              _buildCategoryChips(),

              // Tools Grid
              Expanded(child: _buildToolsGrid()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.developer_mode,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DevHub', style: Theme.of(context).textTheme.displaySmall),
              Text(
                '20+ Developer Tools',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white54),
              ),
            ],
          ),

          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              tooltip: 'Settings',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.2, end: 0);
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search tools...',
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54),
                  tooltip: 'Clear search',
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms);
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
          bottom: 10,
        ),
        children: [
          _buildCategoryChip('all', 'All', '📱'),
          _buildCategoryChip('favorites', 'Favorites', '❤️'),
          _buildCategoryChip('recent', 'Recent', '🕒'),
          ...toolCategories.map(
            (category) =>
                _buildCategoryChip(category.id, category.name, category.icon),
          ),
          const SizedBox(width: 12), // Extra padding at the end
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 300.ms);
  }

  Widget _buildCategoryChip(String id, String label, String icon) {
    final isSelected = _selectedCategory == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = id;
          });
        },
        backgroundColor: AppTheme.surfaceColor,
        selectedColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildToolsGrid() {
    return ValueListenableBuilder<List<String>>(
      valueListenable: FavoritesService().favoritesNotifier,
      builder: (context, favorites, _) {
        return ValueListenableBuilder<List<String>>(
          valueListenable: HistoryService().historyNotifier,
          builder: (context, history, _) {
            // Force rebuild when favorites change if we are in favorites category
            // or just to show favorite status on cards (if we add that later)
            if (_filteredTools.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _selectedCategory == 'favorites'
                          ? Icons.favorite_border
                          : _selectedCategory == 'recent'
                          ? Icons.history
                          : Icons.search_off,
                      size: 64,
                      color: Colors.white24,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedCategory == 'favorites'
                          ? 'No favorites yet'
                          : _selectedCategory == 'recent'
                          ? 'No recent tools'
                          : 'No tools found',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white54),
                    ),
                  ],
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                // Calculate number of columns based on available width
                final width = constraints.maxWidth;
                int crossAxisCount;
                double spacing;
                double aspectRatio;
                
                if (width > 1200) {
                  crossAxisCount = 6;
                  spacing = 16;
                  aspectRatio = 1.0;
                } else if (width > 900) {
                  crossAxisCount = 5;
                  spacing = 14;
                  aspectRatio = 1.0;
                } else if (width > 600) {
                  crossAxisCount = 4;
                  spacing = 12;
                  aspectRatio = 1.0;
                } else if (width > 400) {
                  crossAxisCount = 3;
                  spacing = 10;
                  aspectRatio = 0.9;
                } else {
                  crossAxisCount = 3;  // 3 columns on small phones too
                  spacing = 8;
                  aspectRatio = 0.85;
                }

                return GridView.builder(
                  padding: EdgeInsets.all(width > 600 ? 20 : 12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    childAspectRatio: aspectRatio,
                  ),
                  itemCount: _filteredTools.length,
                  itemBuilder: (context, index) {
                    return _buildToolCard(_filteredTools[index], index);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildToolCard(Tool tool, int index) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust sizes based on card size
        final cardHeight = constraints.maxHeight;
        final isCompact = cardHeight < 120;
        final iconSize = isCompact ? 18.0 : 24.0;
        final iconPadding = isCompact ? 6.0 : 8.0;
        final titleSize = isCompact ? 10.0 : 12.0;
        final cardPadding = isCompact ? 4.0 : 8.0;
        
        return Card(
          child: InkWell(
            onTap: () {
              HistoryService().addToHistory(tool.id);
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      _getToolScreen(tool),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        var tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);
                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(cardPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: 'tool_icon_${tool.id}',
                    child: Container(
                      padding: EdgeInsets.all(iconPadding),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tool.icon,
                        style: TextStyle(fontSize: iconSize),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      tool.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: titleSize,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).animate()
        .fadeIn(delay: (index * 20).ms, duration: 300.ms)
        .scale(begin: const Offset(0.8, 0.8));
  }
}
