part of 'cloud_switch_cubit.dart';

enum CloudSwitchStatus {
  on,
  off,
}

class CloudSwitchState extends Equatable {
  const CloudSwitchState({
    this.status = CloudSwitchStatus.off,
  });

  final CloudSwitchStatus status;

  @override
  List get props => [status];
}
