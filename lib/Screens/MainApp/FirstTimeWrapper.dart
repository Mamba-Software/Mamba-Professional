// Flutter Libs
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';
import 'package:mamba_castelldefels/Globals/Loading.dart';
import 'package:mamba_castelldefels/Providers/AuthenticationProvider.dart';
import 'package:mamba_castelldefels/Providers/ClientProvider.dart';
import 'package:mamba_castelldefels/Providers/LanguageProvider.dart';
import 'package:mamba_castelldefels/Providers/TrainerProvider.dart';
import 'package:mamba_castelldefels/Providers/UserProvider.dart';
import 'package:provider/provider.dart';
// Internal App Tools
import 'FirstTime/FirstClient.dart';
import 'FirstTime/FirstTrainer.dart';
import 'Home/Home.dart';

class FirstTimeWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    errorAuthLogin = false;
    errorAuthRegister = false;
    final user = Provider.of<AuthenticationProvider>(context);
    final usuario = Provider.of<UserProvider>(context).usuario;
    final language = Provider.of<LanguageProvider>(context,listen: false);
    Future.delayed(Duration.zero, () async {
      Locale locale = Idiomas.getLocaleFromString(usuario.idioma!);
      language.setLocale(locale);
    });
    return Consumer<UserProvider>(
        builder: (context, UserProvider userProvider, _) {
          userProvider.getUsuarioFirebase(user.user!.uid);
          switch (userProvider.first) {
            case First.Uninitialized:
              return Loading();
            case First.YES:
              return FirstTime();
            case First.NO:
              return HomePage();
          }
        }
    );
  }
}

class FirstTime extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, UserProvider userProvider, _) {
        switch (userProvider.type) {
          case Type.Uninitialized:
            return Loading();
          case Type.Client:
            return Consumer<ClientProvider>(
                builder: (context, ClientProvider clientProvider, _){
                  clientProvider.getClientFirebase(userProvider.usuario.uid);
                  switch (clientProvider.loader) {
                    case LoaderC.Uninitialized:
                      return Loading();
                    case LoaderC.YES:
                      return Loading();
                    case LoaderC.NO:
                      userIsTrainer = false;
                      return FirstClient();
                  }
                });
          case Type.Trainer:
            return Consumer<TrainerProvider>(
                builder: (context, TrainerProvider trainerProvider, _){
                  trainerProvider.getTrainerFirebase(userProvider.usuario.uid);
                  switch (trainerProvider.loader) {
                    case LoaderT.Uninitialized:
                      return Loading();
                    case LoaderT.YES:
                      return Loading();
                    case LoaderT.NO:
                      userIsTrainer = true;
                      return FirstTrainer();
                  }
                });
        }
      }
    );
  }
}