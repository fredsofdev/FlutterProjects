
import 'dart:math';
import 'dart:ui';

import 'package:dogfeed/connection_cubit.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart';

class Control extends HookWidget {
  const Control({Key? key}) : super(key: key);

  static Route route() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Color.fromRGBO(123, 173, 95, 1),
        systemNavigationBarColor: Color.fromRGBO(123, 173, 95, 1)
    ));
    return MaterialPageRoute<void>(builder: (_) => const Control());
  }

  @override
  Widget build(BuildContext context) {

    final ws = MediaQuery.of(context).size.width;
    final hs = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: hs * 0.06,
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                children: [
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        'assets/3_first_name.png',
                        width:  ws * 0.27,

                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  Flexible(
                    flex: 5,
                    child: SizedBox(
                      width: ws * 0.6,
                    ),
                  ),

                  Flexible(
                    flex: 1,
                    child: Material(
                      elevation: 0.0,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      color: Colors.transparent,
                      child: Ink.image(
                        image: const AssetImage('assets/3_logout.png'),
                        fit: BoxFit.cover,
                        width: ws * 0.1,
                        height: ws * 0.1,
                        child: InkWell(
                          onTap: () {
                            context.read<ConnectionCubit>().logout();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            HookBuilder(
              builder: (context) {

                final bloc = useBloc<ConnectionCubit,ConnectionsState>
                  ( onEmitted: (_,p,c)=>p.defaultAmount!=c.defaultAmount||
                    p.weight!=c.weight||p.foodTime!=c.foodTime||p.weightList!=c.weightList).state;


                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Material(
                            elevation: 0.0,
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                            clipBehavior: Clip.antiAlias,
                            color: Colors.transparent,
                            child: Ink.image(
                              image: const AssetImage('assets/3_weight_btn.png'),
                              fit: BoxFit.cover,
                              width: ws * 0.27,
                              height: ws * 0.27,
                              child: InkWell(
                                onTap: () {
                                  context.read<ConnectionCubit>().getWeights();
                                  _showWeightList(context,bloc.weightList);
                                },
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                "${bloc.weight} kg",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                            )
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Material(
                            elevation: 0.0,
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                            clipBehavior: Clip.antiAlias,
                            color: Colors.transparent,
                            child: Ink.image(
                              image: const AssetImage('assets/3_food_btn.png'),
                              fit: BoxFit.cover,
                              width: ws * 0.27,
                              height: ws * 0.27,
                              child: InkWell(
                                onTap: () {
                                  _selectAmount(context,(bloc.defaultAmount~/100)*30);
                                },
                              ),
                            ),
                          ),
                          Center(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  "${(bloc.defaultAmount~/100)*30}g",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    // color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Material(
                            elevation: 0.0,
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                            clipBehavior: Clip.antiAlias,
                            color: Colors.transparent,
                            child: Ink.image(
                              image: const AssetImage('assets/3_time_btn.png'),
                              fit: BoxFit.cover,
                              width: ws * 0.27,
                              height: ws * 0.27,
                              child: InkWell(
                                onTap: () {
                                  _selectFoodTime(context,bloc.foodTime ~/60);
                                },
                              ),
                            ),
                          ),
                          Center(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  "${bloc.foodTime ~/60}분",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    // color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                              )
                          ),
                        ],
                      ),
                    ),

                  ],
                );
              }
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15.0,30.0,15.0,15.0),
              child: Image.asset(
                'assets/3_line.png',
                width:  ws,

                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                children: [
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        'assets/3_second_name.png',
                        width:  ws * 0.27,

                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  Flexible(
                    flex: 5,
                    child: SizedBox(
                      width: ws * 0.6,
                    ),
                  ),

                  Flexible(
                    flex: 1,
                    child: Material(
                      elevation: 0.0,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      color: Colors.transparent,
                      child: Ink.image(
                        image: const AssetImage('assets/3_addition.png'),
                        fit: BoxFit.cover,
                        width: ws * 0.1,
                        height: ws * 0.1,
                        child: InkWell(
                          onTap: () {
                            _selectDate(context);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Image.asset(
                        'assets/3_list_bg.png',
                        width:  ws,
                        height: hs,
                        fit: BoxFit.fill,
                      ),
                    ),

                    Column(
                      children: [
                        const SizedBox(height: 15,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Padding(
                              padding: EdgeInsets.fromLTRB(15.0,15.0,15.0,0.0),
                              child: Text(
                                "날짜 시간",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(123, 173, 95, 1)
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(15.0,15.0,15.0,0.0),
                              child: Text(
                                "사료양",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(123, 173, 95, 1)
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(15.0,15.0,15.0,0.0),
                              child: Text(
                                "먹는시간",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(123, 173, 95, 1)
                                ),
                              ),
                            ),
                            SizedBox(width: 50,)
                          ],
                        ),
                        Flexible(
                          child: HookBuilder(
                              builder: (context) {
                                final bloc = useBloc<ConnectionCubit,ConnectionsState>
                                  ( onEmitted: (_,p,c)=>p.reserves!=c.reserves);
                                var list = [];
                                bloc.state.reserves.forEach((key, value) {list.add({key: value});});
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(15.0,0.0,15.0,0.0),
                                  child: SizedBox(
                                    height: hs * 0.29,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: list.map(
                                                (value) => ReservePad(
                                              data: Map<String,int>.from(value),
                                            )).toList(),
                                      ),
                                    ),
                                  ),
                                );
                              }
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              width: ws,
              child: Row(
                children: [
                  Image.asset(
                    'assets/3_left_side_dog_ani.gif',
                    width:  ws*0.25,

                    fit: BoxFit.cover,
                  ),
                  SizedBox(
                    width: ws *0.145,
                  ),
                  Material(
                    elevation: 2.0,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    color: Colors.transparent,
                    child: Ink.image(
                      image: const AssetImage('assets/3_skip.png'),
                      fit: BoxFit.cover,
                      width: ws * 0.22,
                      height: ws * 0.22,
                      child: InkWell(
                        onTap: () {
                          context.read<ConnectionCubit>().giveFood();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    if(selected == null) return;
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute + 1),
      initialEntryMode: TimePickerEntryMode.input,
    );
    final timestamp = (selected.millisecondsSinceEpoch ~/ 1000) +
        (newTime!.hour * 3600) + (newTime.minute * 60);
    context.read<ConnectionCubit>().addReserves(timestamp);

  }

  _selectAmount(BuildContext context, int num) async {
    final selnum = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return  Center(
          child: NumberPickerFrom(min: 30, max: 120, initialVal: num, step: 30)
        );
      },
    );

    if(selnum != null){
      final thirtys = selnum~/30;

      context.read<ConnectionCubit>().updateVal({"defaultAmount": thirtys * 100});
    }
  }

  _selectFoodTime(BuildContext context, int num) async {
    final int? selnum = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return Center(
            child: NumberPickerFrom(min: 1, max: 6, initialVal: num, step: 1)
        );
      },
    );

    if(selnum != null){
      context.read<ConnectionCubit>().updateVal({"foodTime": (selnum * 60)});
    }
  }

  _showWeightList(BuildContext context, List list) async {
    var reversedList = List.from(list.reversed);
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return Center(
            child: WeightsDialog(listWeight: reversedList)
        );
      },
    );
  }

}

class ReservePad extends HookWidget {
  const ReservePad({Key? key, required this.data}) : super(key: key);

  final Map<String,int> data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 320,
      child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(data.keys.toList()[0]) * 1000).toString().substring(5, 16),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  "${data.values.toList()[0]}g",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              const SizedBox(width: 15,),
              HookBuilder(
                builder: (context) {
                  final bloc = useBloc<ConnectionCubit,ConnectionsState>(onEmitted: (_,p,c)=>p.foodTime!=c.foodTime).state;
                  return Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      "${bloc.foodTime~/60}분",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  );
                }
              ),
              const SizedBox(width: 2,),
              IconButton(
                // padding: const EdgeInsets.all(0.0),
                splashRadius: 40,
                onPressed:(){
                  context.read<ConnectionCubit>().removeReserves(int.parse(data.keys.toList()[0]));
                },
                icon: const Icon(Icons.cancel)
              )
            ],
          )
      ),
    );
  }




}


class NumberPickerFrom extends HookWidget {
  const NumberPickerFrom({Key? key,
    required this.initialVal,
    required this.min,
    required this.max,
    required this.step,}) : super(key: key);

  final int initialVal;
  final int min;
  final int max;
  final int step;

  @override
  Widget build(BuildContext context) {

    final currentVal = useState(initialVal);

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white
      ),
      child: Column(
        children: <Widget>[
          NumberPicker(
            textStyle: const TextStyle(color: Colors.green),
            selectedTextStyle: const TextStyle(color: Colors.orange, fontSize: 25),
            value: currentVal.value,
            minValue: min,
            maxValue: max,
            step: step,
            onChanged: (value) => currentVal.value = value,
          ),
          ElevatedButton(
              onPressed: (){
                Navigator.pop(context, currentVal.value);
              },
              child: const Text('Edit'))
        ],
      ),
    );
  }
}


class WeightsDialog extends HookWidget {
  const WeightsDialog({Key? key, required this.listWeight }) : super(key: key);

  final List listWeight;
  @override
  Widget build(BuildContext context) {

    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white
      ),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Image.asset(
              'assets/3_list_bg.png',
              width:  MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fill,
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Padding(
                    padding: EdgeInsets.fromLTRB(50.0,25.0,25.0,0.0),
                    child: Text(
                      "날짜 시간",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(123, 173, 95, 1),
                          fontSize: 20
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.0,25.0,15.0,0.0),
                    child: Text(
                      "몸무게",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(123, 173, 95, 1),
                          fontSize: 20
                      ),
                    ),
                  ),
                  SizedBox(width: 30,)
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0,25.0,15.0,0.0),
                child: SizedBox(
                  height: 290,
                  child: SingleChildScrollView(
                    child: Column(

                      children: listWeight.map(
                              (value) => WeightPad(
                            data: Map<String,double>.from(value),
                          )).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),


        ],
      ),
    );
  }
}

class WeightPad extends HookWidget {
  const WeightPad({Key? key, required this.data}) : super(key: key);

  final Map<String,double> data;

  double calculateWeight( double weight){
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
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 320,
      child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  DateTime.fromMillisecondsSinceEpoch(
                      int.parse(data.keys.toList()[0]) * 1000).toString().substring(0, 16),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  "${calculateWeight(data.values.toList()[0])}kg",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }




}