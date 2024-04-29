import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({required this.email, required this.id, required this.error});

  final String id;
  final String email;
  final bool error;

  static const empty = AuthUser(
    email: '',
    id: '',
    error: false,
  );

  @override
  List<Object> get props => [email, id, error];
}
