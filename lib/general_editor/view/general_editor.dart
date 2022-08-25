import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testimage/general_editor/cubit/general_editor_cubit.dart';
class GeneralEditorPage extends StatelessWidget {
  const GeneralEditorPage({
    Key? key,
    this.child,
    required this.creator,
  }) : super(key: key);

  final GeneralEditorCubit Function() creator;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => creator(),
      child: GeneralEditorView(child: child),
    );
  }
}

class GeneralEditorView extends StatefulWidget {
  const GeneralEditorView({
    Key? key,
    this.child,
  }) : super(key: key);
  final Widget? child;

  @override
  State<GeneralEditorView> createState() => _GeneralEditorViewState();
}

class _GeneralEditorViewState extends State<GeneralEditorView> {
  bool top = false;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeneralEditorCubit, GeneralEditorState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Item Details'),
            actions: top
                ? [
                    IconButton(icon: Icon(Icons.cancel), onPressed: () {}),
                    IconButton(icon: Icon(Icons.share), onPressed: () {}),
                    IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
                  ]
                : null,
          ),
          bottomNavigationBar: !top
              ? BottomAppBar(
                  shape: CircularNotchedRectangle(), //shape of notch
                  notchMargin: 5,
                  child: Row(
                    children: [
                      // IconButton(
                      //     color: Colors.green,
                      //     icon: Icon(Icons.play_arrow),
                      //     onPressed: () {}),
                      Spacer(),
                      IconButton(icon: Icon(Icons.cancel), onPressed: () {}),
                      IconButton(icon: Icon(Icons.share), onPressed: () {}),
                      IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
                    ],
                  ),
                )
              : null,
          floatingActionButton: FloatingActionButton(
            // foregroundColor: Colors.purpl,
            child: Icon(Icons.check),
            onPressed: () {
              setState(() {
                top = !top;
                // Future.delayed(Duration(seconds: 5))
                //     .then((value) => print('done'));
                context.read<GeneralEditorCubit>().test();
              });
            },
          ),
          floatingActionButtonLocation: top
              ? FloatingActionButtonLocation.endFloat
              : FloatingActionButtonLocation.centerDocked,
          body: Center(
            child: widget.child,
          ),
        );
      },
    );
  }
}
