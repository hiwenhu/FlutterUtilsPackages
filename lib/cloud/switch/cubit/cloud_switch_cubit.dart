import 'package:equatable/equatable.dart';
import 'package:file_cloud_repository/file_cloud_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'cloud_switch_state.dart';

class CloudSwitchCubit<FC extends FileCloudRepository>
    extends Cubit<CloudSwitchState> {
  static const String key = 'CloudSwitch';
  CloudSwitchCubit({
    required CloudSwitchStatus status,
    required this.fileCloudRepository,
  }) : super(CloudSwitchState(status: status));

  final FC fileCloudRepository;

  Future<void> switchOn() {
    return _switchCloud(CloudSwitchStatus.on);
  }

  Future<void> switchOff() {
    return _switchCloud(CloudSwitchStatus.off);
  }

  Future<void> _switchCloud(CloudSwitchStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, CloudSwitchStatus.values.indexOf(status));
    fileCloudRepository.useCloud = status == CloudSwitchStatus.on;
    emit(CloudSwitchState(status: status));
  }

  static Future<CloudSwitchStatus> getSwitch() async {
    final prefs = await SharedPreferences.getInstance();
    return CloudSwitchStatus.values[(prefs.getInt(key) ?? 0)];
  }
}
