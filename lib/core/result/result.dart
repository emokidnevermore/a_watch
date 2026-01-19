sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final dynamic error;

  const Failure(this.message, [this.error]);
}

extension ResultExtension<T> on Result<T> {
  T? get data {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    }
    return null;
  }

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  String? get errorMessage {
    if (this is Failure<T>) {
      return (this as Failure<T>).message;
    }
    return null;
  }

  dynamic get error => this is Failure<T> ? (this as Failure<T>).error : null;

  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(String message, dynamic error) onFailure,
  }) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).data);
    } else {
      final failure = this as Failure<T>;
      return onFailure(failure.message, failure.error);
    }
  }

  R maybeWhen<R>({
    required R Function() orElse,
    R Function(T data)? onSuccess,
    R Function(String message, dynamic error)? onFailure,
  }) {
    if (this is Success<T>) {
      return onSuccess != null ? onSuccess((this as Success<T>).data) : orElse();
    } else {
      final failure = this as Failure<T>;
      return onFailure != null 
          ? onFailure(failure.message, failure.error) 
          : orElse();
    }
  }
}
