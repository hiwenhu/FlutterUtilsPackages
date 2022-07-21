part of 'file_apperance_bloc.dart';

enum FileApperanceStatus { initial, downloading, uploading, success, failure, conflict }

class FileApperanceState extends Equatable {
  const FileApperanceState({
    required this.fileCloud,
    this.status = FileApperanceStatus.initial,
  });

  final FileApperanceStatus status;
  final FileCloud fileCloud;

  FileApperanceState copyWith({
    FileApperanceStatus? status,
    FileCloud? fileCloud,
  }) {
    return FileApperanceState(
      status: status ?? this.status,
      fileCloud: fileCloud ?? this.fileCloud,
    );
  }

  @override
  List<Object?> get props => [status, fileCloud];
}
