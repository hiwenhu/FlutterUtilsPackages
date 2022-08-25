part of 'my_sql_table_index_bloc.dart';

enum MySqlTableIndexStatus {
  initial,
  loading,
  success,
  columnSelected,
  columnUnselected,
  columnMoveDown,
  columnMoveUp,
}

class MySqlTableIndexState extends Equatable {
  const MySqlTableIndexState({
    this.status = MySqlTableIndexStatus.initial,
    this.selectedColumns = const [],
    this.unselectedColumns = const [],
  });

  final MySqlTableIndexStatus status;
  final List<String> selectedColumns;
  final List<String> unselectedColumns;

  MySqlTableIndexState copyWith({
    MySqlTableIndexStatus? status,
    List<String>? selectedColumns,
    List<String>? unselectedColumns,
  }) {
    return MySqlTableIndexState(
      status: status ?? this.status,
      selectedColumns: selectedColumns ?? this.selectedColumns,
      unselectedColumns: unselectedColumns ?? this.unselectedColumns,
    );
  }

  @override
  List get props => [status, selectedColumns, unselectedColumns];
}
