part of 'edit_file_bloc.dart';

abstract class EditFileEvent extends Equatable {
  const EditFileEvent();

  @override
  List<Object> get props => [];
}

class EditFileContentChanged extends EditFileEvent {
  const EditFileContentChanged(this.content);

  final String content;

  @override
  List<Object> get props => [content];
}

class EditFileSubmitted extends EditFileEvent {
  const EditFileSubmitted();
}
