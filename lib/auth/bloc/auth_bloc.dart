import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/auth/data/auth_repository.dart';
import 'package:mamba/auth/models/auth_user.dart';
import 'package:mamba/auth/sign_in/models/sign_in_provider.dart';
import 'package:mamba/brand/bloc/brand_bloc.dart';
import 'package:mamba/data/Models/Usuario.dart';
import 'package:mamba/events/cubit/events_bloc.dart';
import 'package:mamba/user/bloc/user_bloc.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthStates> {
  
  // Data Repositories
  final AuthRepository _authRepository;
  // State Blocs
  final UserBloc _userBloc;
  final BrandBloc _brandBloc;
  final EventsBloc _eventsBloc;
  // Other Vars
  late StreamSubscription<AuthUser> _authUserSubscription;

  AuthBloc({
    // Data Repositories
    required AuthRepository authRepository,
    // State Blocs
    required UserBloc userBloc,
    required BrandBloc brandBloc,
    required EventsBloc eventsBloc,
  })  : _authRepository = authRepository,
        _userBloc = userBloc,
        _brandBloc = brandBloc,
        _eventsBloc = eventsBloc,
        super(const AuthStates.unknown()) {
    initializeAuth();
  }

  // Init Bloc Function
  void initializeAuth() {
    on<AuthUserChanged>(_onUserChanged);
    on<AuthLogoutRequested>(_onLogoutRequested);
    _authUserSubscription = _authRepository.authUser.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  // Bloc Event onUserChanged Function
  Future<void> _onUserChanged(
      AuthUserChanged event, Emitter<AuthStates> emit) async {
    if (event.user == AuthUser.empty) {
      emit(const AuthStates.unauthenticated());
      _userBloc.restoreUser();
      _brandBloc.restoreBrand();
      _eventsBloc.restoreEvents();
    } else {
      if (event.user.error) {
        _authRepository.logOut();
        emit(const AuthStates.unauthenticated());
        _userBloc.restoreUser();
        _brandBloc.restoreBrand();
        _eventsBloc.restoreEvents();
      } else {
        emit(AuthStates.authenticated(event.user));
        _userBloc.initializeUser(userId: event.user.id);
      }
    }
  }

  // Bloc Event onLogoutRequested Function
  void _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthStates> emit) {
    unawaited(_authRepository.logOut());
  }

  // Auth Repository Functions
  Future<void> logIn({
    required String? email,
    required String? password,
    required SignInProvider provider,
  }) async {
    return provider == SignInProvider.google
        ? _authRepository.logInWithGoogle()
        : provider == SignInProvider.apple
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

  Future<void> resetPassword({required String email}) {
    return _authRepository.resetPassword(email: email);
  }

  // Auxiliar Checking Functions
  Future<bool> checkUserType({required bool checkTrainer}) async {
    return await _authRepository.checkUserType(checkTrainer: checkTrainer);
  }

  Future<bool> checkIfEmailExists({required String email}) {
    return _authRepository.existEmail(email: email);
  }

  Future<bool> checkIfUsernameExists({required String username}) {
    return _authRepository.existUsername(username: username);
  }

  @override
  Future<void> close() {
    _authUserSubscription.cancel();
    return super.close();
  }
}
