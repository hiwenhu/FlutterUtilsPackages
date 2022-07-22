part of 'files_overview_bloc.dart';

abstract class FilesOverviewEvent extends Equatable {
  const FilesOverviewEvent();

  @override
  List<Object> get props => [];
}

class FilesOverviewSubscriptionRequested extends FilesOverviewEvent {
  const FilesOverviewSubscriptionRequested();
}

class FilesOverviewRefreshRequested extends FilesOverviewEvent {
  const FilesOverviewRefreshRequested();
}

// class TodosOverviewTodoCompletionToggled extends TodosOverviewEvent {
//   const TodosOverviewTodoCompletionToggled({
//     required this.todo,
//     required this.isCompleted,
//   });

//   final Todo todo;
//   final bool isCompleted;

//   @override
//   List<Object> get props => [todo, isCompleted];
// }

class FilesOverviewTodoDeleted extends FilesOverviewEvent {
  const FilesOverviewTodoDeleted(this.file);

  final FileCloud file;

  @override
  List<Object> get props => [file];
}

// class TodosOverviewUndoDeletionRequested extends TodosOverviewEvent {
//   const TodosOverviewUndoDeletionRequested();
// }

// class TodosOverviewFilterChanged extends TodosOverviewEvent {
//   const TodosOverviewFilterChanged(this.filter);

//   final TodosViewFilter filter;

//   @override
//   List<Object> get props => [filter];
// }

// class TodosOverviewToggleAllRequested extends TodosOverviewEvent {
//   const TodosOverviewToggleAllRequested();
// }

// class TodosOverviewClearCompletedRequested extends TodosOverviewEvent {
//   const TodosOverviewClearCompletedRequested();
// }
