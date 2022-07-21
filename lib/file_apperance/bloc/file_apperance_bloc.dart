import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_cloud_repository/file_cloud_repository.dart';
import 'package:file_cloud_repository/models/models.dart';

part 'file_apperance_state.dart';
part 'file_apperance_event.dart';

class FileApperanceBloc extends Bloc<FileApperanceEvent, FileApperanceState> {
  FileApperanceBloc(this.fileCloudRepository, FileCloud fileCloud)
      : super(FileApperanceState(
          fileCloud: fileCloud,
        )) {
    on<FileDownloadingEvent>(_onFileDownloading);
    on<FileUploadingEvent>(_onFileUploading);
  }

  final FileCloudRepository fileCloudRepository;

  FutureOr<void> _onFileDownloading(
      FileDownloadingEvent event, Emitter<FileApperanceState> emit) async {
    emit(state.copyWith(status: FileApperanceStatus.downloading));
    try {
      await fileCloudRepository.download(
        state.fileCloud,
        () => emit(state.copyWith(
          fileCloud: state.fileCloud.copyWith(
            version: state.fileCloud.cloudVersion,
          ),
          status: FileApperanceStatus.success,
        )),
      );
    } catch (e) {
      emit(state.copyWith(
        status: FileApperanceStatus.failure,
      ));
    }
  }

  FutureOr<void> _onFileUploading(
      FileUploadingEvent event, Emitter<FileApperanceState> emit) async {
    emit(state.copyWith(status: FileApperanceStatus.uploading));
    try {
      var fileCloud = await fileCloudRepository.upload(state.fileCloud);
      emit(state.copyWith(
        fileCloud: fileCloud,
        status: FileApperanceStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FileApperanceStatus.failure,
      ));
    }
  }
}
