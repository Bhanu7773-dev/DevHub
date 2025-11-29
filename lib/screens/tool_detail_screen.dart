import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/tool_model.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_layout.dart';
import '../services/favorites_service.dart';

class ToolDetailScreen extends StatelessWidget {
  final Tool tool;
  final Widget child;

  const ToolDetailScreen({super.key, required this.tool, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              _buildAppBar(context),

              // Tool Content
              Expanded(
                child: SingleChildScrollView(
                  padding: ResponsiveLayout.getResponsivePadding(context),
                  physics: const BouncingScrollPhysics(),
                  child: ResponsiveLayout(
                    maxWidth: 800,
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back Button
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              tooltip: 'Back',
              onPressed: () => Navigator.pop(context),
            ),
          ).animate().fadeIn().slideX(begin: -0.2, end: 0),

          const SizedBox(width: 16),

          // Tool Icon and Title
          Expanded(
            child: Row(
              children: [
                Hero(
                  tag: 'tool_icon_${tool.id}',
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tool.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tool.name,
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        tool.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0),
          ),

          // Favorite Button
          ValueListenableBuilder<List<String>>(
            valueListenable: FavoritesService().favoritesNotifier,
            builder: (context, favorites, _) {
              final isFavorite = favorites.contains(tool.id);
              return Container(
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.redAccent : Colors.white,
                  ),
                  tooltip: isFavorite
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                  onPressed: () {
                    FavoritesService().toggleFavorite(tool.id);
                    HapticFeedback.selectionClick();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFavorite
                              ? 'Removed from favorites'
                              : 'Added to favorites',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ).animate().fadeIn().slideX(begin: 0.2, end: 0);
            },
          ),
        ],
      ),
    );
  }
}
