part of 'user_bloc.dart';

abstract class UserState extends Equatable {
  final Usuario user;

  const UserState({this.user = const Usuario()});

  @override
  List<Object?> get props => [user];
}

class UserInitial extends UserState {
  const UserInitial() : super();

  @override
  List<Object?> get props => [user];
}

class UserLoaded extends UserState {  
  const UserLoaded({required super.user});

  @override
  List<Object?> get props => [user];

  UserLoaded copyWith({Usuario? user}) {
    return UserLoaded(
      user: user ?? this.user,
    );
  }
}

class UserError extends UserState {
  final String message;

  const UserError({required this.message, Usuario user = const Usuario()})
      : super(user: user);

  @override
  List<Object?> get props => [message, user];
}
