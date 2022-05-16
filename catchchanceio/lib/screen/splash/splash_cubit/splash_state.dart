part of 'splash_cubit.dart';

enum ResourceProcess { initial, processing, done }

class SplashState extends Equatable {
  const SplashState(
      {this.process = ResourceProcess.initial,
      this.percentage = "0",
      this.status = ResourcesStatus.initial});

  final ResourceProcess process;
  final String percentage;
  final ResourcesStatus status;

  @override
  // TODO: implement props
  List<Object> get props => [process, percentage, status];

  SplashState updateState(
      {ResourceProcess? process, String? percentage, ResourcesStatus? status}) {
    return SplashState(
        process: process ?? this.process,
        percentage: percentage ?? this.percentage,
        status: status ?? this.status);
  }
}
