part of 'result_set_viewer_bloc.dart';

enum ResultSetViewerStatus {
  initial,
  loading,
  success,
  failure,
  saving,
  rejecting,
  script;

  bool get isProceeding => const [loading, saving, rejecting].contains(this);
}

class ResultSetViewerState extends Equatable {
  const ResultSetViewerState({
    this.status = ResultSetViewerStatus.initial,
    this.changedCount = 0,
    this.message,
  });

  final ResultSetViewerStatus status;
  final String? message;
  final int changedCount;

  ResultSetViewerState copyWith(
      {ResultSetViewerStatus? status, int? changedCount, String? message}) {
    return ResultSetViewerState(
      status: status ?? this.status,
      changedCount: changedCount ?? this.changedCount,
      message: message ?? this.message,
    );
  }

  @override
  List<dynamic> get props => [status, message, changedCount];
}
