import 'package:flutter/material.dart';

class KeyboardAvoider extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool autoScroll;

  const KeyboardAvoider({
    Key? key,
    required this.child,
    this.padding,
    this.controller,
    this.autoScroll = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: controller,
          // reverse: true, // Consider if content should scroll from bottom
          padding: (padding ?? EdgeInsets.zero).add(
            EdgeInsets.only(bottom: autoScroll ? bottomPadding : 0),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - (autoScroll ? bottomPadding : 0),
            ),
            child: child,
          ),
        );
      },
    );
  }
}
