import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:exception_extension/exception_extension.dart';

part 'result_set_viewer_event.dart';
part 'result_set_viewer_state.dart';

class ResultSetViewer {
  int changedCount = 0;

  ResultSetViewer({required this.id});

  final int id;

  Future<void> saveChanges() async {
    await Future.delayed(
      const Duration(seconds: 5),
    );

    if (Random().nextDouble() < 2) {
      throw Exception('saveChanges err');
    }

    changedCount = 0;
  }

  Future<void> rejectChanges() async {
    await Future.delayed(
      const Duration(seconds: 5),
    );

    if (Random().nextDouble() < 0.2) {
      throw Exception('rejectChanges err');
    }

    changedCount = 0;
  }

  Future<void> loadRows() async {
    await Future.delayed(
      const Duration(seconds: 5),
    );

    if (Random().nextDouble() < 0.2) {
      throw Exception('loadRows err');
    }
  }

  Future<void> editRows() async {
    changedCount += 1;
  }
}

class ResultSetViewerBloc
    extends Bloc<ResultSetViewerEvent, ResultSetViewerState> {
  ResultSetViewerBloc({
    required this.resultSetViewr,
  }) : super(const ResultSetViewerState()) {
    on<ResultSetViewerLoadRows>(_onLoadRows);
    on<ResultSetViewerRowChanged>(_onRowChanged);
    on<ResultSetViewerSaveChanges>(_onSaveChanges);
    on<ResultSetViewerRejectChanges>(_onRejectChanges);
    on<ResultSetViewerGenerateScript>(_onGenerateScript);
    on<ResultSetViewerConfirmFailure>(_onConfirmFailure);
  }

  final ResultSetViewer resultSetViewr;

  FutureOr<void> _onRowChanged(ResultSetViewerRowChanged event,
      Emitter<ResultSetViewerState> emit) async {
    await resultSetViewr.editRows();

    emit(state.copyWith(
      changedCount: resultSetViewr.changedCount,
    ));
  }

  FutureOr<void> _onSaveChanges(ResultSetViewerSaveChanges event,
      Emitter<ResultSetViewerState> emit) async {
    emit(state.copyWith(status: ResultSetViewerStatus.saving));
    try {
      await resultSetViewr.saveChanges();
      emit(state.copyWith(
        status: ResultSetViewerStatus.success,
        changedCount: resultSetViewr.changedCount,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ResultSetViewerStatus.failure,
        message: e.exceptionMsg,
        changedCount: resultSetViewr.changedCount,
      ));
    }
  }

  FutureOr<void> _onRejectChanges(ResultSetViewerRejectChanges event,
      Emitter<ResultSetViewerState> emit) async {
    emit(state.copyWith(status: ResultSetViewerStatus.rejecting));
    try {
      await resultSetViewr.rejectChanges();
      emit(state.copyWith(
        status: ResultSetViewerStatus.success,
        changedCount: resultSetViewr.changedCount,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ResultSetViewerStatus.failure,
        message: e.exceptionMsg,
        changedCount: resultSetViewr.changedCount,
      ));
    }
  }

  FutureOr<void> _onGenerateScript(
      ResultSetViewerGenerateScript event, Emitter<ResultSetViewerState> emit) {
    emit(state.copyWith(status: ResultSetViewerStatus.script));
  }

  FutureOr<void> _onLoadRows(
      ResultSetViewerLoadRows event, Emitter<ResultSetViewerState> emit) async {
    emit(state.copyWith(status: ResultSetViewerStatus.loading));
    try {
      await resultSetViewr.loadRows();
      emit(state.copyWith(
        status: ResultSetViewerStatus.success,
        changedCount: resultSetViewr.changedCount,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ResultSetViewerStatus.failure,
        message: e.exceptionMsg,
        changedCount: resultSetViewr.changedCount,
      ));
    }
  }

  FutureOr<void> _onConfirmFailure(
      ResultSetViewerConfirmFailure event, Emitter<ResultSetViewerState> emit) {
    emit(state.copyWith(status: ResultSetViewerStatus.initial));
  }
}
