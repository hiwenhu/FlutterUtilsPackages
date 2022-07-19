part of 'login_cubit.dart';

enum LoginStatus {
  initial,
  inProgress,
  success,
  failure,
}

class LoginState extends Equatable {
  const LoginState({this.status = LoginStatus.initial, this.errorMessage});

  @override
  List get props => [status, errorMessage];

  final LoginStatus status;
  final String? errorMessage;

  LoginState copyWith({LoginStatus? status, String? errorMessage}) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
