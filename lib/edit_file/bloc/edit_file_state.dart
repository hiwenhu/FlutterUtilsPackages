part of 'edit_file_bloc.dart';

enum EditFileStatus { initial, loading, success, failure }

extension EditFileStatusX on EditFileStatus {
  bool get isLoadingOrSuccess =>
      [EditFileStatus.loading, EditFileStatus.success].contains(this);
}

class EditFileState extends Equatable {
  const EditFileState({
    this.status = EditFileStatus.initial,
    this.initialFile,
    this.content = '',
    this.errorMessage,
  });

  final EditFileStatus status;
  final File? initialFile;
  final String content;
  final String? errorMessage;

  bool get isNewFile => initialFile == null;

  EditFileState copyWith(
      {EditFileStatus? status, File? initialFile, String? content, String? errorMessage}) {
    return EditFileState(
      status: status ?? this.status,
      initialFile: initialFile ?? this.initialFile,
      content: content ?? this.content,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, initialFile, content, errorMessage];
}
