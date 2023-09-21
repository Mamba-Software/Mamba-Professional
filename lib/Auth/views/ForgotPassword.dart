import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Auth/cubit/AuthCubit.dart';
import 'package:mamba_castelldefels/Auth/utils/enumAuth.dart';
import 'package:mamba_castelldefels/Auth/widgets/RecoverPassword.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ForgotPassword extends StatefulWidget {
  ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  // Access to DataBaseService
  var _userDataService = new UserDataService();

  // Scaffold Messenger Key
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  // FormVariables
  final _formKey = GlobalKey<FormState>();
  // Email
  String email = '';
  String? emailTemp;
  // Password
  bool _passwordVisible = false;
  String password1 = '';
  String password2 = '';

  @override
  void initState() {
    mixpanel!.track('mamba_forgot_password_view');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.resetPassword, style: Theme.of(context).textTheme.headline3!.copyWith(color: Colors.white)),
          elevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(
            color: Colors.white, //change your color here
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: AppColors.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width * 0.06,),
            onPressed: () {
              if (email.isNotEmpty) {
                Navigator.pop(context, email.trim());
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.black,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.height*0.03),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.emailError,
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  TextFormField(
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.emailError : null,
                      onChanged: (val) {
                        setState(() => email = val);
                      },
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                      decoration: Styles.textFromInputDecoration.copyWith(
                          labelText: AppLocalizations.of(context)!.email,
                          labelStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                          errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                          prefixIcon:  const Padding(
                            padding: EdgeInsets.all(0.0),
                            child: Icon(
                              Icons.email_outlined,
                              color: AppColors.white,
                            ), // icon is 48px widget.
                          )
                      )
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.04),
                  _renderWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderWidget() {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          switch (state.error) {
            case AuthErrorEnum.forgotEmailError:
              showInSnackBar(AppLocalizations.of(context)!.emailError);
              break;
            case AuthErrorEnum.forgotLoginError:
              showInSnackBar(AppLocalizations.of(context)!.loginError);
              break;
            case AuthErrorEnum.forgotValidateEmailError:
              showInSnackBar(AppLocalizations.of(context)!.validateEmail);
              break;
            case AuthErrorEnum.wrongAppUser:
              // TODO: Handle this case.
              break;
            case AuthErrorEnum.loginError:
              // TODO: Handle this case.
              break;
            case AuthErrorEnum.validateError:
              // TODO: Handle this case.
              break;
            case AuthErrorEnum.registerError:
              // TODO: Handle this case.
              break;
            case AuthErrorEnum.validateErrorRegister:
              // TODO: Handle this case.
              break;
            case AuthErrorEnum.sameEmail:
              // TODO: Handle this case.
              break;
            case AuthErrorEnum.manualRegisterError:
              // TODO: Handle this case.
              break;
          }
        }
        if (state is AuthCorrectForget) {
          showInSnackBar(AppLocalizations.of(context)!.validatePassword);
          Future.delayed(const Duration(seconds: 5), () async {
            Navigator.pop(context, email.trim());
          });
        }
      },
      builder: (context, state) {
        return _renderWidgetChild(state);
      },
    );
  }

  // Update _renderWidget to only return Widgets
  Widget _renderWidgetChild(AuthState state) {
    return recoverPassword(context, state, _formKey, email, password1);
  }



  void showInSnackBar(String value) {
    final snackbar = SnackBar(
      content: Text(
          value,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.black)
      ),
      backgroundColor: Colors.white,
      duration: const Duration(seconds: 3),
    );
    scaffoldMessengerKey.currentState!.showSnackBar(snackbar);
  }
}


