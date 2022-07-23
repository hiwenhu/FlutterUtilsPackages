import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/widgets.dart';
import 'package:testimage/app/bloc/app_bloc.dart';
import 'package:testimage/cloud/switch/cubit/cloud_switch_cubit.dart';
import 'package:testimage/files_overview/bloc/files_overview_bloc.dart';

class CloudSwitchPage extends StatelessWidget {
  const CloudSwitchPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    final useCloud =
        context.select((CloudSwitchCubit cubit) => cubit.state.status);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Column(children: [
        if (user != null)
          ListTile(
            leading: GoogleUserCircleAvatar(identity: user),
            title: Text(user.email),
            trailing: IconButton(
              key: const Key('homePage_logout_iconButton'),
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          content: const Text("Are you sure to quit"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                context
                                    .read<AppBloc>()
                                    .add(AppLogoutRequested());
                                context.read<CloudSwitchCubit>().switchOff();
                                Navigator.pop(context);
                              },
                              child: const Text("OK"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                          ],
                        ));
              },
            ),
          ),
        SwitchListTile.adaptive(
            title: const Text('Using Cloud Sync'),
            subtitle:
                const Text('Sync your connections and scripts with Cloud'),
            value: useCloud == CloudSwitchStatus.on,
            onChanged: (value) {
              if (value) {
                context.read<CloudSwitchCubit>().switchOn();
                context
                    .read<FilesOverviewBloc>()
                    .add(const FilesOverviewLoadFromCloud());
              } else {
                context.read<CloudSwitchCubit>().switchOff();
              }
            }),
      ]),
    );
  }
}
