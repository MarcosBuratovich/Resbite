import 'package:flutter/material.dart';
import 'package:resbite_app/styles/tailwind_theme.dart';

/// Button variants
enum ButtonVariant {
  default_,
  outline,
  ghost,
  destructive,
  link,
}

/// Button sizes
enum ButtonSize {
  sm,
  md,
  lg,
}

/// A shadcn-inspired button component with a variety of variants.
class ShadButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool iconTrailing;
  final bool isLoading;
  final bool isFullWidth;

  const ShadButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.default_,
    this.size = ButtonSize.md,
    this.icon,
    this.iconTrailing = false,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Determine button styling based on variant
    Color backgroundColor;
    Color textColor;
    Color? borderColor;
    
    switch (variant) {
      case ButtonVariant.default_:
        backgroundColor = colorScheme.primary;
        textColor = colorScheme.onPrimary;
        borderColor = null;
        break;
      case ButtonVariant.outline:
        backgroundColor = Colors.transparent;
        textColor = colorScheme.primary;
        borderColor = colorScheme.primary;
        break;
      case ButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        textColor = colorScheme.onSurface;
        borderColor = null;
        break;
      case ButtonVariant.destructive:
        backgroundColor = colorScheme.error;
        textColor = colorScheme.onError;
        borderColor = null;
        break;
      case ButtonVariant.link:
        backgroundColor = Colors.transparent;
        textColor = colorScheme.primary;
        borderColor = null;
        break;
    }
    
    // Determine padding and text style based on size
    EdgeInsetsGeometry padding;
    double iconSize;
    TextStyle textStyle;
    double height;
    
    switch (size) {
      case ButtonSize.sm:
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
        iconSize = 16.0;
        textStyle = TwTypography.labelSm(context);
        height = 32;
        break;
      case ButtonSize.lg:
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
        iconSize = 24.0;
        textStyle = TwTypography.label(context);
        height = 48;
        break;
      case ButtonSize.md:
      // ignore: unreachable_switch_default
      default:
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
        iconSize = 20.0;
        textStyle = TwTypography.labelSm(context);
        height = 40;
        break;
    }
    
    // Build button content
    Widget content;
    
    if (isLoading) {
      // Loading spinner
      content = SizedBox(
        height: iconSize,
        width: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    } else {
      // Button text with optional icon
      if (icon != null) {
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!iconTrailing) ...[
              Icon(icon, size: iconSize, color: textColor),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: textStyle.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (iconTrailing) ...[
              const SizedBox(width: 8),
              Icon(icon, size: iconSize, color: textColor),
            ],
          ],
        );
      } else {
        content = Text(
          text,
          style: textStyle.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        );
      }
    }
    
    // Build button with appropriate styling
    Widget button;
    
    if (variant == ButtonVariant.link) {
      // Link style button
      button = InkWell(
        onTap: isLoading ? null : onPressed,
        child: Padding(
          padding: padding,
          child: content,
        ),
      );
    } else {
      // Regular button
      button = Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: borderColor != null 
                  ? Border.all(color: borderColor) 
                  : null,
            ),
            child: Center(child: content),
          ),
        ),
      );
    }
    
    // Apply full width if needed
    if (isFullWidth) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    
    return button;
  }

  // Factory constructors for different button variants

  /// Primary button with brand color
  factory ShadButton.primary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.md,
    IconData? icon,
    bool iconTrailing = false,
    bool isLoading = false,
    bool isFullWidth = false,
  }) {
    return ShadButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.default_,
      size: size,
      icon: icon,
      iconTrailing: iconTrailing,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  /// Secondary (outline) button
  factory ShadButton.secondary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.md,
    IconData? icon,
    bool iconTrailing = false,
    bool isLoading = false,
    bool isFullWidth = false,
  }) {
    return ShadButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.outline,
      size: size,
      icon: icon,
      iconTrailing: iconTrailing,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  /// Ghost button (no background)
  factory ShadButton.ghost({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.md,
    IconData? icon,
    bool iconTrailing = false,
    bool isLoading = false,
    bool isFullWidth = false,
  }) {
    return ShadButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.ghost,
      size: size,
      icon: icon,
      iconTrailing: iconTrailing,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  /// Destructive button (red/error variant)
  factory ShadButton.destructive({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.md,
    IconData? icon,
    bool iconTrailing = false,
    bool isLoading = false,
    bool isFullWidth = false,
  }) {
    return ShadButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.destructive,
      size: size,
      icon: icon,
      iconTrailing: iconTrailing,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  /// Link-styled button
  factory ShadButton.link({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.md,
    IconData? icon,
    bool iconTrailing = false,
    bool isLoading = false,
    bool isFullWidth = false,
  }) {
    return ShadButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.link,
      size: size,
      icon: icon,
      iconTrailing: iconTrailing,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }
}