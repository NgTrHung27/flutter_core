import 'package:flutter_core/core/utils/regex_validator.dart'
    show RegexValidator;

extension StringValidatorExtension on String {
  bool get isEmailValid => (RegexValidator.email as RegExp).hasMatch(this);
  bool get isPasswordValid => (RegexValidator.password as RegExp).hasMatch(this);
}