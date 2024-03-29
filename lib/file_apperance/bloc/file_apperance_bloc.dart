import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_cloud_repository/file_cloud_repository.dart';
import 'package:file_cloud_repository/models/models.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/abusiveexperiencereport/v1.dart';
import 'package:exception_extension/exception_extension.dart';

part 'file_apperance_state.dart';
part 'file_apperance_event.dart';

class FileApperanceBloc extends Bloc<FileApperanceEvent, FileApperanceState> {
  FileApperanceBloc(this.fileCloudRepository, FileCloud fileCloud)
      : super(FileApperanceState(
          fileCloud: fileCloud,
        )) {
    on<FileDownloadingEvent>(_onFileDownloading);
    on<FileUploadingEvent>(_onFileUploading);
    on<FileApperanceGetCloudEvent>(_onFileGetCloud);
    // interactWithCloud(fileCloud);
    _init();
  }

  void _init() {
    if (state.fileCloud.needGetFromCloud) {
      add(const FileApperanceGetCloudEvent());
    }
  }

  void interactWithCloud(FileCloud fileCloud) {
    if (fileCloud.needDownloading) {
      add(const FileDownloadingEvent());
    } else if (fileCloud.needUploading) {
      add(const FileUploadingEvent());
    }
  }

  final FileCloudRepository fileCloudRepository;

  FutureOr<void> _onFileDownloading(
      FileDownloadingEvent event, Emitter<FileApperanceState> emit) async {
    if (!fileCloudRepository.canUseCloud) return;

    emit(state.copyWith(status: FileApperanceStatus.downloading));
    try {
      // var fileCloud = await fileCloudRepository.download(
      //   state.fileCloud,
      // );

      // emit(state.copyWith(
      //   fileCloud: fileCloud,
      //   status: FileApperanceStatus.success,
      // ));

      await for (var result
          in fileCloudRepository.downloadStream(state.fileCloud)) {
        if (result is double) {
          emit(state.copyWith(progress: result));
        } else if (result is FileCloud) {
          emit(state.copyWith(
            fileCloud: result,
            status: FileApperanceStatus.success,
          ));
        }
      }
    } catch (e) {
      emit(state.copyWith(
        status: FileApperanceStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  FutureOr<void> _onFileUploading(
      FileUploadingEvent event, Emitter<FileApperanceState> emit) async {
    if (!fileCloudRepository.canUseCloud) return;
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
        errorMessage: e.exceptionMsg,
      ));
    }
  }

  FutureOr<void> _onFileGetCloud(FileApperanceGetCloudEvent event,
      Emitter<FileApperanceState> emit) async {
    emit(state.copyWith(status: FileApperanceStatus.reCloud));
    try {
      var fileCloud =
          await fileCloudRepository.localFileReCloud(state.fileCloud);
      emit(state.copyWith(
        status: FileApperanceStatus.success,
        fileCloud: fileCloud,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FileApperanceStatus.failure,
        errorMessage: e.exceptionMsg,
      ));
    }
  }
}
