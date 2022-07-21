part of 'files_overview_bloc.dart';

enum FilesOverviewStatus { initial, loading, success, failure }

class FilesOverviewState extends Equatable {
  const FilesOverviewState({
    this.status = FilesOverviewStatus.initial,
    this.files = const [],
    // this.filter = TodosViewFilter.all,
    this.lastDeletedFile,
    this.errorMessage,
  });

  final FilesOverviewStatus status;
  final List<File> files;
  // final TodosViewFilter filter;
  final File? lastDeletedFile;
  final String? errorMessage;

  // Iterable<Todo> get filteredTodos => filter.applyAll(todos);

  FilesOverviewState copyWith({
    FilesOverviewStatus Function()? status,
    List<File> Function()? files,
    // TodosViewFilter Function()? filter,
    File? Function()? lastDeletedFile,
    String? errorMessage,
  }) {
    return FilesOverviewState(
      status: status != null ? status() : this.status,
      files: files != null ? files() : this.files,
      // filter: filter != null ? filter() : this.filter,
      lastDeletedFile:
          lastDeletedFile != null ? lastDeletedFile() : this.lastDeletedFile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        files,
        // filter,
        lastDeletedFile,
        errorMessage,
      ];
}
