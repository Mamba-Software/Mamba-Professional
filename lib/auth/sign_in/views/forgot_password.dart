import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mamba/app/router/custom_transitions.dart';
import 'package:mamba/auth/sign_in/cubit/sign_in_cubit.dart';
import 'package:mamba/auth/sign_in/models/sign_in_error_type.dart';
import 'package:mamba/auth/sign_in/models/sign_in_provider.dart';
import 'package:mamba/auth/sign_in/widgets/responsive_login.dart';
import 'package:mamba/auth/sign_in/widgets/signin_button.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/snackbar/cubit/snackbar_cubit.dart';
import 'package:mamba/snackbar/models/custom_snackbar.dart';
import 'package:mamba/snackbar/models/snackbar_type.dart';

class ForgotPassword extends StatefulWidget {
  static String routeName = 'password';
  static GoRoute route = GoRoute(
    name: routeName,
    path: 'password',
    pageBuilder: (BuildContext context, GoRouterState state) =>
        CustomTransitions.instance.customTransitionPage(
      state: state,
      child: const ForgotPassword(),
    ),
  );

  const ForgotPassword({super.key});

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  // FormVariables
  final _formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Widget forgotPasswordForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Title
          const SizedBox(height: 30),
          Text(
            "${context.l10n.recover} ${context.l10n.password.toLowerCase()}",
            style: context.textTheme.displayLarge,
          ),
          const SizedBox(height: 60),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (val) => val!.isEmpty ? context.l10n.emailError : null,
            style: context.textTheme.bodyMedium,
            decoration: InputDecoration(
              labelText: context.l10n.email,
            ),
          ),
          const SizedBox(height: 20),
          SignUpButton(
            foregroundColor: context.colorScheme.onSecondary,
            backgroundColor: context.colorScheme.secondary,
            text: context.l10n.recover,
            onTap: () {
              if (_formKey.currentState!.validate()) {
                context
                    .read<SignInCubit>()
                    .forgotPassword(emailController.text.trim(), context);
              }
            },
            isLoading: () => context
                .read<SignInCubit>()
                .checkIfIsLoading(SignInProvider.forgot),
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
                    text: "${context.l10n.rememberedPassword} ",
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
      child: BlocConsumer<SignInCubit, SignInState>(
        listener: (context, state) {
          if (state is SignInError) {
            switch (state.error) {
              case SignInErrorType.forgotEmailError:
                CustomSnackbar snackbar = CustomSnackbar(
                  type: SnackbarType.error,
                  message: context.l10n.emailError,
                );
                context.read<SnackbarCubit>().enqueueSnackbarAction(snackbar);
                break;
              case SignInErrorType.forgotLoginError:
                CustomSnackbar snackbar = CustomSnackbar(
                  type: SnackbarType.error,
                  message: context.l10n.loginError,
                );
                context.read<SnackbarCubit>().enqueueSnackbarAction(snackbar);
                break;
              case SignInErrorType.forgotValidateEmailError:
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
          if (state is SignInForgetPassword) {
            CustomSnackbar snackbar = CustomSnackbar(
              type: SnackbarType.success,
              message: context.l10n.validatePassword,
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
          return forgotPasswordForm();
        },
      ),
    );
  }
}
