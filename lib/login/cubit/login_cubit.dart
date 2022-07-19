import 'package:authentication_repository/authentication_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authenticationRepository) : super(const LoginState());

  final AuthenticationRepository _authenticationRepository;

  Future<void> logInWithGoogleSliently() async {
    emit(state.copyWith(status: LoginStatus.inProgress));
    try {
      await _authenticationRepository.loginWithGoogleSliently();
    } catch (_) {
    } finally {
      emit(state.copyWith(status: LoginStatus.success));
    }
  }

  Future<void> logInWithGoogle() async {
    emit(state.copyWith(status: LoginStatus.inProgress));
    try {
      await _authenticationRepository.loginWithGoogle();
      emit(state.copyWith(status: LoginStatus.success));
    } on LogInWithGoogleFailure catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: LoginStatus.failure,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: LoginStatus.failure));
    }
  }
}
