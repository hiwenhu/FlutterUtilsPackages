import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testimage/cloud/switch/cubit/cloud_switch_cubit.dart';

class CloudWrapper extends StatelessWidget {
  const CloudWrapper({Key? key, this.child}) : super(key: key);

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CloudSwitchCubit, CloudSwitchState>(
      builder: (context, state) {
        var c = child ?? const SizedBox.shrink();
        return state.status == CloudSwitchStatus.off
            ? c
            : Badge(
                badgeContent: const Icon(Icons.cloud_upload),
                child: c,
              );
      },
    );
  }
}
