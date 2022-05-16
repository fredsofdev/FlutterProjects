import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DetailOfQNAScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const DetailOfQNAScreen({required this.data});

  @override
  _DetailOfQNAScreenState createState() => _DetailOfQNAScreenState();
}

class _DetailOfQNAScreenState extends State<DetailOfQNAScreen> {
  TextStyle titleStyle = const TextStyle(
      color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17);
  TextStyle contentStyle = const TextStyle(
      color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 14);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '내가 한 문의',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 15, right: 15, bottom: 4),
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              Text(
                widget.data['q_reg_date'].toString(),
                style: titleStyle.copyWith(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.normal),
              ),
              Text(
                widget.data['title'].toString(),
                style: titleStyle,
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                widget.data['question'].toString(),
                style: contentStyle,
              ),
              const SizedBox(
                height: 40,
              ),
              const Divider(),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  width: 90,
                  height: 24,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      color: Colors.black87),
                  child: const Center(
                      child: Text(
                    '운영자 답변',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ))),
              const SizedBox(
                height: 15,
              ),
              Text(
                widget.data['answer'].toString().isEmpty
                    ? '답변이 없습니다.'
                    : widget.data['answer'].toString(),
                style: contentStyle.copyWith(
                    color: widget.data['answer'].toString().isEmpty
                        ? Colors.grey.shade500
                        : Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
