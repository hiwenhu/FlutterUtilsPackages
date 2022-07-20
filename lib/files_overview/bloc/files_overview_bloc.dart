import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_cloud_repository/file_cloud_repository.dart';

part 'files_overview_event.dart';
part 'files_overview_state.dart';

class FilesOverviewBloc extends Bloc<FilesOverviewEvent, FilesOverviewState> {
  FilesOverviewBloc({
    required FileCloudRepository fileCloudRepository,
  })  : _fileCloudRepository = fileCloudRepository,
        super(const FilesOverviewState()) {
    on<FilesOverviewSubscriptionRequested>(_onSubscriptionRequested);
    // on<TodosOverviewTodoCompletionToggled>(_onTodoCompletionToggled);
    on<FilesOverviewTodoDeleted>(_onTodoDeleted);
    // on<TodosOverviewUndoDeletionRequested>(_onUndoDeletionRequested);
    // on<TodosOverviewFilterChanged>(_onFilterChanged);
    // on<TodosOverviewToggleAllRequested>(_onToggleAllRequested);
    // on<TodosOverviewClearCompletedRequested>(_onClearCompletedRequested);
  }

  final FileCloudRepository _fileCloudRepository;

  Future<void> _onSubscriptionRequested(
    FilesOverviewSubscriptionRequested event,
    Emitter<FilesOverviewState> emit,
  ) async {
    emit(state.copyWith(status: () => FilesOverviewStatus.loading));

    await emit.forEach<List<File>>(
      _fileCloudRepository.getFiles(),
      onData: (todos) => state.copyWith(
        status: () => FilesOverviewStatus.success,
        todos: () => todos,
      ),
      onError: (_, __) => state.copyWith(
        status: () => FilesOverviewStatus.failure,
      ),
    );
  }

  // Future<void> _onTodoCompletionToggled(
  //   TodosOverviewTodoCompletionToggled event,
  //   Emitter<FilesOverviewState> emit,
  // ) async {
  //   final newTodo = event.file.copyWith(isCompleted: event.isCompleted);
  //   await _todosRepository.saveTodo(newTodo);
  // }

  Future<void> _onTodoDeleted(
    FilesOverviewTodoDeleted event,
    Emitter<FilesOverviewState> emit,
  ) async {
    emit(state.copyWith(lastDeletedTodo: () => event.file));
    await _fileCloudRepository.deleteFile(event.file);
  }

  // Future<void> _onUndoDeletionRequested(
  //   TodosOverviewUndoDeletionRequested event,
  //   Emitter<FilesOverviewState> emit,
  // ) async {
  //   assert(
  //     state.lastDeletedTodo != null,
  //     'Last deleted todo can not be null.',
  //   );

  //   final todo = state.lastDeletedTodo!;
  //   emit(state.copyWith(lastDeletedTodo: () => null));
  //   await _fileCloudRepository.saveTodo(todo);
  // }

  // void _onFilterChanged(
  //   TodosOverviewFilterChanged event,
  //   Emitter<FilesOverviewState> emit,
  // ) {
  //   emit(state.copyWith(filter: () => event.filter));
  // }

  // Future<void> _onToggleAllRequested(
  //   TodosOverviewToggleAllRequested event,
  //   Emitter<FilesOverviewState> emit,
  // ) async {
  //   final areAllCompleted = state.todos.every((todo) => todo.isCompleted);
  //   await _fileCloudRepository.completeAll(isCompleted: !areAllCompleted);
  // }

  // Future<void> _onClearCompletedRequested(
  //   TodosOverviewClearCompletedRequested event,
  //   Emitter<FilesOverviewState> emit,
  // ) async {
  //   await _fileCloudRepository.clearCompleted();
  // }
}
