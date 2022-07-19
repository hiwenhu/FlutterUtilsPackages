import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'cloud_switch_state.dart';

class CloudSwitchCubit extends Cubit<CloudSwitchState> {
  static const String key = 'CloudSwitch';
  CloudSwitchCubit({required CloudSwitchStatus status})
      : super(CloudSwitchState(status: status));

  Future<void> switchOn() {
    return _switchCloud(CloudSwitchStatus.on);
  }

  Future<void> switchOff() {
    return _switchCloud(CloudSwitchStatus.off);
  }

  Future<void> _switchCloud(CloudSwitchStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, CloudSwitchStatus.values.indexOf(status));
    emit(CloudSwitchState(status: status));
  }

  static Future<CloudSwitchStatus> getSwitch() async {
    final prefs = await SharedPreferences.getInstance();
    return CloudSwitchStatus.values[(prefs.getInt(key) ?? 0)];
  }
}
