import 'package:catchchanceio/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WithdrawalScreen extends StatefulWidget {
  @override
  _WithdrawalScreenState createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  late String text;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '회원 탈퇴',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '회원탈퇴를 하시겠습니까?',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const Text('회원 정보 및 모든 데이터가 삭제됩니다.'),
            const SizedBox(
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              width: sw * 0.7,
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
              child: Center(
                child: TextField(
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                  onChanged: (val) {
                    text = val;
                  },
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                      isDense: true,
                      fillColor: Colors.grey.shade200,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: "'회원탈퇴' 를 입력하세요.",
                      hintStyle: const TextStyle(color: Colors.redAccent)),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 120,
              height: 38,
              child: RaisedButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  //todo withdrawal user
                  if (text == "회원탈퇴") {
                    context
                        .read<AuthenticationBloc>()
                        .add(AuthenticationDelete());
                  }

                  Navigator.of(context).pop();
                },
                color: Colors.redAccent,
                child: const Text(
                  '회원 탈퇴하기',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
