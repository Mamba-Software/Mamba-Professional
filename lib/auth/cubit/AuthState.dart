part of 'AuthCubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  final AuthProviderEnum provider;

  const AuthLoading(this.provider);

  @override
  List<Object?> get props => [provider];
}

class AuthNotLoged extends AuthState {

  const AuthNotLoged();

  @override
  List<Object?> get props => [];
}

class AuthLoaded extends AuthState {

  const AuthLoaded();

  @override
  List<Object?> get props => [];
}

class AuthRegistered extends AuthState {

  const AuthRegistered();

  @override
  List<Object?> get props => [];
}
class AuthCorrectForget extends AuthState {

  const AuthCorrectForget();

  @override
  List<Object?> get props => [];
}

class AuthError extends AuthState {
  final AuthErrorEnum error;

  const AuthError(this.error);

  @override
  List<Object?> get props => [error];
}

class AuthMaintenance extends AuthState {

  const AuthMaintenance();

  @override
  List<Object?> get props => [];
}

class AuthAdmin extends AuthState {

  const AuthAdmin();

  @override
  List<Object?> get props => [];
}

class AuthUserBrand extends AuthState {

  final Brand brand;

  const AuthUserBrand(this.brand);

  @override
  List<Object?> get props => [brand];
}

class AuthUserNoBrand extends AuthState {

  const AuthUserNoBrand();

  @override
  List<Object?> get props => [];
}

class AuthNewUser extends AuthState {

  const AuthNewUser();

  @override
  List<Object?> get props => [];
}

class AuthLogOut extends AuthState {

  const AuthLogOut();

  @override
  List<Object?> get props => [];
}