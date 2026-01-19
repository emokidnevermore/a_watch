import 'package:equatable/equatable.dart';
import 'package:a_watch/features/top100/domain/entities/top100_page_data.dart';

abstract class Top100State extends Equatable {
  const Top100State();

  @override
  List<Object> get props => [];
}

class Top100Initial extends Top100State {}

class Top100Loading extends Top100State {}

class Top100Loaded extends Top100State {
  final Top100PageData data;

  const Top100Loaded(this.data);

  @override
  List<Object> get props => [data];
}

class Top100Error extends Top100State {
  final String message;

  const Top100Error(this.message);

  @override
  List<Object> get props => [message];
}
