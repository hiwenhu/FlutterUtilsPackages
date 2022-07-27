part of 'file_apperance_bloc.dart';

abstract class FileApperanceEvent extends Equatable {
  const FileApperanceEvent();
  @override
  List<Object?> get props => [];
}

class FileDownloadingEvent extends FileApperanceEvent {
  const FileDownloadingEvent();
}

class FileUploadingEvent extends FileApperanceEvent {
  const FileUploadingEvent();
}

class FileApperanceGetCloudEvent extends FileApperanceEvent {
  const FileApperanceGetCloudEvent();
}
