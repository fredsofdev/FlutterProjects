import 'package:formz/formz.dart';

enum NickNameValidation { empty, exist, valid, notmatch, more, less }

class NickName extends FormzInput<String, NickNameValidation> {
  const NickName.pure() : super.pure('');

  const NickName.dirty([String value = '']) : super.dirty(value);

  static final _nicknameRegExp =
      RegExp(r'^([\u3131-\u314e|\u314f-\u3163|\uac00-\ud7a3|\w]{0,23})$');

  @override
  NickNameValidation validator(String value) {
    if (value.length < 15 && value.length > 2) {
      return _nicknameRegExp.hasMatch(value)
          ? NickNameValidation.valid
          : NickNameValidation.notmatch;
    } else {
      if (value.length > 2) {
        return NickNameValidation.more;
      } else if (value.isEmpty) {
        return NickNameValidation.empty;
      } else {
        return NickNameValidation.less;
      }
    }
  }
}
