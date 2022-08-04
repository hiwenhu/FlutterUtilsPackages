import 'package:authentication_repository/authentication_repository.dart';
import 'package:datetime_withseconds_picker/datetime_withseconds_picker.dart';
import 'package:file_cloud_repository/file_cloud_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:sqlparser/sqlparser.dart' hide Column;
import 'package:testimage/app/bloc/app_bloc.dart';
import 'package:testimage/cloud/switch/cubit/cloud_switch_cubit.dart';
import 'package:testimage/files_overview/bloc/files_overview_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:testimage/files_overview/view/files_overview_page.dart';
import 'package:testimage/resultsets_overview/bloc/result_set_viewer_bloc.dart';
import 'package:testimage/resultsets_overview/view/result_sets_overview.dart';

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
    return const MaterialApp(
      // theme: theme,
      // home: FlowBuilder<AppStatus>(
      //   state: context.select((AppBloc bloc) => bloc.state.status),
      //   onGeneratePages: onGenerateAppViewPages,
      // ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: Locale.fromSubtags(
          languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'),
      supportedLocales: [
        Locale('en', ''), // English, no country code
        Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hans',
            countryCode: 'CN'), // 'zh_Hans_CN'
      ],
      home: FilesOverviewPage(),
      //TestShowTimePicker(),
      // TestSqlparser(),
      //TestResultSetsOverview()
    );
  }
}

class TestResultSetsOverview extends StatelessWidget {
  const TestResultSetsOverview({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResultSetsOverView(
      rsvs: [
        ResultSetViewer(id: 1),
        ResultSetViewer(id: 2),
        ResultSetViewer(id: 3),
      ],
    );
  }
}

class TestSqlparser extends StatefulWidget {
  const TestSqlparser({Key? key}) : super(key: key);

  @override
  State<TestSqlparser> createState() => _TestSqlparserState();
}

class _TestSqlparserState extends State<TestSqlparser> {
  final textEditingCtrl = TextEditingController();
  final parsedEditingCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test SqlParsert'),
      ),
      body: SafeArea(
          child: Column(
        children: [
          TextField(
            controller: textEditingCtrl,
          ),
          TextField(
            controller: parsedEditingCtrl,
            maxLines: 5,
          ),
          ElevatedButton(
            onPressed: () {
              String str = String.fromCharCode(92);
              final tokens = Scanner(textEditingCtrl.text).scanTokens();

              int startIdx = 0;
              int semicolonIdx = tokens
                  .indexWhere((element) => element.type == TokenType.semicolon);
              List<List<Token>> tokenChunks = [];
              while (semicolonIdx != -1) {
                tokenChunks.add(tokens.sublist(startIdx, semicolonIdx));
                startIdx = semicolonIdx + 1;
                semicolonIdx = tokens.indexWhere(
                    (element) => element.type == TokenType.semicolon, startIdx);
              }

              List<String> results = [];
              for (final chunk in tokenChunks) {
                results.add(chunk.map((e) => e.lexeme).join(' '));
              }
              parsedEditingCtrl.text = results.join('\n');
            },
            child: const Text('Parse'),
          ),
        ],
      )),
    );
  }
}

class TestShowTimePicker extends StatefulWidget {
  const TestShowTimePicker({Key? key}) : super(key: key);

  @override
  State<TestShowTimePicker> createState() => _TestShowTimePickerState();
}

class _TestShowTimePickerState extends State<TestShowTimePicker> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Cloud Sync'),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  TextButton(
                    onPressed: () => throw Exception(),
                    child: const Text("Throw Test Exception"),
                  ),
                  FormBuilderDateTimeWithSecondsPicker(
                    name: 'timepicker',
                    resetIcon: IconButton(
                      onPressed: () {
                        _formKey.currentState?.fields['timepicker']
                            ?.didChange(null);
                      },
                      icon: const Icon(Icons.close),
                    ),
                    onChanged: (value) => print(value.toString()),
                  ),
                ],
              )),
          // child: ElevatedButton(
          //   child: const Text('show time picker with seconds'),
          //   onPressed: () => showTimeWithSecPicker(
          //           context: context,
          //           initialTime: TimeOfDayWithSec.now(),
          //           secondLabelText: 'Second')
          //       .then(
          //     (value) => print(value.toString()),
          //   ),
          // ),
        ),
      ),
    );
  }
}
