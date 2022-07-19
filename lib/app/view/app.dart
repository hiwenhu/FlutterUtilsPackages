import 'package:authentication_repository/authentication_repository.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:testimage/app/bloc/app_bloc.dart';
import 'package:testimage/cloud/switch/cubit/cloud_switch_cubit.dart';
import 'package:testimage/cloud/view/cloud_settings_page.dart';
import 'package:testimage/cloud/view/cloud_wrapper.dart';
import 'package:testimage/login/cubit/login_cubit.dart';

class App extends StatelessWidget {
  const App({
    Key? key,
    required AuthenticationRepository authenticationRepository,
    CloudSwitchStatus cloudSwitchStatus = CloudSwitchStatus.off,
  })  : _authenticationRepository = authenticationRepository,
        _cloudSwitchStatus = cloudSwitchStatus,
        super(key: key);

  final AuthenticationRepository _authenticationRepository;
  final CloudSwitchStatus _cloudSwitchStatus;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _authenticationRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AppBloc>(
            create: (_) => AppBloc(
              authenticationRepository: _authenticationRepository,
            ),
          ),
          BlocProvider<CloudSwitchCubit>(
            create: (_) => CloudSwitchCubit(status: _cloudSwitchStatus),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // theme: theme,
      // home: FlowBuilder<AppStatus>(
      //   state: context.select((AppBloc bloc) => bloc.state.status),
      //   onGeneratePages: onGenerateAppViewPages,
      // ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Test Cloud Sync'),
        ),
        body: SafeArea(
          child: Align(
            alignment: Alignment.center,
            child: Column(
              children: const [
                CloudWrapper(child: Text('data')),
                CloudSettingPage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}