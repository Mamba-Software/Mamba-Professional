part of 'user_bloc.dart';

class UserState extends Equatable {
  const UserState({required this.user});

  final Usuario user;

  @override
  List<Object> get props => [user];

  UserState copyWith({Usuario? user}) {
    return UserState(
      user: user ?? this.user,
    );
  }
}
