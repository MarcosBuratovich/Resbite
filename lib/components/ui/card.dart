import 'package:flutter/material.dart';
import 'package:resbite_app/styles/tailwind_theme.dart';

/// A shadcn-inspired card component with various configurations.
class ShadCard extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool hasShadow;
  final bool hasBorder;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final Widget? header;
  final Widget? footer;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget>? actions;
  final CrossAxisAlignment crossAxisAlignment;

  const ShadCard({
    super.key,
    this.child,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.hasShadow = true,
    this.hasBorder = true,
    this.padding = const EdgeInsets.all(16),
    this.width,
    this.height,
    this.header,
    this.footer,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.actions,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = backgroundColor ?? colorScheme.surface;
    final cardBorderRadius = borderRadius ?? BorderRadius.circular(12);

    // Card content construction
    Widget cardContent = Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header (if provided)
        if (header != null) header!,

        // Title section
        if (title != null || subtitle != null || leading != null || trailing != null)
          _buildTitleSection(context),

        // Main content
        if (child != null)
          Padding(
            padding: title != null || subtitle != null || leading != null || trailing != null
                ? EdgeInsets.fromLTRB(padding.horizontal / 2, 0, padding.horizontal / 2, padding.vertical / 2)
                : padding,
            child: child,
          ),

        // Actions row
        if (actions != null && actions!.isNotEmpty) _buildActionsRow(),

        // Footer (if provided)
        if (footer != null) footer!,
      ],
    );

    // Apply shadow using TwExtensions if requested
    Widget cardWidget = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: cardBorderRadius,
        border: hasBorder ? Border.all(color: colorScheme.outline, width: 1) : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: cardBorderRadius,
        clipBehavior: Clip.antiAlias,
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: cardBorderRadius,
                child: cardContent,
              )
            : cardContent,
      ),
    );

    // Apply shadow if requested
    if (hasShadow) {
      return cardWidget.shadowMd;
    }

    return cardWidget;
  }

  /// Builds the title section with title, subtitle, leading and trailing widgets
  Widget _buildTitleSection(BuildContext context) {
    if (title == null && subtitle == null && leading == null && trailing == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        padding.horizontal / 2,
        padding.vertical / 2,
        padding.horizontal / 2,
        subtitle != null ? 4 : padding.vertical / 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Leading widget
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: TwTypography.heading6(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (title != null && subtitle != null) 
                  const SizedBox(height: 4),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TwTypography.bodySm(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Trailing widget
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }

  /// Builds the actions row for the card
  Widget _buildActionsRow() {
    if (actions == null || actions!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.all(padding.horizontal / 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: actions!.map((action) => 
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: action,
          )
        ).toList(),
      ),
    );
  }

  // Factory constructors for different card variants

  /// Default card with border and shadow
  factory ShadCard.default_({
    Key? key,
    Widget? child,
    VoidCallback? onTap,
    double? width,
    double? height,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    Widget? header,
    Widget? footer,
    String? title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    List<Widget>? actions,
  }) {
    return ShadCard(
      key: key,
      child: child,
      onTap: onTap,
      width: width,
      height: height,
      padding: padding,
      header: header,
      footer: footer,
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      actions: actions,
      hasShadow: true,
      hasBorder: true,
    );
  }

  /// Elevated card with shadow but no border
  factory ShadCard.elevated({
    Key? key,
    Widget? child,
    VoidCallback? onTap,
    double? width,
    double? height,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    Widget? header,
    Widget? footer,
    String? title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    List<Widget>? actions,
  }) {
    return ShadCard(
      key: key,
      child: child,
      onTap: onTap,
      width: width,
      height: height,
      padding: padding,
      header: header,
      footer: footer,
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      actions: actions,
      hasShadow: true,
      hasBorder: false,
    );
  }

  /// Outlined card with border but no shadow
  factory ShadCard.outlined({
    Key? key,
    Widget? child,
    VoidCallback? onTap,
    double? width,
    double? height,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    Widget? header,
    Widget? footer,
    String? title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    List<Widget>? actions,
  }) {
    return ShadCard(
      key: key,
      child: child,
      onTap: onTap,
      width: width,
      height: height,
      padding: padding,
      header: header,
      footer: footer,
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      actions: actions,
      hasShadow: false,
      hasBorder: true,
    );
  }

  /// Flat card with no border and no shadow
  factory ShadCard.flat({
    Key? key,
    Widget? child,
    VoidCallback? onTap,
    double? width,
    double? height,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    Widget? header,
    Widget? footer,
    String? title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    List<Widget>? actions,
  }) {
    return ShadCard(
      key: key,
      child: child,
      onTap: onTap,
      width: width,
      height: height,
      padding: padding,
      header: header,
      footer: footer,
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      actions: actions,
      hasShadow: false,
      hasBorder: false,
    );
  }
}

/// Extension for easier access to padding dimensions
extension EdgeInsetsGeometryExtension on EdgeInsetsGeometry {
  double get horizontal {
    final edgeInsets = this.resolve(TextDirection.ltr);
    return edgeInsets.left + edgeInsets.right;
  }

  double get vertical {
    final edgeInsets = this.resolve(TextDirection.ltr);
    return edgeInsets.top + edgeInsets.bottom;
  }
}