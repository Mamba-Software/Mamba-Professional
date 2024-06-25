part of 'sign_in_cubit.dart';

abstract class SignInState extends Equatable {
  const SignInState();
}

class SignInInitial extends SignInState {
  const SignInInitial();

  @override
  List<Object?> get props => [];
}

class SignInLoading extends SignInState {
  final SignInProvider provider;

  const SignInLoading(this.provider);

  @override
  List<Object?> get props => [provider];
}

class SignInRegistered extends SignInState {
  final String email;
  const SignInRegistered({required this.email});

  @override
  List<Object?> get props => [email];
}

class SignInForgetPassword extends SignInState {
  final String email;
  const SignInForgetPassword({required this.email});

  @override
  List<Object?> get props => [email];
}

class SignInError extends SignInState {
  final SignInErrorType error;

  const SignInError(this.error);

  @override
  List<Object?> get props => [error];
}
