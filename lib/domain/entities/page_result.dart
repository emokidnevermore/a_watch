import 'package:equatable/equatable.dart';

class PageResult<T> extends Equatable {
  final List<T> items;
  final int page;
  final String? nextPageUrl;
  final String? prevPageUrl;

  const PageResult({
    required this.items,
    required this.page,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  @override
  List<Object?> get props => [
        items,
        page,
        nextPageUrl,
        prevPageUrl,
      ];

  PageResult<T> copyWith({
    List<T>? items,
    int? page,
    String? nextPageUrl,
    String? prevPageUrl,
  }) {
    return PageResult<T>(
      items: items ?? this.items,
      page: page ?? this.page,
      nextPageUrl: nextPageUrl ?? this.nextPageUrl,
      prevPageUrl: prevPageUrl ?? this.prevPageUrl,
    );
  }
}
