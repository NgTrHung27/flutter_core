class RegexValidator {
  RegexValidator._();

// ignore: deprecated_member_use
  static Pattern get email => RegExp(r"^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$");
// ignore: deprecated_member_use
  static Pattern get password => RegExp(r"^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d]+$");
}
