import 'package:flutter/material.dart';
import 'package:a_watch/domain/entities/series_filters.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final SeriesFilters? filters;
  final Function(int, SeriesFilters?) onPageChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.filters,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox();

    final pages = _generatePageNumbers();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          IconButton(
            onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1, filters) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          // Page buttons
          ...pages.map((page) {
            if (page == -1) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('...'),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                onPressed: page == currentPage ? null : () => onPageChanged(page, filters),
                style: ElevatedButton.styleFrom(
                  backgroundColor: page == currentPage ? Theme.of(context).primaryColor : Colors.grey[800],
                  foregroundColor: _getForegroundColor(context, page == currentPage),
                  disabledBackgroundColor: Theme.of(context).primaryColor,
                  disabledForegroundColor: _getForegroundColor(context, true),
                ),
                child: Text('$page'),
              ),
            );
          }),
          // Next button
          IconButton(
            onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1, filters) : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  List<int> _generatePageNumbers() {
    const maxVisiblePages = 5;
    final pages = <int>[];

    if (totalPages <= maxVisiblePages) {
      for (int i = 1; i <= totalPages; i++) {
        pages.add(i);
      }
    } else {
      pages.add(1);

      if (currentPage > 3) {
        pages.add(-1); // Ellipsis
      }

      final start = (currentPage - 1).clamp(2, totalPages - 3);
      final end = (currentPage + 1).clamp(3, totalPages - 1);

      for (int i = start; i <= end; i++) {
        pages.add(i);
      }

      if (currentPage < totalPages - 2) {
        pages.add(-1); // Ellipsis
      }

      if (totalPages > 1) {
        pages.add(totalPages);
      }
    }

    return pages;
  }

  Color _getForegroundColor(BuildContext context, bool isSelected) {
    if (!isSelected) return Colors.white;

    final primaryColor = Theme.of(context).primaryColor;

    // Check if primary color is light (close to white)
    // If lightness is > 0.7, consider it light and use black text
    final hsl = HSLColor.fromColor(primaryColor);
    return hsl.lightness > 0.7 ? Colors.black : Colors.white;
  }
}
