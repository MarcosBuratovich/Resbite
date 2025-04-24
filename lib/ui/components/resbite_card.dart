import 'package:flutter/material.dart';
import '../../config/theme.dart';

class ResbiteCard extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onTap;
  final Color? color;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? elevation;
  final Widget? header;
  final Widget? footer;
  final double? width;
  final double? height;
  final String? title;
  final String? subtitle;
  final ImageProvider? imageProvider;
  final bool showShadow;
  final bool useGradient;
  final bool usePrimaryGradient;
  final Gradient? customGradient;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget>? actions;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final bool hideOverflow;

  const ResbiteCard({
    super.key,
    this.child,
    this.onTap,
    this.color,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.borderRadius,
    this.elevation,
    this.header,
    this.footer,
    this.width,
    this.height,
    this.title,
    this.subtitle,
    this.imageProvider,
    this.showShadow = true,
    this.useGradient = false,
    this.usePrimaryGradient = true,
    this.customGradient,
    this.leading,
    this.trailing,
    this.actions,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
    this.hideOverflow = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = backgroundColor ?? color ?? Theme.of(context).colorScheme.surface;
    final cardTextColor = textColor ?? Theme.of(context).colorScheme.onSurface;
    final cardElevation = elevation ?? (showShadow ? 2.0 : 0.0);
    final cardBorderRadius = borderRadius ?? BorderRadius.circular(16);
    
    // Determine if we should use gradient background
    BoxDecoration? decoration;
    if (useGradient) {
      if (customGradient != null) {
        // Use custom gradient
        decoration = BoxDecoration(
          gradient: customGradient,
          borderRadius: cardBorderRadius,
          boxShadow: showShadow ? [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ] : null,
        );
      } else {
        // Use theme gradient
        decoration = AppTheme.gradientBoxDecoration(
          primary: usePrimaryGradient,
          borderRadius: cardBorderRadius.topLeft.x,
        );
      }
    } else if (backgroundColor != null) {
      // Use solid background color
      decoration = BoxDecoration(
        color: backgroundColor,
        borderRadius: cardBorderRadius,
        boxShadow: showShadow ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      );
    } else {
      decoration = null;
    }
    
    Widget buildTitle() {
      if (title == null && subtitle == null && leading == null && trailing == null) {
        return const SizedBox.shrink();
      }
      
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, subtitle != null ? 4 : 16),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cardTextColor,
                      ),
                      maxLines: hideOverflow ? 1 : 2,
                      overflow: hideOverflow ? TextOverflow.ellipsis : TextOverflow.visible,
                    ),
                  if (title != null && subtitle != null)
                    const SizedBox(height: 4),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cardTextColor.withOpacity(0.9),
                      ),
                      maxLines: hideOverflow ? 2 : 3,
                      overflow: hideOverflow ? TextOverflow.ellipsis : TextOverflow.visible,
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
    
    Widget buildActions() {
      if (actions == null || actions!.isEmpty) {
        return const SizedBox.shrink();
      }
      
      return Padding(
        padding: const EdgeInsets.all(8.0),
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
    
    Widget cardContent = Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: [
        // Header
        if (header != null) header!,
        
        // Image
        if (imageProvider != null)
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(cardBorderRadius.topLeft.y)),
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
              child: Image(
                image: imageProvider!,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.image,
                      size: 40,
                      color: AppTheme.primaryColor.withOpacity(0.6),
                    ),
                  );
                },
              ),
            ),
          ),
        
        // Title and subtitle
        buildTitle(),
        
        // Main content
        if (child != null)
          Padding(
            padding: padding ?? (title != null || subtitle != null 
              ? const EdgeInsets.fromLTRB(16, 0, 16, 16)
              : const EdgeInsets.all(16)),
            child: child,
          ),
        
        // Action buttons
        if (actions != null && actions!.isNotEmpty)
          buildActions(),
        
        // Footer
        if (footer != null) footer!,
      ],
    );
    
    // Wrap with Material for ink effects if onTap is provided
    if (onTap != null) {
      if (useGradient) {
        return Container(
          width: width,
          height: height,
          decoration: decoration,
          child: Material(
            color: Colors.transparent,
            borderRadius: cardBorderRadius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: cardContent,
            ),
          ),
        );
      }
      
      return Card(
        color: cardColor,
        elevation: cardElevation,
        shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: cardBorderRadius,
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: cardBorderRadius,
          child: SizedBox(
            width: width,
            height: height,
            child: cardContent,
          ),
        ),
      );
    }
    
    // Regular card if no onTap and no gradient
    if (!useGradient) {
      return Card(
        color: cardColor,
        elevation: cardElevation,
        shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: cardBorderRadius,
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: SizedBox(
          width: width,
          height: height,
          child: cardContent,
        ),
      );
    }
    
    // Gradient background card
    return Container(
      width: width,
      height: height,
      decoration: decoration,
      child: cardContent,
    );
  }
}