part of 'edit_file_bloc.dart';

abstract class EditFileEvent extends Equatable {
  const EditFileEvent();

  @override
  List<Object?> get props => [];
}

class EditFileInited extends EditFileEvent {
  const EditFileInited();
}

class EditFileContentChanged extends EditFileEvent {
  const EditFileContentChanged({required this.content, this.status});

  final String content;
  final EditFileStatus? status;

  @override
  List<Object?> get props => [status, content];
}

class EditFileSubmitted extends EditFileEvent {
  const EditFileSubmitted();
}
