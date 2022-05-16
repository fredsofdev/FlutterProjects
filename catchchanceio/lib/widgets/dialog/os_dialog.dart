import 'package:catchchanceio/constants/color.dart';
import 'package:flutter/material.dart';

void showCustomDialog(
    {required BuildContext context,
    required String contentText,
    required String confirmText,
    required String rejectText,
    required Function onConfirm,
     Function? onReject}) {
  showDialog(
      context: context,
      builder: (_) => Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                width: 260,
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Text(
                        contentText,
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 70,
                            height: 30,
                            child: RaisedButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                Navigator.pop(context);
                                onConfirm();
                              },
                              color: appMainColor,
                              child: Text(
                                confirmText,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          SizedBox(
                            width: 70,
                            height: 30,
                            child: RaisedButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                if (onReject != null) {
                                  onReject();
                                }
                                Navigator.pop(context);
                              },
                              color: Colors.grey.shade400,
                              child: Text(
                                rejectText,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ));
}
