part of 'splash_cubit.dart';

enum ResourceProcess {initial, processing}

class SplashState extends Equatable {
  const SplashState._({
    this.process = ResourceProcess.initial,
    this.percentage = "0",
  });

  const SplashState.initial() : this._();


  const SplashState.processing(String percentage) : this._(
      process: ResourceProcess.processing, percentage: percentage
  );

  final ResourceProcess process;
  final String percentage;

  @override
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();
}

