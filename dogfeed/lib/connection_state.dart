part of 'connection_cubit.dart';

class ConnectionsState extends Equatable {

  const ConnectionsState({
    this.defaultAmount = 100,
    this.weight = 0.0,
    this.foodTime = 120,
    this.reserves = const {},
    this.isLoggedIn = AuthState.unknown,
    this.weightList = const []
  });

    final int defaultAmount;
    final double weight;
    final int foodTime;
    final Map<String,int> reserves;
    final AuthState isLoggedIn;
    final List weightList;

  double calculateWeight( double weight){
    print(weight);
    final freeWeight = weight - 3500;
    var accurateWeight = freeWeight / 21700;
    if(accurateWeight < 0.0){
      accurateWeight = 0.0;
    }
    return roundDouble(accurateWeight, 1);
  }
  double roundDouble(double value, int places){
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  @override
  List<Object> get props => [defaultAmount, weight, foodTime, reserves, isLoggedIn, weightList];

  ConnectionsState copyWith({
    int? defaultAmount,
    double? weight,
    int? foodTime,
    Map<String, int>? reserves,
    AuthState? isLoggedIn,
    List? weightList,
  }){
    return ConnectionsState(
      defaultAmount: defaultAmount?? this.defaultAmount,
      weight: weight!= null? calculateWeight(weight): this.weight,
      foodTime: foodTime?? this.foodTime,
      reserves: reserves ?? this.reserves,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      weightList: weightList ?? this.weightList
    );
  }
}


enum AuthState{ unknown, login, logout}