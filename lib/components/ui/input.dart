import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resbite_app/styles/tailwind_theme.dart';

/// A shadcn-inspired input component with various configurations.
class ShadInput extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final GestureTapCallback? onTap;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final bool autocorrect;
  final bool autofocus;
  final bool filled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;

  const ShadInput({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.autocorrect = true,
    this.autofocus = false,
    this.filled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderRadius,
    this.contentPadding,
    this.inputFormatters,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(8);
    final defaultContentPadding =
        contentPadding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    final actualBackgroundColor =
        backgroundColor ??
        (filled
            ? colorScheme.surfaceContainerHighest.withOpacity(0.5)
            : Colors.transparent);
    final actualTextColor = textColor ?? colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label text if provided
        if (labelText != null) ...[
          Text(
            labelText!,
            style: TwTypography.labelSm(context).copyWith(
              fontWeight: FontWeight.w500,
              color:
                  enabled
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 6),
        ],

        // Text field
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          readOnly: readOnly,
          enabled: enabled,
          autocorrect: autocorrect,
          autofocus: autofocus,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          maxLengthEnforcement:
              maxLength != null
                  ? MaxLengthEnforcement.enforced
                  : MaxLengthEnforcement.none,
          style: TwTypography.body(context).copyWith(color: actualTextColor),
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            errorText: errorText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: filled,
            fillColor: actualBackgroundColor,
            contentPadding: defaultContentPadding,
            border: OutlineInputBorder(
              borderRadius: defaultBorderRadius,
              borderSide: BorderSide(
                color: borderColor ?? colorScheme.outline,
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: defaultBorderRadius,
              borderSide: BorderSide(
                color: borderColor ?? colorScheme.outline,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: defaultBorderRadius,
              borderSide: BorderSide(
                color: borderColor ?? colorScheme.primary,
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: defaultBorderRadius,
              borderSide: BorderSide(color: colorScheme.error, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: defaultBorderRadius,
              borderSide: BorderSide(color: colorScheme.error, width: 2.0),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: defaultBorderRadius,
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.5),
                width: 1.0,
              ),
            ),
            errorStyle: TwTypography.bodyXs(
              context,
            ).copyWith(color: colorScheme.error),
            helperStyle: TwTypography.bodyXs(
              context,
            ).copyWith(color: colorScheme.onSurfaceVariant),
            hintStyle: TwTypography.body(
              context,
            ).copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
          ),
          validator: validator,
          autovalidateMode: autovalidateMode,
          inputFormatters: inputFormatters,
        ),
      ],
    );
  }

  // Factory constructors for different input variants

  /// Default text input
  static Widget text({
    Key? key,
    String? labelText,
    String? hintText,
    String? helperText,
    String? errorText,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    GestureTapCallback? onTap,
    TextInputAction textInputAction = TextInputAction.next,
    bool readOnly = false,
    bool enabled = true,
    bool autofocus = false,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return ShadInput(
      key: key,
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      textInputAction: textInputAction,
      readOnly: readOnly,
      enabled: enabled,
      autofocus: autofocus,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      validator: validator,
    );
  }

  /// Email input with email keyboard type
  static Widget email({
    Key? key,
    String? labelText,
    String? hintText = 'Email address',
    String? helperText,
    String? errorText,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    TextInputAction textInputAction = TextInputAction.next,
    bool readOnly = false,
    bool enabled = true,
    bool autofocus = false,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return ShadInput(
      key: key,
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      readOnly: readOnly,
      enabled: enabled,
      autofocus: autofocus,
      prefixIcon: prefixIcon ?? const Icon(Icons.email_outlined),
      suffixIcon: suffixIcon,
      validator: validator,
    );
  }

  /// Password input with obscured text
  static Widget password({
    Key? key,
    String? labelText,
    String? hintText = 'Password',
    String? helperText,
    String? errorText,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    TextInputAction textInputAction = TextInputAction.done,
    bool readOnly = false,
    bool enabled = true,
    bool autofocus = false,
    bool showToggle = true,
    String? Function(String?)? validator,
  }) {
    return _PasswordInput(
      key: key,
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      readOnly: readOnly,
      enabled: enabled,
      autofocus: autofocus,
      showToggle: showToggle,
      validator: validator,
    );
  }

  /// Multiline text input
  static Widget multiline({
    Key? key,
    String? labelText,
    String? hintText,
    String? helperText,
    String? errorText,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    GestureTapCallback? onTap,
    bool readOnly = false,
    bool enabled = true,
    bool autofocus = false,
    int? maxLines = 5,
    int? minLines = 3,
    int? maxLength,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return ShadInput(
      key: key,
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      readOnly: readOnly,
      enabled: enabled,
      autofocus: autofocus,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      validator: validator,
    );
  }

  /// Number input with numeric keyboard
  static Widget number({
    Key? key,
    String? labelText,
    String? hintText,
    String? helperText,
    String? errorText,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    GestureTapCallback? onTap,
    TextInputAction textInputAction = TextInputAction.next,
    bool readOnly = false,
    bool enabled = true,
    bool autofocus = false,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return ShadInput(
      key: key,
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: textInputAction,
      readOnly: readOnly,
      enabled: enabled,
      autofocus: autofocus,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      validator: validator,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
    );
  }
}

/// Private stateful widget for password input with visibility toggle
class _PasswordInput extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final bool showToggle;
  final String? Function(String?)? validator;

  const _PasswordInput({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction = TextInputAction.done,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.showToggle = true,
    this.validator,
  });

  @override
  State<_PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<_PasswordInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return ShadInput(
      labelText: widget.labelText,
      hintText: widget.hintText,
      helperText: widget.helperText,
      errorText: widget.errorText,
      controller: widget.controller,
      focusNode: widget.focusNode,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      obscureText: _obscureText,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon:
          widget.showToggle
              ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
              : null,
      validator: widget.validator,
    );
  }
}
