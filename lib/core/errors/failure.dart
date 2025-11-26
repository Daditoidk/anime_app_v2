import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.network({String? message}) = NetworkFailure;
  const factory Failure.server({String? message, int? statusCode}) =
      ServerFailure;
  const factory Failure.notFound({String? message}) = NotFoundFailure;
  const factory Failure.unexpected({String? message}) = UnexpectedFailure;
}

extension FailureMessage on Failure {
  String get displayMessage {
    return switch (this) {
      NetworkFailure(:final message) => message ?? 'No internet connection',
      ServerFailure(:final message) =>
        message ?? 'Server error, please try again',
      NotFoundFailure(:final message) => message ?? 'Content not found',
      UnexpectedFailure(:final message) => message ?? 'Something went wrong',
    };
  }
}
