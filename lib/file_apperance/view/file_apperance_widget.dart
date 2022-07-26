import 'package:file_cloud_repository/file_cloud_repository.dart';
import 'package:file_cloud_repository/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googledrive_file_cloud/googledrive_file_cloud.dart';
import 'package:path/path.dart';
import 'package:testimage/edit_file/view/edit_file_page.dart';
import 'package:testimage/file_apperance/bloc/file_apperance_bloc.dart';
import 'package:testimage/file_apperance/widget/icon_circularprogress_indicator.dart';
import 'package:testimage/files_overview/bloc/files_overview_bloc.dart';

class FileApperanceWidget extends StatelessWidget {
  const FileApperanceWidget({Key? key, required this.fileCloud})
      : super(key: key);

  final FileCloud fileCloud;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FileApperanceBloc>(
      create: (context) => FileApperanceBloc(
          context.read<GoogleDriveFileRepository>(), fileCloud),
      child: const FileApperanceListTile(),
    );
  }
}

class FileApperanceListTile extends StatelessWidget {
  const FileApperanceListTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<FileApperanceBloc, FileApperanceState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == FileApperanceStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Unknown error')));
        }
      },
      child: BlocBuilder<FileApperanceBloc, FileApperanceState>(
          // buildWhen: (previous, current) => previous.status != current.status,
          builder: (context, state) {
        return Dismissible(
          key: UniqueKey(),
          onDismissed: state.status.isSyncing
              ? null
              : (_) => context
                  .read<FilesOverviewBloc>()
                  .add(FilesOverviewTodoDeleted(
                    state.fileCloud,
                  )),
          child: ListTile(
            leading: state.status.isSyncing
                ? IconCircularProgressIndicator(
                    progress: state.progress,
                    child: state.status.isDownloading
                        ? const Icon(Icons.downloading)
                        : const Icon(Icons.upload),
                  )
                : state.fileCloud.needDownloading
                    ? IconButton(
                        onPressed: () {
                          context
                              .read<FileApperanceBloc>()
                              .add(FileDownloadingEvent());
                        },
                        icon: const Icon(Icons.download),
                      )
                    : state.fileCloud.needUploading
                        ? IconButton(
                            onPressed: () {
                              context
                                  .read<FileApperanceBloc>()
                                  .add(FileUploadingEvent());
                            },
                            icon: const Icon(Icons.upload),
                          )
                        : state.fileCloud.needGetFromCloud
                            ? IconButton(
                                onPressed: () {
                                  context
                                      .read<FileApperanceBloc>()
                                      .add(FileApperanceGetCloudEvent());
                                },
                                icon: const Icon(Icons.cloud),
                              )
                            : const Icon(Icons.file_copy),
            title: Text(basename(state.fileCloud.file.path)),
            subtitle: Text(
                'vertsion${state.fileCloud.version.toString()}/cloudVersion:${state.fileCloud.cloudVersion.toString()}'),
            onTap: state.status.isSyncing || state.status.inFailure
                ? null
                : () => Navigator.of(context).push(EditFilePage.route(context,
                    initialFile: state.fileCloud.file)),
            trailing: state.status == FileApperanceStatus.conflict
                ? const Icon(Icons.error)
                : null,
          ),
        );
      }),
    );
  }
}
