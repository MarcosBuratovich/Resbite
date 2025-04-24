import 'package:flutter/material.dart';
import 'package:resbite_app/components/ui.dart';
import 'package:resbite_app/styles/tailwind_theme.dart';

/// A reusable card layout component using the shadcn-inspired design system.
/// This layout is designed for screens that display content in a card format.
class CardLayout extends StatelessWidget {
  /// The title to display at the top of the layout
  final String title;
  
  /// Optional subtitle to display below the title
  final String? subtitle;
  
  /// Optional icon to display next to the title
  final IconData? titleIcon;
  
  /// The main content of the layout
  final Widget content;
  
  /// Optional action buttons to display at the bottom of the layout
  final List<Widget>? actions;
  
  /// Optional widget to display at the top of the layout, before the title
  final Widget? header;
  
  /// Optional widget to display at the bottom of the layout, after the content
  final Widget? footer;
  
  /// Whether to add padding around the entire layout
  final bool hasPadding;
  
  /// Whether to allow scrolling of the content
  final bool isScrollable;
  
  const CardLayout({
    super.key,
    required this.title,
    this.subtitle,
    this.titleIcon,
    required this.content,
    this.actions,
    this.header,
    this.footer,
    this.hasPadding = true,
    this.isScrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget mainContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header widget if provided
        if (header != null) ...[
          header!,
          const SizedBox(height: 16),
        ],
        
        // Title section
        Row(
          children: [
            if (titleIcon != null) ...[
              Icon(
                titleIcon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TwTypography.heading4(context).copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TwTypography.bodySm(context).copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Main content
        content,
        
        // Action buttons
        if (actions != null && actions!.isNotEmpty) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions!.map((action) => 
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: action,
              )
            ).toList(),
          ),
        ],
        
        // Footer widget if provided
        if (footer != null) ...[
          const SizedBox(height: 24),
          footer!,
        ],
      ],
    );
    
    // Apply padding if needed
    if (hasPadding) {
      mainContent = Padding(
        padding: const EdgeInsets.all(24.0),
        child: mainContent,
      );
    }
    
    // Make content scrollable if needed
    if (isScrollable) {
      mainContent = SingleChildScrollView(
        child: mainContent,
      );
    }
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          title,
          style: TwTypography.heading6(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ShadCard.elevated(
            padding: EdgeInsets.zero,
            child: mainContent,
          ),
        ),
      ),
    );
  }
}

// Removed the ShadCardExtension since it's not needed anymore