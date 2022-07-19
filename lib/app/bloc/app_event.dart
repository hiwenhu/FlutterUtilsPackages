part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List get props => [];
}

class AppLogoutRequested extends AppEvent {}

class AppUserChanged extends AppEvent {
  const AppUserChanged(this.user);

  final GoogleSignInAccount? user;

  @override
  List get props => [user];
}