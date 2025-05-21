import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../models/category.dart';
import '../../../../../config/feature_flags.dart';

/// A filter component for activity categories with support for both modern and legacy UI
class CategoryFilter extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;
  final bool showAllOption;

  const CategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.showAllOption = true,
  });

  @override
  Widget build(BuildContext context) {
    // Use modern or legacy UI based on feature flag
    return FeatureFlags.useModernUI
        ? _buildModernCategoriesFilter(context)
        : _buildLegacyCategoriesFilter(context);
  }

  /// Builds the modern, animated category filter UI
  Widget _buildModernCategoriesFilter(BuildContext context) {
    // List to hold all chips including "All" chip
    final List<Widget> allChips = [];

    // Add "All" chip if needed
    if (showAllOption) {
      allChips.add(
        _buildModernCategoryChip(
          context,
          null, // null represents "All" categories
          'All',
          selectedCategoryId == null,
        ),
      );
    }

    // Add chips for each category
    for (final category in categories) {
      allChips.add(
        _buildModernCategoryChip(
          context,
          category.id,
          category.name,
          selectedCategoryId == category.id,
        ),
      );
    }

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: allChips,
      ),
    );
  }

  /// Builds a single modern category chip with animations
  Widget _buildModernCategoryChip(
    BuildContext context,
    String? categoryId,
    String title,
    bool selected,
  ) {
    // Generate a consistent color for the category based on its name
    final Color tagColor = _getCategoryColor(context, title);

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
            onTap: () => onCategorySelected(categoryId),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? tagColor : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                boxShadow:
                    selected
                        ? [
                          BoxShadow(
                            color: tagColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : const Color(0xFF462748),
                ),
              ),
            ),
          )
          .animate()
          .slide(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
            duration: 250.ms,
            curve: Curves.easeOutBack,
          )
          .fadeIn(duration: 200.ms),
    );
  }

  /// Builds the legacy Material Design 3 categories filter
  Widget _buildLegacyCategoriesFilter(BuildContext context) {
    // List to hold all chips including "All" chip
    final List<Widget> allChips = [];

    // Add "All" chip if needed
    if (showAllOption) {
      allChips.add(
        _buildLegacyCategoryChip(
          context,
          null, // null represents "All" categories
          'All',
          selectedCategoryId == null,
        ),
      );
    }

    // Add chips for each category
    for (final category in categories) {
      allChips.add(
        _buildLegacyCategoryChip(
          context,
          category.id,
          category.name,
          selectedCategoryId == category.id,
        ),
      );
    }

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: allChips,
      ),
    );
  }

  /// Builds a single legacy Material Design 3 category chip
  Widget _buildLegacyCategoryChip(
    BuildContext context,
    String? categoryId,
    String title,
    bool selected,
  ) {
    // Use different colors for different categories to create visual variety
    final Color chipColor = _getCategoryColor(context, title);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          title,
          style: TextStyle(
            color:
                selected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        selected: selected,
        showCheckmark: false,
        // Use avatar icon with selected color
        avatar:
            selected
                ? Icon(Icons.check_circle, size: 18, color: chipColor)
                : Icon(Icons.circle, size: 12, color: chipColor),
        // Use proper Material Design 3 color scheme
        selectedColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onSelected: (_) => onCategorySelected(categoryId),
      ),
    );
  }

  /// Generates a consistent color for a category based on its name
  Color _getCategoryColor(BuildContext context, String name) {
    final colorOptions = [
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
      Theme.of(context).colorScheme.primary,
    ];

    // Use hash code for consistent color selection
    return colorOptions[name.hashCode % colorOptions.length];
  }
}
