import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:getwidget/getwidget.dart';
import 'package:testimage/index/bloc/my_sql_table_index_bloc.dart';
import 'package:testimage/index/repository/my_sql_index_repository.dart';

class MySqlIndexPage extends StatelessWidget {
  const MySqlIndexPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MySqlTableIndexBloc(MySqlTableIndexRepository())
        ..add(const MySqlTableIndexSubscriptionRequested()),
      child: const MySqlTableIndexView(),
    );
  }
}

class MySqlTableIndexView extends StatelessWidget {
  const MySqlTableIndexView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Index'),
      ),
      body: SafeArea(
        child: BlocBuilder<MySqlTableIndexBloc, MySqlTableIndexState>(
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  flex: state.selectedColumns.length + 1,
                  child: ReorderableListView.builder(
                    header: const GFTypography(
                      text: 'Selected Table Columns',
                      type: GFTypographyType.typo5,
                      dividerWidth: 25,
                      dividerColor: Color(0xFF19CA4B),
                    ),
                    key: const Key('ReorderableExpasionTileList'),
                    itemBuilder: (context, index) {
                      var columnName = state.selectedColumns[index];
                      return Slidable(
                        key: Key('$index'),
                        groupTag: "indexColumn",
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              label: 'Delete',
                              backgroundColor: Colors.red,
                              icon: Icons.delete,
                              onPressed: (context) {
                                context.read<MySqlTableIndexBloc>().add(
                                    MySqlTableIndexUnSelectColumn(columnName));
                              },
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(columnName),
                          trailing: const Icon(Icons.drag_handle),
                          // leading: index == 0
                          //     ? const SizedBox.shrink()
                          //     : IconButton(
                          //         onPressed: () {
                          //           context.read<MySqlTableIndexBloc>().add(
                          //               MySqlTableIndexMoveUpColumn(
                          //                   columnName));
                          //         },
                          //         icon: const Icon(Icons.arrow_upward)),
                          // trailing: index == state.selectedColumns.length - 1
                          //     ? const SizedBox.shrink()
                          //     : IconButton(
                          //         onPressed: () {
                          //           context.read<MySqlTableIndexBloc>().add(
                          //               MySqlTableIndexMoveDownColumn(
                          //                   columnName));
                          //         },
                          //         icon: const Icon(Icons.arrow_downward)),
                          leading: IconButton(
                            onPressed: () {
                              context.read<MySqlTableIndexBloc>().add(
                                  MySqlTableIndexUnSelectColumn(columnName));
                            },
                            color: Colors.red,
                            icon: const Icon(Icons.remove_circle),
                          ),
                        ),
                      );
                    },
                    itemCount: state.selectedColumns.length,
                    onReorder: (int oldIndex, int newIndex) {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      context.read<MySqlTableIndexBloc>().add(
                          MySqlTableIndexReorderColumn(
                              state.selectedColumns[oldIndex], newIndex));
                    },
                  ),
                ),
                const Divider(),
                Expanded(
                  flex: state.unselectedColumns.length + 1,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      var columnName =
                          index == 0 ? '' : state.unselectedColumns[index - 1];
                      return index == 0
                          ? const GFTypography(
                              text: 'Unselected Table Columns',
                              type: GFTypographyType.typo5,
                              dividerWidth: 25,
                              dividerColor: Color(0xFF19CA4B),
                            )
                          : ListTile(
                              trailing: const Icon(
                                Icons.add_circle,
                                color: Colors.green,
                              ),
                              title: Text(columnName),
                              onTap: () {
                                context.read<MySqlTableIndexBloc>().add(
                                    MySqlTableIndexSelectColumn(columnName));
                              });
                    },
                    itemCount: state.unselectedColumns.length + 1,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
