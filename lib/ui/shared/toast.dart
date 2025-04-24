import 'package:flutter/material.dart';

import '../../config/theme.dart';

enum ToastType {
  success,
  error,
  warning,
  info,
}

class Toast {
  static void show({
    required BuildContext context,
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
    bool dismissible = true,
    Widget? leading,
    bool showAtTop = false,
  }) {
    // Determine colors and icons based on type
    final Color backgroundColor;
    final IconData icon;
    
    switch (type) {
      case ToastType.success:
        backgroundColor = AppTheme.successColor;
        icon = Icons.check_circle;
        break;
      case ToastType.error:
        backgroundColor = AppTheme.errorColor;
        icon = Icons.error;
        break;
      case ToastType.warning:
        backgroundColor = AppTheme.warningColor;
        icon = Icons.warning;
        break;
      case ToastType.info:
      default:
        backgroundColor = AppTheme.infoColor;
        icon = Icons.info;
        break;
    }
    
    // Create the snackbar widget
    final SnackBar snackBar = SnackBar(
      content: Row(
        children: [
          // Leading icon or widget
          leading ?? Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          
          // Message text
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      dismissDirection: DismissDirection.horizontal,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: showAtTop ? MediaQuery.of(context).size.height - 100 : 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      action: onAction != null || !dismissible
          ? SnackBarAction(
              label: actionLabel ?? 'Dismiss',
              textColor: Colors.white,
              onPressed: onAction ?? () {},
            )
          : null,
    );
    
    // Dismiss any existing snackbars and show the new one
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
  
  static void showSuccess(BuildContext context, String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context: context,
      message: message,
      type: ToastType.success,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }
  
  static void showError(BuildContext context, String message, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context: context,
      message: message,
      type: ToastType.error,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }
  
  static void showWarning(BuildContext context, String message, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context: context,
      message: message,
      type: ToastType.warning,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }
  
  static void showInfo(BuildContext context, String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context: context,
      message: message,
      type: ToastType.info,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }
}