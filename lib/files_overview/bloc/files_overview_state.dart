part of 'files_overview_bloc.dart';

enum FilesOverviewStatus { initial, loading, success, failure }

class FilesOverviewState extends Equatable {
  const FilesOverviewState({
    this.status = FilesOverviewStatus.initial,
    this.files = const [],
    // this.filter = TodosViewFilter.all,
    this.lastDeletedFile,
  });

  final FilesOverviewStatus status;
  final List<File> files;
  // final TodosViewFilter filter;
  final File? lastDeletedFile;

  // Iterable<Todo> get filteredTodos => filter.applyAll(todos);

  FilesOverviewState copyWith({
    FilesOverviewStatus Function()? status,
    List<File> Function()? todos,
    // TodosViewFilter Function()? filter,
    File? Function()? lastDeletedTodo,
  }) {
    return FilesOverviewState(
      status: status != null ? status() : this.status,
      files: todos != null ? todos() : this.files,
      // filter: filter != null ? filter() : this.filter,
      lastDeletedFile:
          lastDeletedTodo != null ? lastDeletedTodo() : this.lastDeletedFile,
    );
  }

  @override
  List<Object?> get props => [
        status,
        files,
        // filter,
        lastDeletedFile,
      ];
}
