/// Thrown if a failure occurs.
class UnknownFailure implements Exception {}

/// Thrown during the login process if a failure occurs.
class LogInFailure implements Exception {}

/// Thrown during the logout process if a failure occurs.
class LogOutFailure implements Exception {}

/// Thrown during the logout process if a failure occurs.
class ResetPasswordFailure implements Exception {}

class EmailNotValid implements Exception {}

class WrongCredentials implements Exception {}

class EmailNotVerified implements Exception {}

class UsernameAlreadyExists implements Exception {}

class EmailAlreadyExists implements Exception {}

class RegisterError implements Exception {}

class WrongAppUser implements Exception {}
