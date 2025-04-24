import 'package:flutter/material.dart';

/// Badge variant
enum BadgeVariant {
  default_,
  secondary,
  outline,
  destructive,
}

/// Badge sizes
enum BadgeSize {
  sm,
  md,
  lg,
}

/// A shadcn-inspired badge component.
class ShadBadge extends StatelessWidget {
  final String text;
  final BadgeVariant variant;
  final BadgeSize size;
  final IconData? icon;
  final bool iconTrailing;
  final VoidCallback? onTap;
  final bool removable;
  final VoidCallback? onRemove;

  const ShadBadge({
    super.key,
    required this.text,
    this.variant = BadgeVariant.default_,
    this.size = BadgeSize.md,
    this.icon,
    this.iconTrailing = false,
    this.onTap,
    this.removable = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Size configuration
    double height;
    double fontSize;
    double iconSize;
    EdgeInsets padding;
    
    switch (size) {
      case BadgeSize.sm:
        height = 24;
        fontSize = 12;
        iconSize = 14;
        padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 2);
        break;
      case BadgeSize.lg:
        height = 32;
        fontSize = 14;
        iconSize = 18;
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
        break;
      case BadgeSize.md:
      // ignore: unreachable_switch_default
      default:
        height = 28;
        fontSize = 13;
        iconSize = 16;
        padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
        break;
    }
    
    // Color configuration based on variant
    Color backgroundColor;
    Color textColor;
    Color borderColor;
    
    switch (variant) {
      case BadgeVariant.secondary:
        backgroundColor = colorScheme.secondaryContainer;
        textColor = colorScheme.onSecondaryContainer;
        borderColor = Colors.transparent;
        break;
      case BadgeVariant.outline:
        backgroundColor = Colors.transparent;
        textColor = colorScheme.onBackground;
        borderColor = colorScheme.outline;
        break;
      case BadgeVariant.destructive:
        backgroundColor = colorScheme.error;
        textColor = colorScheme.onError;
        borderColor = Colors.transparent;
        break;
      case BadgeVariant.default_:
      // ignore: unreachable_switch_default
      default:
        backgroundColor = colorScheme.primary;
        textColor = colorScheme.onPrimary;
        borderColor = Colors.transparent;
        break;
    }
    
    // Widget with icon, text, and remove button if needed
    Widget badgeContent = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Leading icon
        if (icon != null && !iconTrailing) ...[
          Icon(
            icon,
            size: iconSize,
            color: textColor,
          ),
          SizedBox(width: size == BadgeSize.sm ? 4 : 6),
        ],
        
        // Text
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        // Trailing icon
        if (icon != null && iconTrailing) ...[
          SizedBox(width: size == BadgeSize.sm ? 4 : 6),
          Icon(
            icon,
            size: iconSize,
            color: textColor,
          ),
        ],
        
        // Remove button
        if (removable) ...[
          SizedBox(width: size == BadgeSize.sm ? 4 : 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: iconSize,
              color: textColor,
            ),
          ),
        ],
      ],
    );
    
    // Wrap in material for tap feedback if onTap is provided
    Widget badge = Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
        border: variant == BadgeVariant.outline
            ? Border.all(color: borderColor, width: 1)
            : null,
      ),
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(height / 2),
                child: badgeContent,
              ),
            )
          : badgeContent,
    );
    
    return badge;
  }

  // Factory constructors for different badge variants

  /// Default primary badge
  factory ShadBadge.primary({
    Key? key,
    required String text,
    BadgeSize size = BadgeSize.md,
    IconData? icon,
    bool iconTrailing = false,
    VoidCallback? onTap,
    bool removable = false,
    VoidCallback? onRemove,
  }) {
    return ShadBadge(
      key: key,
      text: text,
      variant: BadgeVariant.default_,
      size: size,
      icon: icon,
      iconTrailing: iconTrailing,
      onTap: onTap,
      removable: removable,
      onRemove: onRemove,
    );
  }

  /// Secondary badge
  factory ShadBadge.secondary({
    Key? key,
    required String text,
    BadgeSize size = BadgeSize.md,
    IconData? icon,
    bool iconTrailing = false,
    VoidCallback? onTap,
    bool removable = false,
    VoidCallback? onRemove,
  }) {
    return ShadBadge(
      key: key,
      text: text,
      variant: BadgeVariant.secondary,
      size: size,
      icon: icon,
      iconTrailing: iconTrailing,
      onTap: onTap,
      removable: removable,
      onRemove: onRemove,
    );
  }

  /// Outlined badge
  factory ShadBadge.outline({
    Key? key,
    required String text,
    BadgeSize size = BadgeSize.md,
    IconData? icon,
    bool iconTrailing = false,
    VoidCallback? onTap,
    bool removable = false,
    VoidCallback? onRemove,
  }) {
    return ShadBadge(
      key: key,
      text: text,
      variant: BadgeVariant.outline,
      size: size,
      icon: icon,
      iconTrailing: iconTrailing,
      onTap: onTap,
      removable: removable,
      onRemove: onRemove,
    );
  }

  /// Destructive/error badge
  factory ShadBadge.destructive({
    Key? key,
    required String text,
    BadgeSize size = BadgeSize.md,
    IconData? icon,
    bool iconTrailing = false,
    VoidCallback? onTap,
    bool removable = false,
    VoidCallback? onRemove,
  }) {
    return ShadBadge(
      key: key,
      text: text,
      variant: BadgeVariant.destructive,
      size: size,
      icon: icon,
      iconTrailing: iconTrailing,
      onTap: onTap,
      removable: removable,
      onRemove: onRemove,
    );
  }
}