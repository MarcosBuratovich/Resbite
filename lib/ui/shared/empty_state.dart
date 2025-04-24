import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../config/theme.dart';
import '../components/resbite_button.dart';

enum EmptyStateType {
  noData,
  noResults,
  error,
  noNetwork,
  noPermission,
  maintenance,
  empty,
}

class EmptyState extends StatelessWidget {
  final EmptyStateType type;
  final String? title;
  final String? message;
  final VoidCallback? onActionPressed;
  final String? actionLabel;
  final IconData? customIcon;
  final String? animationAsset;
  final double? iconSize;
  final Color? iconColor;

  const EmptyState({
    super.key,
    this.type = EmptyStateType.noData,
    this.title,
    this.message,
    this.onActionPressed,
    this.actionLabel,
    this.customIcon,
    this.animationAsset,
    this.iconSize,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTitle = _getDefaultTitle();
    final defaultMessage = _getDefaultMessage();
    final defaultIcon = _getDefaultIcon();
    final defaultAnimation = _getDefaultAnimation();
    final defaultColor = _getDefaultColor(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (animationAsset != null || defaultAnimation != null)
              SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset(
                  animationAsset ?? defaultAnimation!,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildIcon(context, defaultIcon, defaultColor);
                  },
                ),
              )
            else
              _buildIcon(context, defaultIcon, defaultColor),
            
            const SizedBox(height: 24),
            
            Text(
              title ?? defaultTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: iconColor ?? defaultColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            Text(
              message ?? defaultMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            if (onActionPressed != null) ...[
              const SizedBox(height: 24),
              ResbiteButton(
                text: actionLabel ?? 'Try Again',
                icon: type == EmptyStateType.error || type == EmptyStateType.noNetwork
                    ? Icons.refresh
                    : Icons.arrow_forward,
                type: ResbiteBtnType.primary,
                backgroundColor: iconColor ?? defaultColor,
                onPressed: onActionPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildIcon(BuildContext context, IconData icon, Color color) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(
        customIcon ?? icon,
        size: iconSize ?? 64,
        color: iconColor ?? color,
      ),
    );
  }
  
  String _getDefaultTitle() {
    switch (type) {
      case EmptyStateType.noData:
        return 'No Data Available';
      case EmptyStateType.noResults:
        return 'No Results Found';
      case EmptyStateType.error:
        return 'Something Went Wrong';
      case EmptyStateType.noNetwork:
        return 'No Internet Connection';
      case EmptyStateType.noPermission:
        return 'Permission Required';
      case EmptyStateType.maintenance:
        return 'Under Maintenance';
      case EmptyStateType.empty:
        return 'Nothing Here Yet';
    }
  }
  
  String _getDefaultMessage() {
    switch (type) {
      case EmptyStateType.noData:
        return 'We couldn\'t find any data to display at this moment.';
      case EmptyStateType.noResults:
        return 'Try adjusting your search or filters to find what you\'re looking for.';
      case EmptyStateType.error:
        return 'We encountered an unexpected error. Please try again later.';
      case EmptyStateType.noNetwork:
        return 'Please check your internet connection and try again.';
      case EmptyStateType.noPermission:
        return 'We need your permission to access this feature.';
      case EmptyStateType.maintenance:
        return 'We\'re currently improving this feature. Please check back soon.';
      case EmptyStateType.empty:
        return 'Be the first to add something here!';
    }
  }
  
  IconData _getDefaultIcon() {
    switch (type) {
      case EmptyStateType.noData:
        return Icons.inventory_2_outlined;
      case EmptyStateType.noResults:
        return Icons.search_off_outlined;
      case EmptyStateType.error:
        return Icons.error_outline;
      case EmptyStateType.noNetwork:
        return Icons.wifi_off_outlined;
      case EmptyStateType.noPermission:
        return Icons.no_encryption_outlined;
      case EmptyStateType.maintenance:
        return Icons.build_outlined;
      case EmptyStateType.empty:
        return Icons.hourglass_empty;
    }
  }
  
  String? _getDefaultAnimation() {
    switch (type) {
      case EmptyStateType.noData:
        return 'assets/animations/empty_box.json';
      case EmptyStateType.noResults:
        return 'assets/animations/no_results.json';
      case EmptyStateType.error:
        return 'assets/animations/error.json';
      case EmptyStateType.noNetwork:
        return 'assets/animations/no_connection.json';
      case EmptyStateType.noPermission:
        return 'assets/animations/locked.json';
      case EmptyStateType.maintenance:
        return 'assets/animations/maintenance.json';
      case EmptyStateType.empty:
        return 'assets/animations/empty.json';
    }
  }
  
  Color _getDefaultColor(BuildContext context) {
    switch (type) {
      case EmptyStateType.noData:
      case EmptyStateType.empty:
        return AppTheme.primaryColor;
      case EmptyStateType.noResults:
        return AppTheme.secondaryColor;
      case EmptyStateType.error:
        return Theme.of(context).colorScheme.error;
      case EmptyStateType.noNetwork:
        return AppTheme.infoColor;
      case EmptyStateType.noPermission:
        return AppTheme.accentColor;
      case EmptyStateType.maintenance:
        return AppTheme.warningColor;
    }
  }
}