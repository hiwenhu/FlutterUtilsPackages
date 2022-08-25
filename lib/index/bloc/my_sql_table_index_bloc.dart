import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:testimage/index/repository/my_sql_index_repository.dart';

part 'my_sql_table_index_event.dart';
part 'my_sql_table_index_state.dart';

class MySqlTableIndexBloc
    extends Bloc<MySqlTableIndexEvent, MySqlTableIndexState> {
  MySqlTableIndexBloc(this.indexRepository)
      : super(MySqlTableIndexState(
            unselectedColumns: indexRepository.getUnselected(const []))) {
    on<MySqlTableIndexSubscriptionRequested>(_onSubscriptionRequested);
    on<MySqlTableIndexSelectColumn>(_onSelectColumn);
    on<MySqlTableIndexUnSelectColumn>(_onUnSelectColumn);
    on<MySqlTableIndexMoveDownColumn>(_onMoveDownColumn);
    on<MySqlTableIndexMoveUpColumn>(_onMoveUpColumn);
    on<MySqlTableIndexReorderColumn>(_onReorderColumn);
  }

  final MySqlTableIndexRepository indexRepository;

  @override
  Future<void> close() async {
    indexRepository.dispose();
    super.close();
  }

  FutureOr<void> _onSubscriptionRequested(
      MySqlTableIndexSubscriptionRequested event,
      Emitter<MySqlTableIndexState> emit) async {
    emit(state.copyWith(status: MySqlTableIndexStatus.loading));
    await emit.forEach<List<String>>(indexRepository.selectedColumns,
        onData: (selected) {
      return state.copyWith(
        status: state.status == MySqlTableIndexStatus.columnSelected
            ? MySqlTableIndexStatus.columnUnselected
            : MySqlTableIndexStatus.columnSelected,
        selectedColumns: selected,
        unselectedColumns: indexRepository.getUnselected(selected),
      );
    });
  }

  FutureOr<void> _onSelectColumn(
      MySqlTableIndexSelectColumn event, Emitter<MySqlTableIndexState> emit) {
    indexRepository.selectColumn(event.columnName);
  }

  FutureOr<void> _onUnSelectColumn(
      MySqlTableIndexUnSelectColumn event, Emitter<MySqlTableIndexState> emit) {
    indexRepository.unselectColumn(event.columnName);
  }

  FutureOr<void> _onMoveDownColumn(
      MySqlTableIndexMoveDownColumn event, Emitter<MySqlTableIndexState> emit) {
    indexRepository.moveDownColumn(event.columnName);
  }

  FutureOr<void> _onMoveUpColumn(
      MySqlTableIndexMoveUpColumn event, Emitter<MySqlTableIndexState> emit) {
    indexRepository.moveUpColumn(event.columnName);
  }

  FutureOr<void> _onReorderColumn(
      MySqlTableIndexReorderColumn event, Emitter<MySqlTableIndexState> emit) {
    indexRepository.reorder(event.columnName, event.toPosition);
  }
}
