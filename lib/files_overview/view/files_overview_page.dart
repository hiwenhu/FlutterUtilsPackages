import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googledrive_file_cloud/googledrive_file_cloud.dart';
import 'package:testimage/app/view/app_drawer.dart';
import 'package:testimage/cloud/switch/cubit/cloud_switch_cubit.dart';
import 'package:testimage/edit_file/view/edit_file_page.dart';
import 'package:testimage/files_overview/bloc/files_overview_bloc.dart';
import 'package:testimage/files_overview/widgets/file_list_tile.dart';

class FilesOverviewPage extends StatelessWidget {
  const FilesOverviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CloudSwitchCubit, CloudSwitchState>(
      builder: (context, state) {
        var fileCloudRepository = GoogleDriveFileRepository(
            account: context.read<AuthenticationRepository>().currentUser);
        return
            // state.status == CloudSwitchStatus.on?
            BlocProvider<FilesOverviewBloc>(
          create: (context) => FilesOverviewBloc(
            fileCloudRepository: fileCloudRepository,
          )..add(const FilesOverviewSubscriptionRequested()),
          child: RepositoryProvider.value(
            value: fileCloudRepository,
            child: const FilesOverviewView(),
          ),
        )
            // : Scaffold(
            //     appBar: AppBar(
            //       title: const Text("Files"),
            //     ),
            //     body: const SafeArea(child: Center(child: Text('Todo'))),
            //     drawer: const AppDrawer(),
            //   )
            ;
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
        actions: [
          BlocSelector<FilesOverviewBloc, FilesOverviewState,
              FilesOverviewStatus>(
            selector: (state) {
              return state.status;
            },
            builder: (context, status) {
              return IconButton(
                onPressed: status == FilesOverviewStatus.loading
                    ? null
                    : () {
                        context
                            .read<FilesOverviewBloc>()
                            .add(const FilesOverviewSubscriptionRequested());
                      },
                icon: const Icon(
                  Icons.refresh,
                ),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        key: const Key('homeView_addTodo_floatingActionButton'),
        onPressed: () {
          Navigator.of(context).push(EditFilePage.route(context));
        },
        child: const Icon(Icons.add),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<FilesOverviewBloc, FilesOverviewState>(
              listenWhen: (previous, current) =>
                  previous.status != current.status,
              listener: (context, state) {
                if (state.status == FilesOverviewStatus.failure) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage ?? 'Unknown error'),
                      ),
                    );
                }
              }),
        ],
        child: BlocBuilder<FilesOverviewBloc, FilesOverviewState>(
          builder: (context, state) {
            // if (state.files.isEmpty) {
            if (state.status == FilesOverviewStatus.loading) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
              // return const Center(
              //     child: CupertinoActivityIndicator(
              //   color: Colors.yellow,
              // ),);
            } else if (state.status != FilesOverviewStatus.success) {
              return const SizedBox();
            } else if (state.files.isEmpty) {
              return Center(
                child: Text(
                  'empty',
                  // l10n.FilesOverviewEmptyText,
                  style: Theme.of(context).textTheme.caption,
                ),
              );
            }
            // }

            return CupertinoScrollbar(
              child: ListView(
                children: [
                  for (final file in state.files)
                    FileListTile(
                      file: file.file,
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
                            .add(FilesOverviewTodoDeleted(file));
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
