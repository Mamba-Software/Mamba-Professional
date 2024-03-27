import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/auth/cubit/AuthCubit.dart';
import 'package:mamba/auth/utils/enumAuth.dart';
import 'package:mamba/auth/widgets/mobile/RecoverPassword.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/app/style/Styles.dart';
import 'package:mamba/l10n/language_manager.dart';
import 'package:mamba/l10n/language_manager.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  // Access to DataBaseService
  final _userDataService = UserDataService();

  // Scaffold Messenger Key
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  // FormVariables
  final _formKey = GlobalKey<FormState>();
  // Email
  String email = '';
  String? emailTemp;
  // Password
  final bool _passwordVisible = false;
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
          title: Text(context.l10n.resetPassword,
              style: Theme.of(context)
                  .textTheme
                  .displaySmall!
                  .copyWith(color: Colors.white)),
          elevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(
            color: Colors.white, //change your color here
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: AppColors.black,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: MediaQuery.of(context).size.width * 0.06,
            ),
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
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                  vertical: MediaQuery.of(context).size.height * 0.03),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.emailError,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.white),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  TextFormField(
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) =>
                          val!.isEmpty ? context.l10n.emailError : null,
                      onChanged: (val) {
                        setState(() => email = val);
                      },
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.white),
                      decoration: Styles.textFromInputDecoration.copyWith(
                          labelText: context.l10n.email,
                          labelStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.white),
                          errorStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.red),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(0.0),
                            child: Icon(
                              Icons.email_outlined,
                              color: AppColors.white,
                            ), // icon is 48px widget.
                          ))),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
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
              showInSnackBar(context.l10n.emailError);
              break;
            case AuthErrorEnum.forgotLoginError:
              showInSnackBar(context.l10n.loginError);
              break;
            case AuthErrorEnum.forgotValidateEmailError:
              showInSnackBar(context.l10n.validateEmail);
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
          showInSnackBar(context.l10n.validatePassword);
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
      content: Text(value,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: AppColors.black)),
      backgroundColor: Colors.white,
      duration: const Duration(seconds: 3),
    );
    scaffoldMessengerKey.currentState!.showSnackBar(snackbar);
  }
}
