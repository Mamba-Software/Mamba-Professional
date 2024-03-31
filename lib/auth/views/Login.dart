import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/auth/cubit/AuthCubit.dart';
import 'package:mamba/auth/utils/enumAuth.dart';
import 'package:mamba/auth/views/ForgotPassword.dart';
import 'package:mamba/auth/views/Register.dart';
import 'package:mamba/auth/splash/SplashScreen.dart';
import 'package:mamba/auth/widgets/signin_button.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/auth/widgets/responsive_login.dart';
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

class _LoginState extends State<Login> with PlatformMixin {
  // Access to DatabaseService
  final _userDataService = UserDataService();
  // Scaffold Messenger Key
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // FormVariables
  final _formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  FocusNode focusNodePassword = FocusNode();

  // Apple Sign In
  bool isLoadingApple = false;

  @override
  initState() {
    super.initState();
    context.read<PopupsCubit>().checkIfAppUpdate(false);
  }

  Widget initialLogIn(AuthState state) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          Text(
            context.l10n.login,
            style: context.textTheme.displayLarge,
          ),
          const SizedBox(height: 60),
          isAndroid == false
              ? Column(
                  children: [
                    SignUpButton(
                        foregroundColor: context.colorScheme.primary,
                        backgroundColor: context.colorScheme.background,
                        text: context.l10n.continueWithApple,
                        icon: Image(
                          image: AssetImage(Assets.apple),
                          color: context.theme.primaryColor,
                        ),
                        onTap: () => context
                            .read<AuthCubit>()
                            .generalSignIn(AuthProviderEnum.apple, context),
                        isLoading: () => context
                            .read<AuthCubit>()
                            .checkIfIsLoading(AuthProviderEnum.apple)),
                    const SizedBox(height: 20),
                  ],
                )
              : Container(),
          SignUpButton(
              foregroundColor: context.colorScheme.primary,
              backgroundColor: context.colorScheme.background,
              text: context.l10n.continueWithGoogle,
              icon: Image(
                image: AssetImage(Assets.google),
              ),
              onTap: () => context
                  .read<AuthCubit>()
                  .generalSignIn(AuthProviderEnum.google, context),
              isLoading: () => context
                  .read<AuthCubit>()
                  .checkIfIsLoading(AuthProviderEnum.google)),
          const SizedBox(height: 30),
          Row(children: <Widget>[
            Expanded(
              child: Divider(
                color: context.theme.dividerColor,
                height: 0.5,
              ),
            ),
            Text(
              "  ${context.l10n.loginWithEmail}   ",
              style: context.textTheme.labelMedium,
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: Divider(
                color: context.theme.dividerColor,
                height: 0.5,
              ),
            ),
          ]),
          const SizedBox(height: 30),
          TextFormField(            
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (val) => val!.isEmpty ? context.l10n.emailError : null,
            onFieldSubmitted: (val) {
              focusNodePassword.requestFocus();
            },
            style: context.textTheme.bodyMedium,
            decoration: InputDecoration(
              labelText: context.l10n.email,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: passwordController,
            focusNode: focusNodePassword,
            validator: (val) =>
                val!.length < 6 ? context.l10n.passwordError : null,
            keyboardType: TextInputType.visiblePassword,
            style: context.textTheme.bodyMedium,
            obscureText: true,
            decoration: InputDecoration(
              labelText: context.l10n.password,
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
                    builder: (context) => const ForgotPassword(),
                    settings: const RouteSettings(name: 'ForgotPassword'),
                  ));
              /*
              if (email != null) {
                setState(() {
                  emailController.text = email;
                  this.email = email;
                });
              }*/
            },
            child: Text(
              context.l10n.forgotPassword,
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          SignUpButton(
              foregroundColor: context.colorScheme.onSecondary,
              backgroundColor: context.colorScheme.secondary,
              text: context.l10n.continueWithGoogle.split(" ")[0],
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  //emailTemp = email;
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                  context.read<AuthCubit>().generalSignIn(
                      AuthProviderEnum.normal,
                      context,
                      emailController.text,
                      passwordController.text);
                }
              },
              isLoading: () => context
                  .read<AuthCubit>()
                  .checkIfIsLoading(AuthProviderEnum.normal)),
          const SizedBox(height: 10),
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
              /*
              if (email != null) {
                setState(() {
                  emailController.text = email;
                  this.email = email;
                });
              }
              */
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
          const SizedBox(height: 5),
          context.isDesktop == false
              ? TextButton(
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
                      style: context.textTheme.labelMedium,
                      children: [
                        TextSpan(
                          text: context.l10n.useMambaTermsAndConditions,
                        ),
                        TextSpan(
                          text: context.l10n.termsAndConditions.toLowerCase(),
                          /*style: context.textTheme.labelMedium?.copyWith(
                                decoration: TextDecoration.underline)
                                */
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
      child: BlocConsumer<AuthCubit, AuthState>(
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
              await _userDataService.resendEmail(emailController.text.trim());
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
