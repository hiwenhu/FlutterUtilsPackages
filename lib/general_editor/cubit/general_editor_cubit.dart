import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'general_editor_state.dart';

class GeneralEditorCubit extends Cubit<GeneralEditorState> {
  GeneralEditorCubit() : super(GeneralEditorInitial());

  void test() {
    print('object');
  }
}

class GeneralEditorCubitA extends GeneralEditorCubit {
  @override
  void test() {
    print('A');
  }
}

class GeneralEditorCubitB extends GeneralEditorCubit {
  @override
  void test() {
    print('B');
  }
}
