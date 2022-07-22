import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testimage/app/bloc/app_bloc.dart';
import 'package:testimage/login/cubit/login_cubit.dart';

import 'cloud_switch_page.dart';

class CloudSettingPage extends StatelessWidget {
  const CloudSettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppStatus status = context.select((AppBloc bloc) => bloc.state.status);
    Widget widget = status == AppStatus.authenticated
        ? const CloudSwitchPage()
        : BlocProvider(
            create: (context) =>
                LoginCubit(context.read<AuthenticationRepository>()),
            child: BlocListener<LoginCubit, LoginState>(
              listener: (context, state) {
                if (state.status == LoginStatus.failure) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                            state.errorMessage ?? 'Authentication Failure'),
                      ),
                    );
                }
              },
              child: BlocBuilder<LoginCubit, LoginState>(
                builder: (context, state) {
                  return Scaffold(
                    body: Center(
                      child: state.status == LoginStatus.inProgress
                          ? const CircularProgressIndicator()
                          : IconButton(
                              onPressed: () {
                                context.read<LoginCubit>().logInWithGoogle();
                              },
                              icon: const Icon(Icons.cloud),
                            ),
                    ),
                  );
                },
              ),
            ),
          );
    return widget;
  }
}
