import 'package:equatable/equatable.dart';
import 'package:a_watch/features/top100/domain/entities/top100_page_data.dart';

abstract class Top100Event extends Equatable {
  const Top100Event();

  @override
  List<Object> get props => [];
}

class Top100Load extends Top100Event {
  final Top100Filter filter;

  const Top100Load({
    this.filter = Top100Filter.all,
  });

  @override
  List<Object> get props => [filter];
}

class Top100ChangeFilter extends Top100Event {
  final Top100Filter filter;

  const Top100ChangeFilter(this.filter);

  @override
  List<Object> get props => [filter];
}

class Top100Refresh extends Top100Event {
  final Top100Filter filter;

  const Top100Refresh(this.filter);

  @override
  List<Object> get props => [filter];
}
