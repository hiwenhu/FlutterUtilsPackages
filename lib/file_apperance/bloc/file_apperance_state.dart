part of 'file_apperance_bloc.dart';

enum FileApperanceStatus {
  initial,
  downloading,
  uploading,
  success,
  failure,
  conflict
}

extension FileApperanceStatusX on FileApperanceStatus {
  bool get isSyncing => const [
        FileApperanceStatus.uploading,
        FileApperanceStatus.downloading
      ].contains(this);

  bool get isDownloading => FileApperanceStatus.downloading == this;
  bool get isUploading => FileApperanceStatus.uploading == this;
}

class FileApperanceState extends Equatable {
  const FileApperanceState({
    required this.fileCloud,
    this.status = FileApperanceStatus.initial,
    this.errorMessage,
    this.progress,
  });

  final FileApperanceStatus status;
  final FileCloud fileCloud;
  final String? errorMessage;
  final double? progress;

  FileApperanceState copyWith({
    FileApperanceStatus? status,
    FileCloud? fileCloud,
    String? errorMessage,
    double? progress,
  }) {
    return FileApperanceState(
      status: status ?? this.status,
      fileCloud: fileCloud ?? this.fileCloud,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [status, fileCloud, errorMessage, progress];
}
