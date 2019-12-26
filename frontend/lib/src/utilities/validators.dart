class Validators {
  static final validNickname = RegExp(r'^[a-zA-Z0-9]{4,}$');
  static final validEmail = new RegExp(r"^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$");

  String validateNickname(String nickname) {
    if (!validNickname.hasMatch(nickname)) {
      return "Nazwa użykownika musi składać się z co najmniej 4 liter";
    }
    return null;
  }

  String validateEmail(String email) {
    if (!validEmail.hasMatch(email)) {
      return "Wprowadź email w prawidłowej formie";
    }
    return null;
  }

  String validatePassword(String password) {
    if (password.length < 6) {
      return "Hasło musi posiadać co najmniej 6 znaków";
    }
    return null;
  }
}