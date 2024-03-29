import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/auth/cubit/AuthCubit.dart';
import 'package:mamba/auth/utils/enumAuth.dart';
import 'package:mamba/auth/views/ForgotPassword.dart';
import 'package:mamba/auth/views/Register.dart';
import 'package:mamba/auth/views/SplashScreen.dart';
import 'package:mamba/auth/widgets/AppleLogin.dart';
import 'package:mamba/auth/widgets/GoogleLogin.dart';
import 'package:mamba/auth/widgets/NormalLogin.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/commons/widgets/responsive/responsive_login.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/app/styles/AppColors.dart';
import 'package:mamba/popups/cubit/popups_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

// Login Page. This allow the User to get Logged In or to Register a new account.
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login>
    with TickerProviderStateMixin, PlatformMixin {
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
    super.initState();
    context.read<PopupsCubit>().checkIfAppUpdate(false);
  }

  Widget _renderWidget() {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          switch (state.error) {
            case AuthErrorEnum.wrongAppUser:
              // Handle wrong app user error here.
              showInSnackBar(context.l10n.wrongAppUser,
                  context.l10n.wrongAppUserBody, true);

              break;
            case AuthErrorEnum.loginError:
              // Handle login error here.
              showInSnackBar(context.l10n.loginError);

              break;
            case AuthErrorEnum.validateError:
              print('Error: Validation failed.');
              // Handle validation error here.
              showInSnackBar(context.l10n.validateError,
                  "${context.l10n.resend} ${context.l10n.email}", true, true);

              break;
            case AuthErrorEnum.registerError:
              print('Error: Registration failed.');
              // Handle registration error here.
              showInSnackBar(context.l10n.registerError);
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
        return initialLogIn(state);
      },
    );
  }

  Widget initialLogIn(AuthState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        //isIOS ? appleLogin(context, state) : Container(),
        isAndroid == false ? appleLogin(context, state) : Container(),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        googleLogin(context, state),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.width * 0.05),
          child: Row(children: <Widget>[
            Expanded(
              child: Divider(
                  color: context.theme.dividerColor,
                  height: 0.5,
                  indent: MediaQuery.of(context).size.width * 0.05,
                  endIndent: MediaQuery.of(context).size.width * 0.05),
            ),
            Text(context.l10n.intermediatePaymentMethod,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.grey),
                textAlign: TextAlign.center),
            Expanded(
              child: Divider(
                  color: context.theme.dividerColor,
                  height: 0.5,
                  indent: MediaQuery.of(context).size.width * 0.05,
                  endIndent: MediaQuery.of(context).size.width * 0.05),
            ),
          ]),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        TextFormField(
          autofocus: true,
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (val) => val!.isEmpty ? context.l10n.emailError : null,
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
          decoration: InputDecoration(
            labelText: context.l10n.email,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        TextFormField(
            focusNode: focusNodePassword,
            validator: (val) =>
                val!.length < 6 ? context.l10n.passwordError : null,
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
            decoration: InputDecoration(
              labelText: context.l10n.password,
            )),
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
            child: Text(
              context.l10n.forgotPassword,
              style: context.textTheme.bodyMedium,
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
              style: context.textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: "${context.l10n.noAccount} ",
                ),
                TextSpan(
                  text: context.l10n.register,
                  style: context.textTheme.bodyMedium
                      ?.copyWith(decoration: TextDecoration.underline),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
                    text: "${context.l10n.noAccount} ",
                  ),
                  TextSpan(
                      text: context.l10n.register,
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
                    text: context.l10n.useMambaTermsAndConditions,
                  ),
                  TextSpan(
                      text: context.l10n.termsAndConditions.toLowerCase(),
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
    return ResponsiveCenter(
      child: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.02,
                  vertical: MediaQuery.of(context).size.height * 0.02),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[_renderWidget()],
              ),
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
