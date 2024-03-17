import 'dart:io';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Auth/cubit/AuthCubit.dart';
import 'package:mamba_castelldefels/Auth/utils/enumAuth.dart';
import 'package:mamba_castelldefels/Auth/views/mobile/ForgotPassword.dart';
import 'package:mamba_castelldefels/Auth/views/mobile/Register.dart';
import 'package:mamba_castelldefels/Auth/views/mobile/SplashScreen.dart';
import 'package:mamba_castelldefels/Auth/widgets/mobile/AppleLogin.dart';
import 'package:mamba_castelldefels/Auth/widgets/mobile/GoogleLogin.dart';
import 'package:mamba_castelldefels/Auth/widgets/mobile/NormalLogin.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/commons/constants/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/commons/constants/GlobalVars.dart';
import 'package:mamba_castelldefels/app/style/AppColors.dart';
import 'package:mamba_castelldefels/app/style/Styles.dart';
import 'package:url_launcher/url_launcher.dart';

// Login Page. This allow the User to get Logged In or to Register a new account.
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  // Access to DatabaseService
  final _userDataService = UserDataService();

  bool isEmailSignIn = false;

  // Password Visible
  bool _passwordVisible = false;

  // Scaffold Messenger Key
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // FormVariables
  final _formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  FocusNode focusNodePassword = FocusNode();
  String email = '';
  String password = '';
  String emailTemp = '';

  // Apple Sign In
  bool isLoadingApple = false;

  @override
  initState() {
    mixpanel!.track('mamba_login_view');
    super.initState();
  }

  Widget _renderWidget() {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          switch (state.error) {
            case AuthErrorEnum.wrongAppUser:
              // Handle wrong app user error here.
              showInSnackBar(AppLocalizations.of(context)!.wrongAppUser,
                  AppLocalizations.of(context)!.wrongAppUserBody, true);

              break;
            case AuthErrorEnum.loginError:
              // Handle login error here.
              showInSnackBar(AppLocalizations.of(context)!.loginError);

              break;
            case AuthErrorEnum.validateError:
              print('Error: Validation failed.');
              // Handle validation error here.
              showInSnackBar(
                  AppLocalizations.of(context)!.validateError,
                  "${AppLocalizations.of(context)!.resend} ${AppLocalizations.of(context)!.email}",
                  true,
                  true);

              break;
            case AuthErrorEnum.registerError:
              print('Error: Registration failed.');
              // Handle registration error here.
              showInSnackBar(AppLocalizations.of(context)!.registerError);
              //context.read<AuthCubit>().resetState();
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
            case AuthErrorEnum.forgotLoginError:
              // TODO: Handle this case.
              break;
            case AuthErrorEnum.forgotEmailError:
              // TODO: Handle this case.
              break;
            case AuthErrorEnum.forgotValidateEmailError:
              // TODO: Handle this case.
              break;
          }
        }
        if (state is AuthLoaded) {
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute<void>(
                builder: (context) => const SplashScreen(),
                settings: const RouteSettings(name: 'SplashScreen'),
              ));
        }
      },
      builder: (context, state) {
        return _renderWidgetChild(state);
      },
    );
  }

  // Update _renderWidget to only return Widgets
  Widget _renderWidgetChild(AuthState state) {
    return isEmailSignIn == false ? initialLogIn(state) : logInWithEmail(state);
  }

  Widget initialLogIn(AuthState state) {
    return Container(
        key: const ValueKey<int>(0),
        height: MediaQuery.of(context).size.height * 0.4,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: AppColors.black,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Platform.isAndroid == false
                ? appleLogin(context, state)
                : Container(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            googleLogin(context, state),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            GestureDetector(
              onTap: () {
                setState(() {
                  isEmailSignIn = true;
                });
              },
              child: Material(
                elevation: 4,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.0),
                  ),
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.07,
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(30)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: MediaQuery.of(context).size.height * 0.07,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: AppColors.black,
                            borderRadius: BorderRadius.circular(30)),
                        child: Icon(
                          Icons.email_outlined,
                          size: MediaQuery.of(context).size.height * 0.04,
                          color: AppColors.white,
                        ),
                      ),
                      Expanded(
                          child: Text(
                              AppLocalizations.of(context)!.loginWithEmail,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(color: AppColors.black),
                              textAlign: TextAlign.center)),
                    ],
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                String? email = await Navigator.push(
                    context,
                    CupertinoPageRoute<String>(
                      builder: (context) => const Register(),
                      settings: const RouteSettings(name: 'Register'),
                    ));
                if (email != null) {
                  setState(() {
                    emailController.text = email;
                    this.email = email;
                  });
                }
              },
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.white),
                  children: [
                    TextSpan(
                      text: "${AppLocalizations.of(context)!.noAccount} ",
                    ),
                    TextSpan(
                        text: AppLocalizations.of(context)!.register,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.white,
                            decoration: TextDecoration.underline)),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            TextButton(
              onPressed: () async {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                if (!await launchUrl(Uri.parse(termsAndConditions)))
                  throw 'Could not launch $termsAndConditions';
              },
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.white),
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context)!
                          .useMambaTermsAndConditions,
                    ),
                    TextSpan(
                        text: AppLocalizations.of(context)!
                            .termsAndConditions
                            .toLowerCase(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.white,
                            decoration: TextDecoration.underline)),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.005),
          ],
        ));
  }

  Widget logInWithEmail(AuthState state) {
    return Container(
      key: const ValueKey<int>(1),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
          vertical: MediaQuery.of(context).size.height * 0.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: AppColors.black,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          TextFormField(
            autofocus: true,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (val) =>
                val!.isEmpty ? AppLocalizations.of(context)!.emailError : null,
            onChanged: (val) {
              setState(() {
                email = val;
              });
            },
            onFieldSubmitted: (val) {
              focusNodePassword.requestFocus();
            },
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.white),
            decoration: Styles.textFromInputDecoration.copyWith(
                labelText: AppLocalizations.of(context)!.email,
                labelStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.white),
                errorStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.red),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Icon(
                    Icons.email_outlined,
                    color: AppColors.white,
                    size: MediaQuery.of(context).size.width * 0.06,
                  ), // icon is 48px widget.
                )),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          TextFormField(
              focusNode: focusNodePassword,
              validator: (val) => val!.length < 6
                  ? AppLocalizations.of(context)!.passwordError
                  : null,
              onChanged: (val) {
                setState(() {
                  password = val;
                });
              },
              keyboardType: TextInputType.visiblePassword,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.white),
              obscureText: !_passwordVisible,
              decoration: Styles.textFromInputDecoration.copyWith(
                  labelText: AppLocalizations.of(context)!.password,
                  labelStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.white),
                  errorStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.red),
                  suffixIcon: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.white,
                            size: MediaQuery.of(context).size.width * 0.06,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          })),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Icon(
                      Icons.vpn_key_outlined,
                      color: AppColors.white,
                      size: MediaQuery.of(context).size.width * 0.06,
                    ), // icon is 48px widget.
                  ))),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.08),
            child: TextButton(
              onPressed: () async {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                String? email = await Navigator.push(
                    context,
                    CupertinoPageRoute<String>(
                      builder: (context) => const ForgotPassword(),
                      settings: const RouteSettings(name: 'ForgotPassword'),
                    ));
                if (email != null) {
                  setState(() {
                    emailController.text = email;
                    this.email = email;
                  });
                }
              },
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.center),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.white),
                  children: [
                    /*
                                      TextSpan(
                                          text: AppLocalizations.of(context)!.forgotPassword+" "
                                      ),
                                      */
                    TextSpan(
                        text: AppLocalizations.of(context)!.forgotPassword,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.normal)),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          normalLogin(context, state, _formKey, email, password),
          TextButton(
            onPressed: () async {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              String? email = await Navigator.push(
                  context,
                  CupertinoPageRoute<String>(
                    builder: (context) => const Register(),
                    settings: const RouteSettings(name: 'Register'),
                  ));
              if (email != null) {
                setState(() {
                  emailController.text = email;
                  this.email = email;
                });
              }
            },
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.white),
                children: [
                  TextSpan(
                    text: "${AppLocalizations.of(context)!.noAccount} ",
                  ),
                  TextSpan(
                      text: AppLocalizations.of(context)!.register,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.white,
                          decoration: TextDecoration.underline)),
                ],
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          TextButton(
            onPressed: () async {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              if (!await launchUrl(Uri.parse(termsAndConditions)))
                throw 'Could not launch $termsAndConditions';
            },
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.white),
                children: [
                  TextSpan(
                    text: AppLocalizations.of(context)!
                        .useMambaTermsAndConditions,
                  ),
                  TextSpan(
                      text: AppLocalizations.of(context)!
                          .termsAndConditions
                          .toLowerCase(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.white,
                          decoration: TextDecoration.underline)),
                ],
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.005),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.black,
        appBar: isEmailSignIn
            ? AppBar(
                toolbarHeight: MediaQuery.of(context).size.height * 0.08,
                backgroundColor: AppColors.black,
                elevation: 0,
                centerTitle: false,
                systemOverlayStyle: SystemUiOverlayStyle.light,
                title: FocusScope.of(context).hasPrimaryFocus == false
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Image.asset(Constants.logoExtended))
                    : Container(),
                leadingWidth: MediaQuery.of(context).size.width * 0.12,
                automaticallyImplyLeading: false,
                leading: Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.02),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back,
                        size: MediaQuery.of(context).size.width * 0.08,
                        color: AppColors.white),
                    alignment: Alignment.center,
                    onPressed: () {
                      setState(() {
                        isEmailSignIn = false;
                      });
                    },
                  ),
                ),
              )
            : AppBar(
                toolbarHeight: MediaQuery.of(context).size.height * 0.08,
                backgroundColor: AppColors.black,
                systemOverlayStyle: SystemUiOverlayStyle.light,
                elevation: 0,
              ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.02,
                vertical: MediaQuery.of(context).size.height * 0.02),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.linear,
                  child: FocusScope.of(context).hasPrimaryFocus ||
                          isEmailSignIn == false
                      ? Container(
                          key: const ValueKey<int>(0),
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.05),
                          height: MediaQuery.of(context).size.height * 0.3,
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Image.asset(Constants.logoExtended))
                      : Container(
                          key: const ValueKey<int>(1),
                        ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(0, 0.1),
                              end: const Offset(0, 0))
                          .animate(animation),
                      child: child,
                    );
                  },
                  child: _renderWidget(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showInSnackBar(String value,
      [String valueBody = "",
      bool isClickable = false,
      bool resendEmail = false]) {
    Widget snackbar;
    if (isClickable) {
      snackbar = SnackBar(
        content: GestureDetector(
          onTap: () async {
            if (resendEmail == false) {
              await LaunchApp.openApp(
                  androidPackageName: 'com.mamba.mambaprofessionalapp',
                  iosUrlScheme: "mamba-professional",
                  appStoreLink:
                      "https://apps.apple.com/us/app/mamba-professional/id1642701679",
                  openStore: true);
            } else {
              await _userDataService.resendEmail(email.trim());
              scaffoldMessengerKey.currentState!.hideCurrentSnackBar();
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: Text(value,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: AppColors.black)),
              ),
              Flexible(
                child: Text(
                  valueBody,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.black,
                      decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        duration: const Duration(seconds: 6),
      );
    } else {
      snackbar = SnackBar(
        content: Text(value,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: AppColors.black)),
        backgroundColor: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
    scaffoldMessengerKey.currentState!.showSnackBar(snackbar as SnackBar);
  }
}
