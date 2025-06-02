// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../config/theme.dart';

enum ResbiteBtnType { primary, secondary, text, gradient }

enum ResbiteBtnSize { small, medium, large }

enum ResbiteBtnShape { rounded, pill, square }

class ResbiteButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ResbiteBtnType type;
  final ResbiteBtnSize size;
  final ResbiteBtnShape shape;
  final IconData? icon;
  final Widget? customIcon;
  final bool isLoading;
  final bool fullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;

  const ResbiteButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ResbiteBtnType.primary,
    this.size = ResbiteBtnSize.medium,
    this.shape = ResbiteBtnShape.rounded,
    this.icon,
    this.customIcon,
    this.isLoading = false,
    this.fullWidth = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Get the theme colors
    Theme.of(context);

    // Define sizes
    double horizontalPadding;
    double verticalPadding;
    double fontSize;
    double iconSize;
    double borderRadius;

    switch (size) {
      case ResbiteBtnSize.small:
        horizontalPadding = 12;
        verticalPadding = 8;
        fontSize = 12;
        iconSize = 16;
        break;
      case ResbiteBtnSize.large:
        horizontalPadding = 24;
        verticalPadding = 16;
        fontSize = 16;
        iconSize = 24;
        break;
      case ResbiteBtnSize.medium:
        horizontalPadding = 16;
        verticalPadding = 12;
        fontSize = 14;
        iconSize = 20;
        break;
    }

    // Define shape
    switch (shape) {
      case ResbiteBtnShape.pill:
        borderRadius = 50; // Very large value for pill shape
        break;
      case ResbiteBtnShape.square:
        borderRadius = 4; // Small value for more square corners
        break;
      case ResbiteBtnShape.rounded:
        borderRadius = 12;
        break;
    }

    // Define colors based on type
    Color bgColor;
    Color txtColor;
    Color? shadowColor;

    switch (type) {
      case ResbiteBtnType.secondary:
        bgColor = Colors.transparent;
        txtColor = AppTheme.primaryColor;
        shadowColor = null;
        break;
      case ResbiteBtnType.text:
        bgColor = Colors.transparent;
        txtColor = AppTheme.primaryColor;
        shadowColor = null;
        break;
      case ResbiteBtnType.gradient:
        bgColor = Colors.transparent; // Will use gradient decoration instead
        txtColor = AppTheme.lightTextColor;
        shadowColor = AppTheme.primaryColor.withOpacity(0.3);
        break;
      case ResbiteBtnType.primary:
        bgColor = backgroundColor ?? AppTheme.primaryColor;
        txtColor = textColor ?? AppTheme.lightTextColor;
        shadowColor = AppTheme.primaryColor.withOpacity(0.3);
        break;
    }

    // Apply custom colors if provided
    if (backgroundColor != null && type != ResbiteBtnType.gradient) {
      bgColor = backgroundColor!;
    }

    if (textColor != null) {
      txtColor = textColor!;
    }

    // Button content
    Widget buttonContent;

    if (isLoading) {
      // Loading indicator
      buttonContent = SizedBox(
        height: iconSize,
        width: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(txtColor),
        ),
      );
    } else if (icon != null || customIcon != null) {
      // Button with icon and text
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (customIcon != null)
            customIcon!
          else if (icon != null)
            Icon(icon, size: iconSize, color: txtColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: txtColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      );
    } else {
      // Text only button
      buttonContent = Text(
        text,
        style: TextStyle(
          color: txtColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        textAlign: TextAlign.center,
      );
    }

    // Custom gradient button
    if (type == ResbiteBtnType.gradient) {
      return Container(
        width: fullWidth ? double.infinity : null,
        decoration: AppTheme.gradientBoxDecoration(
          primary: true,
          borderRadius: borderRadius,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            padding:
                padding ??
                EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: buttonContent,
        ),
      );
    }

    // Button style
    ButtonStyle buttonStyle;

    switch (type) {
      case ResbiteBtnType.secondary:
        buttonStyle = OutlinedButton.styleFrom(
          foregroundColor: txtColor,
          side: BorderSide(
            color: borderColor ?? AppTheme.primaryColor,
            width: 1.5,
          ),
          padding:
              padding ??
              EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
        break;
      case ResbiteBtnType.text:
        buttonStyle = TextButton.styleFrom(
          foregroundColor: txtColor,
          padding:
              padding ??
              EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
        break;
      case ResbiteBtnType.gradient:
        // This case is handled separately above
        buttonStyle = ElevatedButton.styleFrom();
        break;
      case ResbiteBtnType.primary:
        buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: txtColor,
          elevation: 2,
          shadowColor: shadowColor,
          padding:
              padding ??
              EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
        break;
    }

    // Determine which button widget to use
    Widget button;

    switch (type) {
      case ResbiteBtnType.secondary:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonContent,
        );
        break;
      case ResbiteBtnType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonContent,
        );
        break;
      case ResbiteBtnType.gradient:
        // This case is handled separately above
        button = const SizedBox();
        break;
      case ResbiteBtnType.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonContent,
        );
        break;
    }

    // Apply full width if needed
    if (fullWidth && type != ResbiteBtnType.gradient) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
