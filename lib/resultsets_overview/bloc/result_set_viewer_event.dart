part of 'result_set_viewer_bloc.dart';

abstract class ResultSetViewerEvent extends Equatable {
  const ResultSetViewerEvent();

  @override
  List<Object> get props => [];
}

class ResultSetViewerLoadRows extends ResultSetViewerEvent {
  const ResultSetViewerLoadRows();
}

class ResultSetViewerRowChanged extends ResultSetViewerEvent {
  const ResultSetViewerRowChanged();
}

class ResultSetViewerSaveChanges extends ResultSetViewerEvent {
  const ResultSetViewerSaveChanges();
}

class ResultSetViewerRejectChanges extends ResultSetViewerEvent {
  const ResultSetViewerRejectChanges();
}

class ResultSetViewerGenerateScript extends ResultSetViewerEvent {
  const ResultSetViewerGenerateScript();
}

class ResultSetViewerConfirmFailure extends ResultSetViewerEvent {
  const ResultSetViewerConfirmFailure();
}
