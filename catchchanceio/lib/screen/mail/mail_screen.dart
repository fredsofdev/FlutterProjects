import 'dart:io';

import 'package:catchchanceio/constants/behavior.dart';
import 'package:catchchanceio/constants/color.dart';
import 'package:catchchanceio/repository/authentication/inventory_repository.dart';
import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:catchchanceio/widgets/appbars/screen_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/mail_cubit.dart';

class MailScreen extends StatelessWidget {
  final String myId;
  final bool isNotice;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return BlocProvider(
      create: (_) => MailCubit(InventoryRepository(), myId),
      child: _MailScreen(isNotice: isNotice),
    );
  }

  const MailScreen({required this.myId, required this.isNotice});
}

class _MailScreen extends StatefulWidget {
  final bool isNotice;

  const _MailScreen({required this.isNotice});

  @override
  _MailScreenState createState() => _MailScreenState();
}

class _MailScreenState extends State<_MailScreen> {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/mail/';
  String _selectedTab = 'gift';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isNotice) {
      _selectedTab = 'notice';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: FileImage(File('${_imagePath}bg.png')),
                fit: BoxFit.cover)),
        child: Column(
          children: [
            //todo appbar
            ScreenAppBar(
              buttons: [],
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
                child: Container(
              width: double.infinity,
              color: const Color(0xff2f294f),
              child: Column(
                children: [
                  HeaderNavInMail(
                    selectedTab: _selectedTab,
                    onChanged: (String tab) {
                      setState(() {
                        _selectedTab = tab;
                      });
                    },
                  ),
                  //todo gift page
                  Visibility(
                    visible: _selectedTab == 'gift',
                    child: Expanded(
                        child: Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 4),
                      width: sw,
                      child: ScrollConfiguration(
                        behavior: NoGlowScrollBehavior(),
                        child: SingleChildScrollView(
                          child: BlocBuilder<MailCubit, MailState>(
                              builder: (context, state) {
                            return Column(
                              children: state.mail
                                  .map(
                                    (e) => OneGiftListBox(
                                      title: e['title'].toString(),
                                      date: e['reg_date'].toString(),
                                      content: e['message'].toString(),
                                      howManyCoin: e.containsKey('coin') ? e['coin'] as int: 0,
                                      senderName: e['from_name'].toString(),
                                      productType: e['product_type'].toString(),
                                      profileImgUrl: e['from_url'].toString(),
                                      productId: e['product_id'].toString(),
                                      itemId: e['id'].toString(),
                                    ),
                                  )
                                  .toList(),
                            );
                          }),
                        ),
                      ),
                    )),
                  ),

                  //todo notice page
                  Visibility(
                    visible: _selectedTab == 'notice',
                    child: Expanded(
                        child: Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 4),
                      width: sw,
                      child: ScrollConfiguration(
                        behavior: NoGlowScrollBehavior(),
                        child: SingleChildScrollView(
                          child: BlocBuilder<MailCubit, MailState>(
                              builder: (context, state) {
                            return Column(
                              children: state.notice
                                  .map(
                                    (e) => OneNoticeListBox(
                                      title: e['title'].toString(),
                                      date: e['reg_date'].toString(),
                                      content: e['content'].toString(),
                                      id: e['id'].toString(),
                                    ),
                                  )
                                  .toList(),
                            );
                          }),
                        ),
                      ),
                    )),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class HeaderNavInMail extends StatefulWidget {
  final String selectedTab;
  final Function? onChanged;

  const HeaderNavInMail({required this.selectedTab, this.onChanged});

  @override
  _HeaderNavInMailState createState() => _HeaderNavInMailState();
}

class _HeaderNavInMailState extends State<HeaderNavInMail> {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/mail/';
  TextStyle ts = const TextStyle(
      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14);
  late String _selectedTab;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedTab = widget.selectedTab;
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return SizedBox(
      width: sw,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.file(
            File('${_imagePath}header_frame.png'),
            width: sw,
            fit: BoxFit.contain,
          ),
          Positioned(
              left: 0,
              child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTab = 'gift';
                    });
                    widget.onChanged!('gift');
                  },
                  child: Opacity(
                      opacity: _selectedTab == 'gift' ? 1.0 : 0.0,
                      child: Image.file(
                        File('${_imagePath}left_active.png'),
                        width: sw / 1.88,
                        fit: BoxFit.contain,
                      )))),
          Positioned(
              right: 0,
              child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTab = 'notice';
                    });
                    widget.onChanged!('notice');
                  },
                  child: Opacity(
                      opacity: _selectedTab == 'notice' ? 1.0 : 0.0,
                      child: Image.file(
                        File('${_imagePath}right_active.png'),
                        width: sw / 1.84,
                        fit: BoxFit.contain,
                      )))),
          Positioned(
              left: 20,
              child: IgnorePointer(
                  child: Text(
                '받은 선물',
                style: ts.copyWith(
                    color:
                        _selectedTab == 'gift' ? Colors.white : Colors.white54),
              ))),
          Positioned(
              right: 20,
              child: IgnorePointer(
                  child: Row(
                children: [
                  const Icon(
                    Icons.circle,
                    size: 10,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    '공지 사항',
                    style: ts.copyWith(
                        color: _selectedTab == 'notice'
                            ? Colors.white
                            : Colors.white54),
                  ),
                ],
              ))),
        ],
      ),
    );
  }
}

class OneNoticeListBox extends StatelessWidget {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/mail/';
  final TextStyle ts = const TextStyle(
      color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold);

  final String title;
  final String date;
  final String content;
  final String id;

  OneNoticeListBox({required this.content, required this.date, required this.title, required this.id});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        showDetailOfNotice(context, title: title, date: date, content: content);
      },
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        width: sw,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 12, right: 12),
              width: sw,
              height: 85,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xffae9dcc), Color(0xff2f294f)],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: sw - 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: ts,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          date,
                          style: ts.copyWith(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          height: 1,
                        ),
                        Text(
                          content,
                          style: ts.copyWith(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Image.file(
                    File('${_imagePath}arrow.png'),
                    width: 22,
                  )
                ],
              ),
            ),
            Container(
              width: sw,
              height: 5,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                colors: [
                  const Color(0xff605499),
                  const Color(0xff2f294f).withOpacity(0.0)
                ],
              )),
            )
          ],
        ),
      ),
    );
  }
}

class OneGiftListBox extends StatelessWidget {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/mail/';
  final TextStyle ts = const TextStyle(
      color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold);

  final String productType; //todo 'Item', 'Coupon', 'Coin'
  final String? productId;
  final String title;
  final String profileImgUrl;
  final String date;
  final String content;
  final int? howManyCoin;
  final String senderName;
  final String? itemId;
  final String? type;

  OneGiftListBox(
      {required this.title,
      required this.date,
      required this.content,
      this.howManyCoin,
      required this.senderName,
      required this.profileImgUrl,
      required this.productType,
      this.productId,
        this.type,
      this.itemId});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () async {
        //todo 일일 접속 보상 내용 상세 내용 showDialog 이용
        if (productType == 'Coin') {
          showDetailOfGift(context,
              productType: 'Coin',
              title: title,
              content: content,
              date: date,
              howManyCoin: howManyCoin!, accept: () {
            context.read<MailCubit>().acceptItem(itemId: itemId);
          });
        } else if (productType == 'Item') {
          final data =
              await context.read<MailCubit>().getItem(productId!, productType);
          showDetailOfGift(context,
              productType: data['type'].toString(),
              title: data['title'].toString(),
              content: data['f_desc'].toString(),
              date: date,
              imgUrl: data['img_url'].toString(), accept: () {
            context.read<MailCubit>().acceptItem(datas: data, itemId: itemId);
          });
        } else if (productType == 'Coupon') {
          final data =
              await context.read<MailCubit>().getItem(productId!, productType);
          showDetailOfGift(context,
              productType: data['type'].toString(),
              title: data['title'].toString(),
              content: data['f_desc'].toString(),
              date: date,
              imgUrl: data['img_url_b'].toString(), accept: () {
            context.read<MailCubit>().acceptItem(datas: data, itemId: itemId);
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        width: sw,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 12, right: 12),
              width: sw,
              height: 85,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xffae9dcc), Color(0xff2f294f)],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      child: productType == "Item"? Image.file(
                                        File('${AppConfig.appDocDirectory!.path}/osgame/logo/app_logo.png'),
                                        width: 20,
                                        height: 20,
                                        fit: BoxFit.cover,
                                        )   : Image.network(
                                        profileImgUrl ,
                                            //'https://picsum.photos/250?image=9',
                                        width: 20,
                                        height: 20,
                                        fit: BoxFit.cover,
                                      )),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    senderName,
                                    style: ts,
                                  ),
                                ],
                              ),
                              Text(date,
                                  style: ts
                                      .copyWith(color: Colors.white70)
                                      .copyWith(fontSize: 11)),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            title,
                            style: ts,
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(content, style: ts.copyWith(fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  Image.file(
                    File('${_imagePath}arrow.png'),
                    width: 22,
                  )
                ],
              ),
            ),
            Container(
              width: sw,
              height: 5,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                colors: [
                  const Color(0xff605499),
                  const Color(0xff2f294f).withOpacity(0.0)
                ],
              )),
            )
          ],
        ),
      ),
    );
  }
}

void showDetailOfNotice(BuildContext context,
    {required String title, required String date, required String content}) {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/mail/';
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Center(
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: 280,
                height: 460,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Image.file(
                              File('${_imagePath}btn_close.png'),
                              width: 30,
                            ))
                      ],
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Expanded(
                        child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 15),
                      width: double.infinity,
                      height: 460,
                      decoration: BoxDecoration(
                          color: const Color(0xff9c83aa).withOpacity(0.4),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.4), width: 4)),
                      child: Column(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 8),
                            width: double.infinity,
                            height: 330,
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 1.1,
                                  ),
                                  bottom: BorderSide(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 1.1,
                                  ),
                                )),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    content,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ))
                  ],
                ),
              ),
            ),
          ));
}

Future<void> showDetailOfGift(
  BuildContext context, {
  required String productType,
  required String title,
  required String date,
  required String content,
   int? howManyCoin,
   String? imgUrl,
   String? itemId,
  required Function accept,
}) async {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/mail/';
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 260,
                height: 390,
                color: Colors.transparent,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Image.file(
                              File('${_imagePath}btn_close.png'),
                              width: 30,
                            ))
                      ],
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Container(
                      width: double.infinity,
                      height: 350,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          color: const Color(0xff9c83aa).withOpacity(0.4),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.4), width: 4)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 19),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          Text(
                            date,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                          Text(
                            content,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            width: 106,
                            height: 106,
                            child: productType == 'coin'
                                ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.file(
                                        File('${_imagePath}item_frame.png'),
                                        width: 90,
                                      ),
                                      Image.file(
                                        File(
                                            '${AppConfig.appDocDirectory!.path}/osgame/icons/coin.png'),
                                        width: 60,
                                      ),
                                      Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Text(
                                            'x $howManyCoin',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ))
                                    ],
                                  )
                                : Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.network(
                                        imgUrl!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )
                                    ],
                                  ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          SizedBox(
                            width: 115,
                            height: 46,
                            child: RaisedButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                accept();
                                Navigator.pop(context);
                              },
                              color: appMainColor,
                              child: const Text(
                                '수령하기',
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ));
}
