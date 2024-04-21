enum SignInMode {
  initial,
  register,
  login,
  loginEmail,
}

extension SignInModeX on SignInMode {
  /// Indicates whether the form is in the process of being submitted.
  bool get isInitial => this == SignInMode.initial;

  /// Indicates whether the form has been submitted successfully.
  bool get isRegister => this == SignInMode.register;

  /// Indicates whether the form submission failed.
  bool get isLogin => this == SignInMode.login;

  /// Indicates whether the form submission has been canceled.
  bool get isLoginEmail => this == SignInMode.loginEmail;
}
