part of 'my_sql_table_index_bloc.dart';

abstract class MySqlTableIndexEvent extends Equatable {
  const MySqlTableIndexEvent();

  @override
  List<Object> get props => [];
}

class MySqlTableIndexSubscriptionRequested extends MySqlTableIndexEvent {
  const MySqlTableIndexSubscriptionRequested();
}

class MySqlTableIndexSelectColumn extends MySqlTableIndexEvent {
  const MySqlTableIndexSelectColumn(this.columnName);

  final String columnName;
}

class MySqlTableIndexUnSelectColumn extends MySqlTableIndexEvent {
  const MySqlTableIndexUnSelectColumn(this.columnName);

  final String columnName;
}

class MySqlTableIndexMoveDownColumn extends MySqlTableIndexEvent {
  const MySqlTableIndexMoveDownColumn(this.columnName);

  final String columnName;
}

class MySqlTableIndexMoveUpColumn extends MySqlTableIndexEvent {
  const MySqlTableIndexMoveUpColumn(this.columnName);

  final String columnName;
}

class MySqlTableIndexReorderColumn extends MySqlTableIndexEvent {
  const MySqlTableIndexReorderColumn(this.columnName, this.toPosition);

  final String columnName;
  final int toPosition;
}
