import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mamba/app/router/custom_transitions.dart';
import 'package:mamba/auth/bloc/auth_bloc.dart';
import 'package:mamba/auth/cubit/AuthCubit.dart';
import 'package:mamba/auth/models/enum_auth.dart';
import 'package:mamba/auth/views/forgot_password.dart';
import 'package:mamba/auth/views/register.dart';
import 'package:mamba/auth/splash/SplashScreen.dart';
import 'package:mamba/auth/widgets/signin_button.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/auth/widgets/responsive_login.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/home/views/home.dart';
import 'package:mamba/popups/cubit/popups_cubit.dart';
import 'package:mamba/snackbar/cubit/snackbar_cubit.dart';
import 'package:mamba/snackbar/models/custom_snackbar.dart';
import 'package:mamba/snackbar/models/snackbar_type.dart';
import 'package:url_launcher/url_launcher.dart';

// Login Page. This allow the User to get Logged In or to Register a new account.
class Login extends StatefulWidget {
  static String routeName = 'login';

  static GoRoute route = GoRoute(
    name: routeName,
    path: "/login",
    pageBuilder: (BuildContext context, GoRouterState state) =>
        CustomTransitions.instance.customTransitionPage(
      state: state,
      child: const Login(),
    ),
    routes: [
      Register.route,
      ForgotPassword.route,
    ],
  );

  const Login({super.key});

  static Route routeDir() {
    return MaterialPageRoute<void>(
      builder: (_) => const Login(),
      settings: const RouteSettings(name: 'Login'),
    );
  }

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with PlatformMixin {
  // Form Variables
  final _formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  FocusNode focusNodePassword = FocusNode();
  bool _passwordVisible = false;

  @override
  initState() {
    super.initState();
    context.read<PopupsCubit>().checkIfAppUpdate(false);
  }

  Widget loginForm(AuthState state) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          const SizedBox(height: 30),
          Text(
            context.l10n.login,
            style: context.textTheme.displayLarge,
          ),
          const SizedBox(height: 60),
          // Apple and Google
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
          // Divider
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
          // Text Form Field
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
            obscureText: !_passwordVisible,
            decoration: InputDecoration(
              labelText: context.l10n.password,
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 2.0),
                child: IconButton(
                  icon: Icon(
                    // Based on passwordVisible state choose the icon
                    !_passwordVisible ? Icons.visibility : Icons.visibility_off,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
            ),
          ),
          // Forgot Password
          TextButton(
            onPressed: () async {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              context.goNamed(ForgotPassword.routeName);
              /*
              String? email = await context.push<String>('/login/password');
              if (email != null) {
                setState(() {
                  emailController.text = email;
                });
              }
              */
            },
            child: Text(
              context.l10n.forgotPassword,
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          // LogIn Button
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
                context.read<AuthCubit>().generalSignIn(AuthProviderEnum.normal,
                    context, emailController.text, passwordController.text);
              }
            },
            isLoading: () => context
                .read<AuthCubit>()
                .checkIfIsLoading(AuthProviderEnum.normal),
          ),
          const SizedBox(height: 10),
          // Register
          TextButton(
            onPressed: () async {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              context.goNamed(Register.routeName);
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
                    style: context.textTheme.titleSmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          // Privacy Terms
          context.isDesktop == false
              ? Column(
                  children: [
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
                          style: context.textTheme.labelMedium,
                          children: [
                            TextSpan(
                              text: context.l10n.useMambaTermsAndConditions,
                            ),
                            TextSpan(
                              text:
                                  context.l10n.termsAndConditions.toLowerCase(),
                              /*style: context.textTheme.labelMedium?.copyWith(
                                    decoration: TextDecoration.underline)
                                    */
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthStateS>(
          listener: (context, state) {
            switch (state.status) {
              case AuthStatus.unauthenticated:
                context.goNamed(Login.routeName);
                break;
              case AuthStatus.authenticated:
                context.goNamed(HomePage.routeName);
                break;
              case AuthStatus.unknown:
                break;
            }
          },
        ),
      ],
      child: ResponsiveLogin(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              switch (state.error) {
                case AuthErrorEnum.wrongAppUser:
                  CustomSnackbar snackbar = CustomSnackbar(
                    type: SnackbarType.error,
                    message:
                        "${context.l10n.wrongAppUser} ${context.l10n.wrongAppUserBody}",
                    onAccept: () async {
                      if (isWeb) {
                        if (!await launchUrl(Uri.parse(clients))) {
                          throw 'Could not launch $termsAndConditions';
                        }
                      } else {
                        LaunchApp.openApp(
                          androidPackageName: 'com.mamba.mambaprofessionalapp',
                          iosUrlScheme: "mamba-professional",
                          appStoreLink:
                              "https://apps.apple.com/us/app/mamba-professional/id1642701679",
                          openStore: true,
                        );
                      }
                    },
                    actionText: context.l10n.open,
                  );
                  context
                      .read<SnackbarCubit>()
                      .enqueueSnackbarAction(snackbar);
                  break;
                case AuthErrorEnum.loginError:
                  CustomSnackbar snackbar = CustomSnackbar(
                    type: SnackbarType.error,
                    message: context.l10n.loginError,
                  );
                  context
                      .read<SnackbarCubit>()
                      .enqueueSnackbarAction(snackbar);
                  break;
                case AuthErrorEnum.validateError:
                  CustomSnackbar snackbar = CustomSnackbar(
                    type: SnackbarType.error,
                    message: context.l10n.validateError,
                    onAccept: () => context
                        .read<AuthCubit>()
                        .resendVerificationEmail(emailController.text.trim()),
                    actionText: "${context.l10n.resend} ${context.l10n.email}",
                  );
                  context
                      .read<SnackbarCubit>()
                      .enqueueSnackbarAction(snackbar);
                  break;
                case AuthErrorEnum.registerError:
                  CustomSnackbar snackbar = CustomSnackbar(
                    type: SnackbarType.error,
                    message: context.l10n.registerError,
                  );
                  context
                      .read<SnackbarCubit>()
                      .enqueueSnackbarAction(snackbar);
                  break;
                default:
                  break;
              }
            }
            if (state is AuthRegistered) {
              AuthRegistered castedState = state;
              emailController.text = castedState.email;
            }
            if (state is AuthCorrectForget) {
              AuthCorrectForget castedState = state;
              emailController.text = castedState.email;
            }
            if (state is AuthLoaded) {
              context.goNamed(SplashScreen.routeName);
            }
          },
          builder: (context, state) {
            return loginForm(state);
          },
        ),
      ),
    );
  }
}
