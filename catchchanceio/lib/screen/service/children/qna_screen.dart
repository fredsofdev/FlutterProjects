import 'package:catchchanceio/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:catchchanceio/constants/behavior.dart';
import 'package:catchchanceio/constants/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';

import 'detail_of_qna_screen.dart';

class QNAScreen extends StatefulWidget {
  @override
  _QNAScreenState createState() => _QNAScreenState();
}

class _QNAScreenState extends State<QNAScreen> {
  @override
  void initState() {
    context.read<AuthenticationBloc>().add(GetQNA());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '1:1 문의하기',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        padding:
            const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            Row(
              children: const [
                Text('내가 한 문의',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, state) {
                return Expanded(
                    child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ScrollConfiguration(
                    behavior: NoGlowScrollBehavior(),
                    child: SingleChildScrollView(
                      child: Column(
                        children: state.qna
                            .map(
                              (e) => OneQNAList(
                                data: e,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ));
              },
            ),
            SizedBox(
              width: 115,
              height: 38,
              child: RaisedButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  _showQNAForm1(
                      context: context,
                      submit: (String title, String question) {
                        if (title.toString().isNotEmpty &&
                            question.toString().isNotEmpty) {
                          context
                              .read<AuthenticationBloc>()
                              .add(PostQNA(title, question));
                        }
                      });
                },
                color: appMainColor,
                child: const Text(
                  '문의하기',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
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

Future<void> _showQNAForm1({required BuildContext context, required Function submit}) {
  String title = "";
  String question = "";

  return showDialog(
      context: context,
      builder: (BuildContext contex) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: MediaQuery.of(context).viewInsets,
                  padding: const EdgeInsets.all(14),
                  width: 270,
                  height: 500,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                '1:1 문의하기',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          const Text(
                            '제목',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          MyTextField1(
                            width: double.infinity,
                            maxLines: 1,
                            hintText: '제목',
                            onChange: (String val) {
                              title = val;
                            },
                          ),
                          const SizedBox(
                            height: 26,
                          ),
                          const Text(
                            '질문 내용',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          MyTextField1(
                            width: double.infinity,
                            maxLines: 10,
                            hintText: '질문 내용',
                            onChange: (String val) {
                              question = val;
                            },
                          ),
                        ],
                      ),
                      Align(
                        child: SizedBox(
                          width: 90,
                          height: 32,
                          child: RaisedButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              //todo write form,
                              if (title.isNotEmpty && question.isNotEmpty) {
                                submit(title, question);
                              }
                              Navigator.pop(context);
                            },
                            color: appMainColor,
                            child: const Text(
                              '작성하기',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      });
}

class MyTextField1 extends StatelessWidget {
  final double width;
  final int maxLines;
  final String hintText;
  final Function onChange;

  const MyTextField1({required this.hintText, required this.maxLines, required this.width, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      width: width,
      decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: const BorderRadius.all(Radius.circular(8))),
      child: Center(
        child: TextField(
          onChanged: (val) {
            onChange(val);
          },
          style: const TextStyle(color: Colors.black, fontSize: 15),
          cursorColor: Colors.black,
          maxLines: maxLines,
          decoration: InputDecoration(
              isDense: true,
              fillColor: Colors.grey.shade200,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              hintText: hintText),
        ),
      ),
    );
  }
}

class OneQNAList extends StatelessWidget {
  final Map<String, dynamic> data;

  const OneQNAList({required this.data});

  TextStyle get titleStyle => const TextStyle(
      color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16);

  TextStyle get contentStyle => const TextStyle(
      color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 14);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.fade,
                child: DetailOfQNAScreen(data: data)));
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(width: 2, color: Colors.grey.shade100))),
        width: double.infinity,
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(
                  data['title'].toString(),
                  style: titleStyle,
                  overflow: TextOverflow.ellipsis,
                )),
                Text(
                  data['q_reg_date'].toString(),
                  style: titleStyle.copyWith(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(
              height: 6,
            ),
            Text(data['question'].toString(),
                style: contentStyle, overflow: TextOverflow.ellipsis)
          ],
        ),
      ),
    );
  }
}
