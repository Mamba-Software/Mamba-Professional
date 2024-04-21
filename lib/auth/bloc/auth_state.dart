part of 'auth_bloc.dart';

enum AuthStatus { authenticated, unauthenticated, unknown }

class AuthStateS extends Equatable {
  //constructors

  const AuthStateS._({
    this.status = AuthStatus.unknown,
    this.user = AuthUser.empty,
  });

  const AuthStateS.unknown() : this._();

  const AuthStateS.authenticated(AuthUser user)
      : this._(status: AuthStatus.authenticated, user: user);

  const AuthStateS.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  final AuthStatus status;
  final AuthUser user;

  @override
  List<Object> get props => [status, user];
}
