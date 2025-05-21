import 'package:flutter/material.dart';

class ContentSheetFrame extends StatelessWidget {
  final Widget child;
  final String? title;
  final VoidCallback? onClose;
  final EdgeInsetsGeometry padding;

  const ContentSheetFrame({
    Key? key,
    required this.child,
    this.title,
    this.onClose,
    this.padding = const EdgeInsets.all(16.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (title != null || onClose != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (onClose != null)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onClose,
                    ),
                  // If only title is present and no close button, add a spacer to center title
                  if (title != null && onClose == null)
                    const SizedBox(width: 48), // Width of an IconButton
                ],
              ),
            if (title != null || onClose != null) const SizedBox(height: 16.0),
            Flexible(child: child), // Use Flexible for content that might overflow
          ],
        ),
      ),
    );
  }
}
