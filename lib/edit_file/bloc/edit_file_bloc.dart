import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:file_cloud_repository/file_cloud_repository.dart';

part 'edit_file_event.dart';
part 'edit_file_state.dart';

class EditFileBloc extends Bloc<EditFileEvent, EditFileState> {
  EditFileBloc({
    required FileCloudRepository fileCloudRepository,
    required File? initialFile,
  })  : _fileCloudRepository = fileCloudRepository,
        super(
          EditFileState(
            initialFile: initialFile,
            content: initialFile?.readAsStringSync() ?? '',
          ),
        ) {
    on<EditFileSubmitted>(_onSubmitted);
    on<EditFileContentChanged>(_onContentChanged);
  }

  final FileCloudRepository _fileCloudRepository;

  FutureOr<void> _onSubmitted(
      EditFileSubmitted event, Emitter<EditFileState> emit) async {
    emit(state.copyWith(
      status: EditFileStatus.loading,
    ));

    try {
      final file = (state.initialFile ?? _fileCloudRepository.newFile('tmp'));
      if (Platform.isAndroid) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        if (androidInfo.isPhysicalDevice == true) {
          await file.writeAsString(state.content);
        }
      }

      _fileCloudRepository.saveFile(file);

      emit(state.copyWith(
        status: EditFileStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EditFileStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  FutureOr<void> _onContentChanged(
      EditFileContentChanged event, Emitter<EditFileState> emit) {
    emit(
      state.copyWith(
        content: event.content,
      ),
    );
  }
}
