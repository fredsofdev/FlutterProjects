import 'package:formz/formz.dart';

enum NickNameValidationError { invalid, exist}

class NickName extends FormzInput<String, NickNameValidationError> {
  const NickName.pure() : super.pure('');
  const NickName.dirty([String value = '']) : super.dirty(value);

  static final _nicknameRegExp =
  RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');

  @override
  NickNameValidationError validator(String value) {
    return _nicknameRegExp.hasMatch(value)
        ? null
        : NickNameValidationError.invalid;
  }
}