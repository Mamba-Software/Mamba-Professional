import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mamba/auth/data/auth_repository.dart';
import 'package:mamba/auth/models/auth_user.dart';
import 'package:mamba/auth/models/enum_auth.dart';
import 'package:mamba/brand/bloc/brand_bloc.dart';
import 'package:mamba/user/bloc/user_bloc.dart';
import 'package:mamba/user/models/users/user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthStateS> {
  AuthBloc({
    required AuthRepository authRepository,
    required UserBloc userBloc,
    required BrandBloc brandBloc,
  })  : _authRepository = authRepository,
        _userBloc = userBloc,
        _brandBloc = brandBloc,
        super(const AuthStateS.unknown(),) {    
    on<AuthUserChanged>(_onUserChanged);
    on<AuthLogoutRequested>(_onLogoutRequested);
    _userSubscription = _authRepository.authUser.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  final UserBloc _userBloc;
  final BrandBloc _brandBloc;
  //final AnalyticsRepository _analyticsRepository;
  final AuthRepository _authRepository;
  late StreamSubscription<AuthUser> _userSubscription;

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }

  Future<void> _onUserChanged(
      AuthUserChanged event, Emitter<AuthStateS> emit) async {
    if (event.user == AuthUser.empty) {
      emit(const AuthStateS.unauthenticated());
      _userBloc.resetUser();
      _brandBloc.resetBrand();
    } else {
      if (event.user.error) {
        _authRepository.logOut();
        emit(const AuthStateS.unauthenticated());
        _userBloc.resetUser();
        _brandBloc.resetBrand();
      } else {
        emit(AuthStateS.authenticated(event.user));
        _userBloc.initUser(userId: event.user.id);
      }
    }
  }

  Future<bool> checkUserType({required bool checkTrainer}) async {
    return await _authRepository.checkUserType(checkTrainer: checkTrainer);
  }

  void _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthStateS> emit) {
    unawaited(_authRepository.logOut());
  }

  Future<void> logInWithCredentials(
      {required String? email,
      required String? password,
      required AuthProviderEnum provider}) async {
    return provider == AuthProviderEnum.google
        ? _authRepository.logInWithGoogle()
        : provider == AuthProviderEnum.apple
            ? _authRepository.logInWithApple()
            : _authRepository.logInWithEmailAndPassword(
                email: email!,
                password: password!,
              );
  }

  Future<void> registerUser({
    required String email,
    required String password,
    required String name,
    required DateTime birthday,
    required String username,
    required String mainImagePath,
    required int gender,
    required List<String> imagesPaths,
  }) async {
    await _authRepository.registerUser(
      user: Usuario(
        id: '',
        name: name,
        firstName: name.contains(' ') ? name.split(' ')[0] : name,
        lastName: name.contains(' ') && name.split(' ').length > 1
            ? name.split(' ')[1]
            : '',
        email: email,
        gender: gender,
      ),
      password: password,
      mainImagePath: mainImagePath,
      otherImagesPaths: imagesPaths,
    );
  }

  Future<void> createUser({
    required String email,
    required String password,
  }) async {
    await _authRepository.createUser(
      email: email,
      password: password,
    );
  }

  Future<void> resetPassword({required String email}) {
    return _authRepository.resetPassword(email: email);
  }

  Future<bool> checkIfEmailExists({required String email}) {
    return _authRepository.existEmail(email: email);
  }

  Future<bool> checkIfUsernameExists({required String username}) {
    return _authRepository.existUsername(username: username);
  }
}
