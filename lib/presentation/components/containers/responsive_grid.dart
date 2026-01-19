import 'package:flutter/material.dart';
import 'package:a_watch/core/theme/design_tokens.dart';

/// Responsive grid container for lists and collections
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final double? childAspectRatio;
  final EdgeInsetsGeometry? padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.childAspectRatio,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = DesignTokens.getGridColumns(width);
    final aspectRatio = childAspectRatio ?? _getAspectRatio(width);

    return GridView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: crossAxisSpacing ?? 12,
        mainAxisSpacing: mainAxisSpacing ?? 12,
      ),
      itemCount: children.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return children[index];
      },
    );
  }

  double _getAspectRatio(double width) {
    if (width >= DesignTokens.desktopMinWidth) {
      return 2 / 3.0; // Для десктопа - менее вытянутые карточки
    } else if (width >= DesignTokens.tabletMinWidth) {
      return 2 / 3.0; // Для планшета - средние карточки
    } else {
      return 2 / 3.0; // Для мобильных - более вытянутые карточки
    }
  }
}

/// Responsive horizontal list with custom item width
class ResponsiveHorizontalList extends StatelessWidget {
  final List<Widget> children;
  final double? itemWidth;
  final double? spacing;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  const ResponsiveHorizontalList({
    super.key,
    required this.children,
    this.itemWidth,
    this.spacing,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final defaultItemWidth = itemWidth ?? _getItemWidth(width);

    return SizedBox(
      height: _getListHeight(width),
      child: ListView.builder(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: children.length,
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(
              right: index == children.length - 1 ? 0 : spacing ?? 12,
            ),
            width: defaultItemWidth,
            child: children[index],
          );
        },
      ),
    );
  }

  double _getItemWidth(double width) {
    if (width >= DesignTokens.desktopMinWidth) {
      return 200.0; // Для десктопа - широкие карточки
    } else if (width >= DesignTokens.tabletMinWidth) {
      return 180.0; // Для планшета - средние карточки
    } else {
      return 140.0; // Для мобильных - узкие карточки
    }
  }

  double _getListHeight(double width) {
    if (width >= DesignTokens.desktopMinWidth) {
      return 280.0; // Для десктопа - высокие карточки
    } else if (width >= DesignTokens.tabletMinWidth) {
      return 240.0; // Для планшета - средние карточки
    } else {
      return 200.0; // Для мобильных - низкие карточки
    }
  }
}

/// Section wrapper with title and optional action button
class SectionWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onAction;
  final String? actionText;
  final EdgeInsetsGeometry? padding;
  final TextAlign? titleAlign;

  const SectionWrapper({
    super.key,
    required this.title,
    required this.child,
    this.onAction,
    this.actionText,
    this.padding,
    this.titleAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with optional action
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: titleAlign,
                ),
              ),
              if (onAction != null && actionText != null)
                TextButton(
                  onPressed: onAction,
                  child: Text(actionText!),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Content
          child,
        ],
      ),
    );
  }
}

/// Loading state widget
class LoadingState extends StatelessWidget {
  final String? message;
  final double? size;

  const LoadingState({
    super.key,
    this.message,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
            strokeWidth: 2,
          ),
          if (message != null)
            const SizedBox(height: 16),
          if (message != null)
            Text(
              message!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}

/// Error state widget
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null)
            const SizedBox(height: 16),
          if (onRetry != null)
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Повторить'),
            ),
        ],
      ),
    );
  }
}

/// Empty state widget
class EmptyState extends StatelessWidget {
  final String message;
  final String? submessage;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyState({
    super.key,
    required this.message,
    this.submessage,
    this.icon,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 48,
              color: Colors.grey,
            ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          if (submessage != null)
            const SizedBox(height: 8),
          if (submessage != null)
            Text(
              submessage!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          if (onAction != null && actionText != null)
            const SizedBox(height: 16),
          if (onAction != null && actionText != null)
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionText!),
            ),
        ],
      ),
    );
  }
}
