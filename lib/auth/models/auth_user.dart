import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({required this.email, required this.id});

  final String id;
  final String email;

  static const empty = AuthUser(
    email: '',
    id: '',
  );

  @override
  List<Object> get props => [email, id];
}
