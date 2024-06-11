import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mamba/app/router/custom_transitions.dart';
import 'package:mamba/auth/cubit/AuthCubit.dart';
import 'package:mamba/auth/models/enum_auth.dart';
import 'package:mamba/auth/widgets/responsive_login.dart';
import 'package:mamba/auth/widgets/signin_button.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/snackbar/cubit/snackbar_cubit.dart';
import 'package:mamba/snackbar/models/custom_snackbar.dart';
import 'package:mamba/snackbar/models/snackbar_type.dart';

// Register Page that allows the User to create his profile. This is the same for Client and Trainer.
// After registering the page pop´s after 5 seconds and the user is sent to the Login page. Before Login in
// they need to verify his email.
class Register extends StatefulWidget {
  static String routeName = 'register';
  static GoRoute route = GoRoute(
    name: routeName,
    path: 'register',
    pageBuilder: (BuildContext context, GoRouterState state) =>
        CustomTransitions.instance.customTransitionPage(
      state: state,
      child: const Register(),
    ),
  );

  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> with PlatformMixin {
  // Form Variables
  final _formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  FocusNode focusNodePassword = FocusNode();
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
  }

  Widget registerForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Title
          const SizedBox(height: 30),
          Text(
            context.l10n.createAccount,
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
          const SizedBox(height: 20),
          SignUpButton(
            foregroundColor: context.colorScheme.onSecondary,
            backgroundColor: context.colorScheme.secondary,
            text: context.l10n.register,
            onTap: () {
              if (_formKey.currentState!.validate()) {
                //emailTemp = email;
                context.read<AuthCubit>().signUp(emailController.text.trim(),
                    passwordController.text, context);
              }
            },
            isLoading: () => context
                .read<AuthCubit>()
                .checkIfIsLoading(AuthProviderEnum.register),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () async {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              context.pop();
            },
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: context.textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: "${context.l10n.existingAccount} ",
                  ),
                  TextSpan(
                    text: context.l10n.login,
                    style: context.textTheme.titleSmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLogin(
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            switch (state.error) {
              case AuthErrorEnum.sameEmail:
                CustomSnackbar snackbar = CustomSnackbar(
                  type: SnackbarType.error,
                  message: context.l10n.sameEmail,
                );
                context.read<SnackbarCubit>().enqueueSnackbarAction(snackbar);
                break;
              case AuthErrorEnum.manualRegisterError:
                CustomSnackbar snackbar = CustomSnackbar(
                  type: SnackbarType.error,
                  message: context.l10n.registerError,
                );
                context.read<SnackbarCubit>().enqueueSnackbarAction(snackbar);
                break;
              case AuthErrorEnum.validateErrorRegister:
                CustomSnackbar snackbar = CustomSnackbar(
                  type: SnackbarType.error,
                  message: context.l10n.validateEmail,
                );
                context.read<SnackbarCubit>().enqueueSnackbarAction(snackbar);
                break;
              default:
                break;
            }
          }
          if (state is AuthRegistered) {
            CustomSnackbar snackbar = CustomSnackbar(
              type: SnackbarType.success,
              message: context.l10n.validate,
            );
            context.read<SnackbarCubit>().enqueueSnackbarAction(snackbar);
            Future.delayed(
              Duration(seconds: (snackbarDefaultDuration + 0.5).toInt()),
              () async {
                context.pop();
              },
            );
          }
        },
        builder: (context, state) {
          return registerForm();
        },
      ),
    );
  }
}
