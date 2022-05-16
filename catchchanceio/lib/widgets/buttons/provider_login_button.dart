import 'package:flutter/material.dart';

class ProviderLoginButton extends StatefulWidget {
  final String loginProvider;
  final Function onTap;

  const ProviderLoginButton({required this.loginProvider, required this.onTap});

  @override
  _ProviderLoginButtonState createState() => _ProviderLoginButtonState();
}

class _ProviderLoginButtonState extends State<ProviderLoginButton> {
  late Color btnColor;
  late String btnText;
  Color textColor = Colors.white;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.loginProvider == 'google') {
      btnColor = const Color(0xfffafafa);
      textColor = Colors.black54;
      btnText = '구글 계정으로 로그인';
    } else if (widget.loginProvider == 'facebook') {
      btnColor = const Color(0xff39569a);
      btnText = '페이스북 계정으로 로그인';
    } else if (widget.loginProvider == 'kakao') {
      btnColor = const Color(0xfffeea01);
      textColor = const Color(0xff3b1d1d);
      btnText = '카카오 계정으로 로그인';
    } else if (widget.loginProvider == 'line') {
      btnColor = const Color(0xff22ba4f);
      btnText = '라인 계정으로 로그인';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      color: btnColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          widget.onTap();
        },
        child: Container(
          width: 280,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 26),
          child: Center(
              child: Row(
            children: <Widget>[
              Image.asset(
                'assets/images/login/${widget.loginProvider}-letter.png',
                width: 26,
              ),
              const SizedBox(
                width: 20,
              ),
              Text(
                btnText,
                style: TextStyle(
                    color: textColor,
                    fontSize: 14.6,
                    fontWeight: FontWeight.bold),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
