import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../config/theme.dart';

enum LoadingStateType {
  circular,
  linear,
  skeleton,
  shimmer,
  pulsating,
}

class LoadingState extends StatelessWidget {
  final LoadingStateType type;
  final String? message;
  final Color? color;
  final double? size;
  final EdgeInsetsGeometry? padding;
  final Widget? child; // For skeleton/shimmer loading

  const LoadingState({
    super.key,
    this.type = LoadingStateType.circular,
    this.message,
    this.color,
    this.size,
    this.padding,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final loadingColor = color ?? AppTheme.primaryColor;
    
    Widget loadingIndicator;
    switch (type) {
      case LoadingStateType.circular:
        loadingIndicator = SizedBox(
          width: size ?? 40,
          height: size ?? 40,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
            strokeWidth: 3,
          ),
        );
        break;
      
      case LoadingStateType.linear:
        loadingIndicator = SizedBox(
          width: size ?? 200,
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
            backgroundColor: loadingColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
        );
        break;
      
      case LoadingStateType.skeleton:
        loadingIndicator = _buildSkeleton(context, loadingColor);
        break;
      
      case LoadingStateType.shimmer:
        loadingIndicator = _buildShimmer(context, loadingColor);
        break;
      
      case LoadingStateType.pulsating:
        loadingIndicator = _buildPulsating(context, loadingColor);
        break;
    }
    
    // If message is provided, show it with the loading indicator
    if (message != null) {
      return Center(
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              loadingIndicator,
              const SizedBox(height: 16),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: loadingColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    // Just show the loading indicator
    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: loadingIndicator,
      ),
    );
  }
  
  Widget _buildSkeleton(BuildContext context, Color color) {
    if (child != null) {
      return Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      );
    }
    
    // Default skeleton layout
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(3, (index) {
        return Container(
          width: double.infinity,
          height: 16,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
  
  Widget _buildShimmer(BuildContext context, Color color) {
    return Shimmer.fromColors(
      baseColor: color.withOpacity(0.05),
      highlightColor: color.withOpacity(0.25),
      period: const Duration(milliseconds: 1500),
      child: child ?? _buildSkeleton(context, color),
    );
  }
  
  Widget _buildPulsating(BuildContext context, Color color) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + (value * 0.2),
            child: child,
          ),
        );
      },
      child: child ?? Container(
        width: size ?? 80,
        height: size ?? 80,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.hourglass_top,
          color: color,
          size: (size ?? 80) * 0.5,
        ),
      ),
    );
  }
  
  static Widget listItemSkeleton({
    double height = 80,
    double? width,
    bool showAvatar = true,
    int lines = 2,
    Color? color,
    BorderRadius? borderRadius,
  }) {
    return LoadingState(
      type: LoadingStateType.shimmer,
      color: color,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (showAvatar) ...[
              Container(
                width: height - 32,
                height: height - 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  lines,
                  (index) => Container(
                    width: index == 0 ? double.infinity : (index * 30 + 100),
                    height: 12,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  static Widget gridItemSkeleton({
    double? height,
    double? width,
    Color? color,
    BorderRadius? borderRadius,
  }) {
    return LoadingState(
      type: LoadingStateType.shimmer,
      color: color,
      child: Container(
        width: width ?? 160,
        height: height ?? 180,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: width ?? 160,
              height: (height ?? 180) * 0.6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: (borderRadius ?? BorderRadius.circular(12)).topLeft,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: (width ?? 160) * 0.8,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: (width ?? 160) * 0.5,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}