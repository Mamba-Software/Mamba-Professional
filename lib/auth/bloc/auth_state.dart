part of 'auth_bloc.dart';

enum AuthStatus { authenticated, unauthenticated, unknown }

class AuthStates extends Equatable {
  //constructors

  const AuthStates._({
    this.status = AuthStatus.unknown,
    this.user = AuthUser.empty,
  });

  const AuthStates.unknown() : this._();

  const AuthStates.authenticated(AuthUser user)
      : this._(status: AuthStatus.authenticated, user: user);

  const AuthStates.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  final AuthStatus status;
  final AuthUser user;

  @override
  List<Object> get props => [status, user];
}
