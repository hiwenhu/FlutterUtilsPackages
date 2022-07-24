import 'package:authentication_repository/authentication_repository.dart';
import 'package:datetime_withseconds_picker/datetime_withseconds_picker.dart';
import 'package:file_cloud_repository/file_cloud_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testimage/app/bloc/app_bloc.dart';
import 'package:testimage/cloud/switch/cubit/cloud_switch_cubit.dart';
import 'package:testimage/files_overview/bloc/files_overview_bloc.dart';
import 'package:testimage/files_overview/view/files_overview_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class App<FC extends FileCloudRepository> extends StatelessWidget {
  const App({
    Key? key,
    required AuthenticationRepository authenticationRepository,
    required FC fileCloudReposity,
    CloudSwitchStatus cloudSwitchStatus = CloudSwitchStatus.off,
  })  : _authenticationRepository = authenticationRepository,
        _fileCloudReposity = fileCloudReposity,
        _cloudSwitchStatus = cloudSwitchStatus,
        super(key: key);

  final AuthenticationRepository _authenticationRepository;
  final FC _fileCloudReposity;
  final CloudSwitchStatus _cloudSwitchStatus;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(
          value: _authenticationRepository,
        ),
        RepositoryProvider.value(
          value: _fileCloudReposity,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AppBloc>(
            create: (_) => AppBloc(
              authenticationRepository: _authenticationRepository,
            ),
          ),
          BlocProvider<CloudSwitchCubit>(
            create: (_) => CloudSwitchCubit(
                fileCloudRepository: _fileCloudReposity,
                status: _cloudSwitchStatus),
          ),
          BlocProvider<FilesOverviewBloc>(
              create: (context) => FilesOverviewBloc(
                    fileCloudRepository: _fileCloudReposity,
                  )..add(const FilesOverviewSubscriptionRequested())),
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
      ],
      home: const FilesOverviewPage(),
          //const TestShowTimePicker(),
    );
  }
}

class TestShowTimePicker extends StatelessWidget {
  const TestShowTimePicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Cloud Sync'),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            child: const Text('show time picker with seconds'),
            onPressed: () => showTimeWithSecPicker(
                    context: context,
                    initialTime: TimeOfDayWithSec.now(),
                    secondLabelText: 'Second')
                .then(
              (value) => print(value.toString()),
            ),
          ),
        ),
      ),
    );
  }
}
