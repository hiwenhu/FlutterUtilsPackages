import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testimage/resultsets_overview/bloc/result_set_viewer_bloc.dart';

class ResultSetViewerPage extends StatelessWidget {
  const ResultSetViewerPage({
    Key? key,
    required this.resultSetViewerBloc,
  }) : super(key: key);

  final ResultSetViewerBloc resultSetViewerBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: resultSetViewerBloc,
      child: const ResultSetViewerWidget(),
    );
  }
}

class ResultSetViewerWidget extends StatelessWidget {
  const ResultSetViewerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 160,
          color: Color.fromARGB(255, Random().nextInt(256),
              Random().nextInt(256), Random().nextInt(256)),
          child: Center(
            child: ElevatedButton(
                onPressed: () {
                  context
                      .read<ResultSetViewerBloc>()
                      .add(const ResultSetViewerRowChanged());
                },
                child: const Text('Change row')),
          ),
        ),
        BlocBuilder<ResultSetViewerBloc, ResultSetViewerState>(
            builder: (context, state) {
          var status = state.status;
          return status.isProceeding
              ? Stack(
                  children: [
                    ModalBarrier(
                      color: Colors.grey.withOpacity(0.6),
                      onDismiss: () {},
                    ),
                    const Center(child: CircularProgressIndicator.adaptive()),
                  ],
                )
              : status == ResultSetViewerStatus.failure
                  ? Stack(children: [
                      ModalBarrier(
                        color: Colors.grey.withOpacity(0.6),
                        dismissible: false,
                      ),
                      AlertDialog(
                        content: Text(state.message ?? 'Error'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              context
                                  .read<ResultSetViewerBloc>()
                                  .add(const ResultSetViewerConfirmFailure());
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ])
                  : const SizedBox.shrink();
        }),
      ],
    );
  }
}
