part of 'user_bloc.dart';

abstract class UserState extends Equatable {
  const UserState();
}

class UserInitial extends UserState {
  const UserInitial();

  @override
  List<Object?> get props => [];
}

class UserLoaded extends UserState {  
  final Usuario user;
  
  const UserLoaded({required this.user});

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
  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}