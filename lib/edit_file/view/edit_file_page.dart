import 'dart:io';

import 'package:file_cloud_repository/file_cloud_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googledrive_file_cloud/googledrive_file_cloud.dart';
import 'package:testimage/edit_file/bloc/edit_file_bloc.dart';

class EditFilePage extends StatelessWidget {
  const EditFilePage({Key? key}) : super(key: key);

  static Route<void> route(
    BuildContext preContext, {
    File? initialFile,
  }) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => BlocProvider(
        create: (_) => EditFileBloc(
          fileCloudRepository: preContext.read<GoogleDriveFileRepository>(),
          initialFile: initialFile,
        ),
        child: const EditFilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditFileBloc, EditFileState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == EditFileStatus.success,
      listener: (context, state) => Navigator.pop(context),
      child: const EditFileView(),
    );
  }
}

class EditFileView extends StatelessWidget {
  const EditFileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = context.select((EditFileBloc bloc) => bloc.state.status);
    final theme = Theme.of(context);
    final floatingActionButtonTheme = theme.floatingActionButtonTheme;
    final fabBackgroundColor = floatingActionButtonTheme.backgroundColor ??
        theme.colorScheme.secondary;
    return BlocListener<EditFileBloc, EditFileState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.status == EditFileStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Unknown error'),
              ),
            );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Editing file"),
        ),
        floatingActionButton: FloatingActionButton(
          // tooltip: l10n.editTodoSaveButtonTooltip,
          shape: const ContinuousRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32)),
          ),
          backgroundColor: status.isLoadingOrSuccess
              ? fabBackgroundColor.withOpacity(0.5)
              : fabBackgroundColor,
          onPressed: status.isLoadingOrSuccess
              ? null
              : () {
                  context.read<EditFileBloc>().add(const EditFileSubmitted());
                },
          child: status.isLoadingOrSuccess
              ? const CupertinoActivityIndicator()
              : const Icon(Icons.check_rounded),
        ),
        body: SafeArea(child: const FileEditField()),
      ),
    );
  }
}

class FileEditField extends StatelessWidget {
  const FileEditField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditFileBloc>().state;

    return TextFormField(
      key: const Key('editFileView_textFormField'),
      initialValue: state.content,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
      ),
      maxLength: 50,
      onChanged: (value) {
        context
            .read<EditFileBloc>()
            .add(EditFileContentChanged(content: value));
      },
    );
  }
}
