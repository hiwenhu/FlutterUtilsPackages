import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googledrive_file_cloud/googledrive_file_cloud.dart';
import 'package:testimage/cloud/switch/cubit/cloud_switch_cubit.dart';
import 'package:testimage/files_overview/bloc/files_overview_bloc.dart';
import 'package:testimage/files_overview/widgets/file_list_tile.dart';

class FilesOverviewPage extends StatelessWidget {
  const FilesOverviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CloudSwitchCubit, CloudSwitchState>(
      builder: (context, state) {
        return state.status == CloudSwitchStatus.on
            ? BlocProvider<FilesOverviewBloc>(
                create: (context) => FilesOverviewBloc(
                  fileCloudRepository: GoogleDriveFileRepository(
                      account:
                          context.read<AuthenticationRepository>().currentUser),
                ),
                child: const FilesOverviewView(),
              )
            : const Text('Todo');
      },
    );
  }
}

class FilesOverviewView extends StatelessWidget {
  const FilesOverviewView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Files'),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<FilesOverviewBloc, FilesOverviewState>(
              listenWhen: (previous, current) =>
                  previous.status != current.status,
              listener: (context, state) {}),
        ],
        child: BlocBuilder<FilesOverviewBloc, FilesOverviewState>(
          builder: (context, state) {
            if (state.files.isEmpty) {
              if (state.status == FilesOverviewStatus.loading) {
                return const Center(child: CupertinoActivityIndicator());
              } else if (state.status != FilesOverviewStatus.success) {
                return const SizedBox();
              } else {
                return Center(
                  child: Text(
                    'empty',
                    // l10n.FilesOverviewEmptyText,
                    style: Theme.of(context).textTheme.caption,
                  ),
                );
              }
            }

            return CupertinoScrollbar(
              child: ListView(
                children: [
                  for (final todo in state.files)
                    FileListTile(
                      file: todo,
                      // onToggleCompleted: (isCompleted) {
                      //   context.read<FilesOverviewBloc>().add(
                      //         FilesOverviewTodoCompletionToggled(
                      //           file: todo,
                      //           isCompleted: isCompleted,
                      //         ),
                      //       );
                      // },
                      onDismissed: (_) {
                        context
                            .read<FilesOverviewBloc>()
                            .add(FilesOverviewTodoDeleted(todo));
                      },
                      // onTap: () {
                      //   Navigator.of(context).push(
                      //     EditTodoPage.route(initialTodo: todo),
                      //   );
                      // },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
