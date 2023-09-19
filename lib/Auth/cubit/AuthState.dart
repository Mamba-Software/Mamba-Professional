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

class AuthLoaded extends AuthState {

  const AuthLoaded();

  @override
  List<Object?> get props => [];
}

class AuthError extends AuthState {
  final AuthErrorEnum error;

  const AuthError(this.error);

  @override
  List<Object?> get props => [error];
}