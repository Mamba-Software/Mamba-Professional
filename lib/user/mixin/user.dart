import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/data/Models/Usuario.dart';
import 'package:mamba/user/bloc/user_bloc.dart';

mixin UserBlocMixin {
  Usuario myUser(BuildContext context) {
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      return userState.user;
    }
    return Usuario(); // Or handle differently if the user is not loaded
  }
}
