part of 'files_overview_bloc.dart';

enum FilesOverviewStatus { initial, loading, loadingCloud, success, failure }

class FilesOverviewState extends Equatable {
  const FilesOverviewState({
    this.status = FilesOverviewStatus.initial,
    this.files = const [],
    // this.filter = TodosViewFilter.all,
    this.lastDeletedFile,
    this.errorMessage,
  });

  final FilesOverviewStatus status;
  final List<FileCloud> files;
  // final TodosViewFilter filter;
  final FileCloud? lastDeletedFile;
  final String? errorMessage;

  // Iterable<Todo> get filteredTodos => filter.applyAll(todos);

  // FilesOverviewState copyWith({
  //   FilesOverviewStatus Function()? status,
  //   List<FileCloud> Function()? files,
  //   // TodosViewFilter Function()? filter,
  //   FileCloud? Function()? lastDeletedFile,
  //   String? errorMessage,
  // }) {
  //   return FilesOverviewState(
  //     status: status != null ? status() : this.status,
  //     files: files != null ? files() : this.files,
  //     // filter: filter != null ? filter() : this.filter,
  //     lastDeletedFile:
  //         lastDeletedFile != null ? lastDeletedFile() : this.lastDeletedFile,
  //     errorMessage: errorMessage ?? this.errorMessage,
  //   );
  // }

  FilesOverviewState copyWith({
    FilesOverviewStatus? status,
    List<FileCloud>? files,
    // TodosViewFilter Function()? filter,
    FileCloud? lastDeletedFile,
    String? errorMessage,
  }) {
    return FilesOverviewState(
      status: status != null ? status : this.status,
      files: files != null
          ? List.from(files)
          : List.from(
              this.files), //一定要用from,否则修改的是原来的引用,导致state还是之前的,这应该是equatabl的特性
      // filter: filter != null ? filter() : this.filter,
      lastDeletedFile:
          lastDeletedFile != null ? lastDeletedFile : this.lastDeletedFile,
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
