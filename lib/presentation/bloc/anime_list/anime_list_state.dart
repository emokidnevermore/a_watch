import 'package:a_watch/features/anime/domain/entities/anime.dart';
import 'package:a_watch/domain/entities/page_result.dart';
import 'package:equatable/equatable.dart';

abstract class AnimeListState extends Equatable {
  const AnimeListState();

  @override
  List<Object> get props => [];
}

class AnimeListInitial extends AnimeListState {}

class AnimeListLoading extends AnimeListState {}

class AnimeListLoaded extends AnimeListState {
  final PageResult<Anime> pageResult;
  final bool isLoadingMore;
  final bool isRefreshing;

  const AnimeListLoaded({
    required this.pageResult,
    this.isLoadingMore = false,
    this.isRefreshing = false,
  });

  @override
  List<Object> get props => [pageResult, isLoadingMore, isRefreshing];
}

class AnimeListError extends AnimeListState {
  final String message;

  const AnimeListError(this.message);

  @override
  List<Object> get props => [message];
}
