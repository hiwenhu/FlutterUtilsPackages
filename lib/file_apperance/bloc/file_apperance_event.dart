part of 'file_apperance_bloc.dart';

abstract class FileApperanceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FileDownloadingEvent extends FileApperanceEvent {}

class FileUploadingEvent extends FileApperanceEvent {}

class FileApperanceGetCloudEvent extends FileApperanceEvent {}
