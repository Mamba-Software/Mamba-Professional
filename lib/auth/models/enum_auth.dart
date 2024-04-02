enum AuthProviderEnum {
  normal,   // Default
  google,
  apple,
  register,
  forgot,
}

enum AuthErrorEnum {
  wrongAppUser,   // Default
  loginError,
  validateError,
  registerError,
  validateErrorRegister,
  sameEmail,
  manualRegisterError,
  forgotLoginError,
  forgotEmailError,
  forgotValidateEmailError
}