import 'package:flutter/material.dart';

/// Avatar sizes
enum AvatarSize { xs, sm, md, lg, xl }

/// A shadcn-inspired avatar component.
class ShadAvatar extends StatelessWidget {
  /// Image URL to display (optional)
  final String? imageUrl;

  /// Widget to display if imageUrl is null or image fails to load
  final Widget? fallback;

  /// Initials to display if no image and no fallback provided
  final String? initials;

  /// Size variant of the avatar
  final AvatarSize size;

  /// Whether to show a border around the avatar
  final bool hasBorder;

  /// Border color (if hasBorder is true)
  final Color? borderColor;

  /// Border width (if hasBorder is true)
  final double borderWidth;

  /// Background color when displaying initials
  final Color? backgroundColor;

  /// Text color when displaying initials
  final Color? textColor;

  /// Optional status indicator color (shows a small dot)
  final Color? statusColor;

  /// Optional callback when avatar is tapped
  final VoidCallback? onTap;

  const ShadAvatar({
    super.key,
    this.imageUrl,
    this.fallback,
    this.initials,
    this.size = AvatarSize.md,
    this.hasBorder = false,
    this.borderColor,
    this.borderWidth = 2.0,
    this.backgroundColor,
    this.textColor,
    this.statusColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Determine avatar dimensions based on size
    double dimension;
    double fontSize;
    double statusDotSize;

    switch (size) {
      case AvatarSize.xs:
        dimension = 24;
        fontSize = 10;
        statusDotSize = 6;
        break;
      case AvatarSize.sm:
        dimension = 32;
        fontSize = 14;
        statusDotSize = 8;
        break;
      case AvatarSize.lg:
        dimension = 56;
        fontSize = 24;
        statusDotSize = 12;
        break;
      case AvatarSize.xl:
        dimension = 72;
        fontSize = 32;
        statusDotSize = 14;
        break;
      case AvatarSize.md:
        dimension = 40;
        fontSize = 18;
        statusDotSize = 10;
        break;
    }

    // Configure colors
    final actualBorderColor = borderColor ?? colorScheme.primary;
    final actualBackgroundColor =
        backgroundColor ?? colorScheme.surfaceContainerHighest;
    final actualTextColor = textColor ?? colorScheme.onSurfaceVariant;

    // Build the avatar content (image, fallback, or initials)
    Widget avatarContent;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // Use image if provided
      avatarContent = ClipRRect(
        borderRadius: BorderRadius.circular(dimension / 2),
        child: Image.network(
          imageUrl!,
          width: dimension,
          height: dimension,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Show fallback or initials on error
            return _buildFallbackContent(
              dimension,
              fontSize,
              actualBackgroundColor,
              actualTextColor,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: dimension,
              height: dimension,
              color: actualBackgroundColor,
              child: Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                  strokeWidth: 2,
                ),
              ),
            );
          },
        ),
      );
    } else {
      // Use fallback or initials
      avatarContent = _buildFallbackContent(
        dimension,
        fontSize,
        actualBackgroundColor,
        actualTextColor,
      );
    }

    // Apply border if needed
    if (hasBorder) {
      avatarContent = Container(
        width: dimension,
        height: dimension,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: actualBorderColor, width: borderWidth),
        ),
        child: ClipOval(child: avatarContent),
      );
    }

    // Add status indicator if needed
    if (statusColor != null) {
      avatarContent = Stack(
        children: [
          avatarContent,
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: statusDotSize,
              height: statusDotSize,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.surface,
                  width: borderWidth / 2,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Add tap functionality if needed
    if (onTap != null) {
      avatarContent = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(dimension / 2),
        child: avatarContent,
      );
    }

    return avatarContent;
  }

  // Helper method to build fallback content
  Widget _buildFallbackContent(
    double dimension,
    double fontSize,
    Color backgroundColor,
    Color textColor,
  ) {
    if (fallback != null) {
      return Container(
        width: dimension,
        height: dimension,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(child: fallback),
      );
    } else if (initials != null && initials!.isNotEmpty) {
      return Container(
        width: dimension,
        height: dimension,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            _formatInitials(initials!),
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    } else {
      // Default icon fallback
      return Container(
        width: dimension,
        height: dimension,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.person, size: dimension * 0.6, color: textColor),
      );
    }
  }

  // Format initials: take first 2 characters or first characters of first/last words
  String _formatInitials(String input) {
    if (input.length <= 2) return input.toUpperCase();

    final words = input.trim().split(' ');
    if (words.length == 1) return words[0].substring(0, 2).toUpperCase();

    return (words.first.isNotEmpty ? words.first[0] : '') +
        (words.last.isNotEmpty ? words.last[0] : '');
  }

  // Factory constructors for different avatar sizes

  /// Extra small avatar (24x24)
  factory ShadAvatar.xs({
    Key? key,
    String? imageUrl,
    Widget? fallback,
    String? initials,
    bool hasBorder = false,
    Color? borderColor,
    double borderWidth = 2.0,
    Color? backgroundColor,
    Color? textColor,
    Color? statusColor,
    VoidCallback? onTap,
  }) {
    return ShadAvatar(
      key: key,
      imageUrl: imageUrl,
      fallback: fallback,
      initials: initials,
      size: AvatarSize.xs,
      hasBorder: hasBorder,
      borderColor: borderColor,
      borderWidth: borderWidth,
      backgroundColor: backgroundColor,
      textColor: textColor,
      statusColor: statusColor,
      onTap: onTap,
    );
  }

  /// Small avatar (32x32)
  factory ShadAvatar.sm({
    Key? key,
    String? imageUrl,
    Widget? fallback,
    String? initials,
    bool hasBorder = false,
    Color? borderColor,
    double borderWidth = 2.0,
    Color? backgroundColor,
    Color? textColor,
    Color? statusColor,
    VoidCallback? onTap,
  }) {
    return ShadAvatar(
      key: key,
      imageUrl: imageUrl,
      fallback: fallback,
      initials: initials,
      size: AvatarSize.sm,
      hasBorder: hasBorder,
      borderColor: borderColor,
      borderWidth: borderWidth,
      backgroundColor: backgroundColor,
      textColor: textColor,
      statusColor: statusColor,
      onTap: onTap,
    );
  }

  /// Large avatar (56x56)
  factory ShadAvatar.lg({
    Key? key,
    String? imageUrl,
    Widget? fallback,
    String? initials,
    bool hasBorder = false,
    Color? borderColor,
    double borderWidth = 2.0,
    Color? backgroundColor,
    Color? textColor,
    Color? statusColor,
    VoidCallback? onTap,
  }) {
    return ShadAvatar(
      key: key,
      imageUrl: imageUrl,
      fallback: fallback,
      initials: initials,
      size: AvatarSize.lg,
      hasBorder: hasBorder,
      borderColor: borderColor,
      borderWidth: borderWidth,
      backgroundColor: backgroundColor,
      textColor: textColor,
      statusColor: statusColor,
      onTap: onTap,
    );
  }

  /// Extra large avatar (72x72)
  factory ShadAvatar.xl({
    Key? key,
    String? imageUrl,
    Widget? fallback,
    String? initials,
    bool hasBorder = false,
    Color? borderColor,
    double borderWidth = 2.0,
    Color? backgroundColor,
    Color? textColor,
    Color? statusColor,
    VoidCallback? onTap,
  }) {
    return ShadAvatar(
      key: key,
      imageUrl: imageUrl,
      fallback: fallback,
      initials: initials,
      size: AvatarSize.xl,
      hasBorder: hasBorder,
      borderColor: borderColor,
      borderWidth: borderWidth,
      backgroundColor: backgroundColor,
      textColor: textColor,
      statusColor: statusColor,
      onTap: onTap,
    );
  }
}
