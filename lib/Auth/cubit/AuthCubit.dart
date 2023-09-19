import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mamba_castelldefels/Auth/utils/enumAuth.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'AuthState.dart';


class AuthCubit extends Cubit<AuthState> {

  AuthCubit() : super(const AuthInitial());

  final _userDataService = UserDataService();
  List<Event> finishedEventsList = [];
  List<Event> upcomingEventsList = [];
  late StreamSubscription<QuerySnapshot> _subscription;
  final googleSignIn = GoogleSignIn();

  void generalSignIn(AuthProviderEnum provider, BuildContext context, [String? email, String? password]) {
    emit(AuthLoading(provider));
    switch(provider) {
      case AuthProviderEnum.normal:
          _signIn(email!, password!);
        break;
      case AuthProviderEnum.google:
          _signInWithGoogle(context);
        break;
      case AuthProviderEnum.apple:
          _signInWithApple(context);
        break;
    }
  }

  void _signIn(String email, String password) async {
    int result = await _userDataService.signIn(email.trim(), password);
    if (result == 0) {
      User? user = await _userDataService.getCurrentUser();
      bool? isTrainer;
      try {
        isTrainer = await _userDataService.checkIfUserIsTrainer(user!.uid);
        if (isTrainer != null && isTrainer == false) {
          await _userDataService.signOut();
          mixpanel!.track('mamba_login_wrong_app_error');
          emit(const AuthError(AuthErrorEnum.wrongAppUser));
        } else {
          mixpanel!.track('mamba_login_completed');
          emit(const AuthLoaded());
        }
      } catch (e) {
        emit(const AuthError(AuthErrorEnum.loginError));
      }
    } else if (result == -1) {
      mixpanel!.track('mamba_login_notfound_error');
      //email = emailTemp;
      emit(const AuthError(AuthErrorEnum.loginError));
    } else if (result == -2) {
      mixpanel!.track('mamba_login_validate_email_error');
      emit(const AuthError(AuthErrorEnum.validateError));
    }
  }

  void _signInWithGoogle(BuildContext context) async {
    try {
      final user = await googleSignIn.signIn();
      if (user == null) {
        emit(const AuthError(AuthErrorEnum.loginError));
      } else {
        final googleAuth = await user.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);
        bool userExists = await _userDataService.checkIfUserExists(authResult.user!.uid);
        if (userExists) {
          // Check it is no Trainer
          bool? isTrainer;
          try {
            isTrainer = await _userDataService.checkIfUserIsTrainer(authResult.user!.uid);
            if (isTrainer != null && isTrainer == false) {
              await _userDataService.signOut();
              await googleSignIn.signOut();
              emit(const AuthError(AuthErrorEnum.wrongAppUser));
            } else {
              mixpanel!.track('mamba_google_login_completed');
              emit(const AuthLoaded());
            }
          } catch (e) {
            emit(const AuthError(AuthErrorEnum.loginError));
          }
        } else {
          // Create an account and a user for this new person from google
          bool result = await _userDataService.addUserGoogleOrApple(authResult, Localizations.localeOf(context).languageCode);
          if (result) {
            mixpanel!.track('mamba_google_register_completed');
            emit(const AuthLoaded());
          } else {
            emit(const AuthError(AuthErrorEnum.loginError));
          }
        }
      }
    } catch (e) {
      emit(const AuthError(AuthErrorEnum.registerError));
    }
  }

  void _signInWithApple(BuildContext context) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oAuthProvider = OAuthProvider('apple.com');
      final oAuthCredential = oAuthProvider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );
      UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(oAuthCredential);
      String? fullName;
      if (credential.givenName != null && credential.familyName != null) {
        fullName = '${credential.givenName} ${credential.familyName}';
      }
      if (fullName != null) {
        await authResult.user!.updateDisplayName(fullName);
        await authResult.user!.reload();
      }
      bool userExists = await _userDataService.checkIfUserExists(authResult.user!.uid);
      if (userExists) {
        // Check it is no Trainer
        bool? isTrainer;
        try {
          isTrainer = await _userDataService.checkIfUserIsTrainer(authResult.user!.uid);
          if (isTrainer != null && isTrainer == false) {
            await _userDataService.signOut();
            emit(const AuthError(AuthErrorEnum.wrongAppUser));
          } else {
            mixpanel!.track('mamba_apple_login_completed');
            emit(const AuthLoaded());
          }
        } catch (e) {
          emit(const AuthError(AuthErrorEnum.loginError));
        }
      } else {
        // Create an account and a user for this new person from Apple
        bool result = await _userDataService.addUserGoogleOrApple(authResult, Localizations.localeOf(context).languageCode);
        if (result) {
          mixpanel!.track('mamba_apple_register_completed');
          emit(const AuthLoaded());
        } else {
          emit(const AuthError(AuthErrorEnum.loginError));
        }
      }
    } catch (e) {
      print(e.toString());
      emit(const AuthError(AuthErrorEnum.registerError));
    }
  }

  void resetState() {
    emit(const AuthInitial());
  }

/*
  Future<void> getInitialAuth(List<Usuario> _brandTrainers) async {
    try {
      // Set the State to Loading
      emit(const AuthLoading());
      // Brand Id String
      String brandId = currentBrand.id!;
      // Get Last 100 Finished Events
      finishedEventsList = await _eventDataService.getBrandFirstCompletedEventsLimit(brandId, limit);
      // Add The Trainers to the Event
      List<Usuario> eventTrainers = [];
      for (Event evt in finishedEventsList) {
        for (Usuario trainer in _brandTrainers) {
          int index =  trainer.eventsList.indexWhere((element) => element.id == evt.id);
          if (index != -1) {
            eventTrainers.add(trainer);
          }
        }
        evt.setUserList = eventTrainers;
        eventTrainers = [];
      }
      // Open the Stream to Get Brand Upcoming Events
      _subscription = _eventDataService.getBrandUpcomingEventsStream(brandId).listen((querySnapshot) async {
          List<DocumentSnapshot> documents = querySnapshot.docs;
          upcomingEventsList = documentsToEvents(documents, _brandTrainers);
          List<Event> finalList = finishedEventsList+upcomingEventsList;
          // Order Notification List Descending Time
          finalList.sort((a,b) {
            var aDate =  DateTime(
              int.parse(a.year!),
              int.parse(a.month!),
              int.parse(a.day!),
              int.parse(a.hour!),
              int.parse(a.minute!),
            );
            var bDate =  DateTime(
              int.parse(b.year!),
              int.parse(b.month!),
              int.parse(b.day!),
              int.parse(b.hour!),
              int.parse(b.minute!),
            );
            return aDate.compareTo(bDate);
          });
          // Emit a new state with the list of `Events`.
          emit(AuthLoaded(finalList));
        },
          onError: (e) {
            print("Brand Events Error"+e.toString());
            emit(AuthError(e.toString()));
          },
        );
      } catch(e) {
        print("Brand Events Error"+e.toString());
        emit(AuthError(e.toString()));
      }
      /* Open the Stream to Get Brand Upcoming Events
      _subscription = _eventDataService.getBrandUpcomingEventsStream(brandId).listen((querySnapshot) async {
        for (var change in querySnapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            print("new one");
            DocumentSnapshot document = change.doc;
            Event evt = documentToEvent(document, _brandTrainers);
            upcomingEventsList.removeWhere((element) => element.id == evt.id!);
            upcomingEventsList.add(evt);
          }
          if (change.type == DocumentChangeType.modified) {
            print("modified one");
            DocumentSnapshot document = change.doc;
            Event evt = documentToEvent(document, _brandTrainers);
            upcomingEventsList.removeWhere((element) => element.id == evt.id!);
            upcomingEventsList.add(evt);
          }
          if (change.type == DocumentChangeType.modified) {
            print("deleted one");
          }
        }
        List<Event> finalList = finishedEventsList+upcomingEventsList;
        // Order Notification List Descending Time
        finalList.sort((a,b) {
          var aDate =  DateTime(
            int.parse(a.year!),
            int.parse(a.month!),
            int.parse(a.day!),
            int.parse(a.hour!),
            int.parse(a.minute!),
          );
          var bDate =  DateTime(
            int.parse(b.year!),
            int.parse(b.month!),
            int.parse(b.day!),
            int.parse(b.hour!),
            int.parse(b.minute!),
          );
          return aDate.compareTo(bDate);
        });
        // Emit a new state with the list of `Events`.
        emit(AuthLoaded(finalList));
      },
      onError: (e) {
        print("Brand Events Error"+e.toString());
        emit(AuthError(e.toString()));
      },
      );
    } catch(e) {
      print("Brand Events Error"+e.toString());
      emit(AuthError(e.toString()));
    }
       */
  }

  Future<void> getMoreAuth(String eventId, List<Usuario> _brandTrainers) async {
    try {
      print("Getting More Brand Events");
      // Set the State to Loading
      String brandId = currentBrand.id!;
      // Get Last 100 Finished Events
      List<Event> moreFinishedEvents = await _eventDataService.getBrandMoreCompletedEventsLimit(brandId, eventId, limit*2);
      // Add The Trainers to the Event
      List<Usuario> eventTrainers = [];
      for (Event evt in moreFinishedEvents) {
        for (Usuario trainer in _brandTrainers) {
          int index =  trainer.eventsList.indexWhere((element) => element.id == evt.id);
          if (index != -1) {
            eventTrainers.add(trainer);
          }
        }
        evt.setUserList = eventTrainers;
        eventTrainers = [];
      }
      finishedEventsList = List.from(moreFinishedEvents+finishedEventsList);
      List<Event> finalList = List.from(finishedEventsList+upcomingEventsList);
      // Order Notification List Descending Time
      finalList.sort((a,b) {
        var aDate =  DateTime(
          int.parse(a.year!),
          int.parse(a.month!),
          int.parse(a.day!),
          int.parse(a.hour!),
          int.parse(a.minute!),
        );
        var bDate =  DateTime(
          int.parse(b.year!),
          int.parse(b.month!),
          int.parse(b.day!),
          int.parse(b.hour!),
          int.parse(b.minute!),
        );
        return aDate.compareTo(bDate);
      });
      emit(AuthLoaded(finalList));
    } catch(e) {
      print("More Brand Events Error"+e.toString());
      emit(AuthError(e.toString()));
    }
  }

  Future<void> updateBrandEvent(String eventId, List<Usuario> _brandTrainers) async {
    try {
      print("Update Brand Event");
      // Set the State to Loading
      String brandId = currentBrand.id!;
      // Get Last 100 Finished Events
      Event event = await _eventDataService.getSingleEvent(eventId);
      // Add The Trainers to the Event
      List<Usuario> eventTrainers = [];
      for (Usuario trainer in _brandTrainers) {
        int index = trainer.eventsList.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          eventTrainers.add(trainer);
        }
      }
      event.setUserList = eventTrainers;
      // Remove From Finished List First and Add Again
      finishedEventsList.removeWhere((element) => element.id == eventId);
      finishedEventsList.add(event);
      List<Event> finalList = List.from(finishedEventsList+upcomingEventsList);
      // Order Notification List Descending Time
      finalList.sort((a,b) {
        var aDate =  DateTime(
          int.parse(a.year!),
          int.parse(a.month!),
          int.parse(a.day!),
          int.parse(a.hour!),
          int.parse(a.minute!),
        );
        var bDate =  DateTime(
          int.parse(b.year!),
          int.parse(b.month!),
          int.parse(b.day!),
          int.parse(b.hour!),
          int.parse(b.minute!),
        );
        return aDate.compareTo(bDate);
      });
      emit(AuthLoaded(finalList));
      print("Event $eventId Successfully Updated");
    } catch(e) {
      print("Delete Brand Event Error"+e.toString());
      emit(AuthError(e.toString()));
    }
  }

  Future<void> deleteBrandEvent(String eventId) async {
    try {
      print("Delete More Brand Events");
      upcomingEventsList.removeWhere((element) => element.id == eventId);
      finishedEventsList.removeWhere((element) => element.id == eventId);
      List<Event> finalList = List.from(finishedEventsList+upcomingEventsList);
      // Order Notification List Descending Time
      finalList.sort((a,b) {
        var aDate =  DateTime(
          int.parse(a.year!),
          int.parse(a.month!),
          int.parse(a.day!),
          int.parse(a.hour!),
          int.parse(a.minute!),
        );
        var bDate =  DateTime(
          int.parse(b.year!),
          int.parse(b.month!),
          int.parse(b.day!),
          int.parse(b.hour!),
          int.parse(b.minute!),
        );
        return aDate.compareTo(bDate);
      });
      emit(AuthLoaded(finalList));
      print("Event $eventId Successfully Deleted");
    } catch(e) {
      print("Delete Brand Event Error"+e.toString());
      emit(AuthError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    //print('LO CIERRO');
    _subscription.cancel();
    return super.close();
  }

*/

}


List<Event> documentsToEvents(List<DocumentSnapshot> documents, List<Usuario> _brandTrainers) {
  List<Event> events = [];
  List<Usuario> eventTrainers = [];
  for(int i = 0; i < documents.length; i++) {
    Event evt = Event.fromObjectOnlyCoverData(documents[i].id, documents[i]);
    // Check Trainers in Event
    for (Usuario trainer in _brandTrainers) {
      int index =  trainer.eventsList.indexWhere((element) => element.id == evt.id);
      if (index != -1) {
        eventTrainers.add(trainer);
      }
    }
    evt.setUserList = eventTrainers;
    events.add(evt);
    eventTrainers = [];
  }
  // Order By
  events.sort((a,b) {
    var aDate =  a.doneAt!.toDate();
    var bDate =  b.doneAt!.toDate();
    return aDate.compareTo(bDate);
  });
  // Return List of Events
  return events;
}

Event documentToEvent(DocumentSnapshot document, List<Usuario> _brandTrainers) {
  List<Usuario> eventTrainers = [];
  Event evt = Event.fromObjectOnlyCoverData(document.id, document);
  // Check Trainers in Event
  for (Usuario trainer in _brandTrainers) {
    int index =  trainer.eventsList.indexWhere((element) => element.id == evt.id);
    if (index != -1) {
      eventTrainers.add(trainer);
    }
  }
  evt.setUserList = eventTrainers;
  return evt;
}
