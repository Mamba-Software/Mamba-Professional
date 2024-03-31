import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/auth/cubit/AuthCubit.dart';
import 'package:mamba/auth/models/enum_auth.dart';
import 'package:mamba/auth/widgets/responsive_login.dart';
import 'package:mamba/auth/widgets/signin_button.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/app/styles/AppColors.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/snackbar/cubit/snackbar_cubit.dart';
import 'package:mamba/snackbar/models/snackbar_type.dart';


class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  // Scaffold Messenger Key
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
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
                    .read<AuthCubit>()
                    .forgotPassword(emailController.text.trim(), context);
              }
            },
            isLoading: () => context
                .read<AuthCubit>()
                .checkIfIsLoading(AuthProviderEnum.forgot),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () async {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              Navigator.pop(context, emailController.text.trim());
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
                    style: context.textTheme.bodyMedium
                        ?.copyWith(color: context.colorScheme.secondary),
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
              case AuthErrorEnum.forgotEmailError:
                context.read<SnackbarCubit>().createSnackbar(
                      SnackbarType.error,
                      context.l10n.emailError,
                    );
                break;
              case AuthErrorEnum.forgotLoginError:
                context.read<SnackbarCubit>().createSnackbar(
                      SnackbarType.error,
                      context.l10n.loginError,
                    );
                break;
              case AuthErrorEnum.forgotValidateEmailError:
                context.read<SnackbarCubit>().createSnackbar(
                      SnackbarType.error,
                      context.l10n.validateEmail,
                    );
                break;
              default:
                break;
            }
          }
          if (state is AuthCorrectForget) {
            context.read<SnackbarCubit>().createSnackbar(
                  SnackbarType.success,
                  context.l10n.validatePassword,
                );
            Future.delayed(Duration(seconds: snackbarDefaultDuration + 1),
                () async {
              Navigator.pop(context, emailController.text.trim());
            });
          }
        },
        builder: (context, state) {
          return forgotPasswordForm();
        },
      ),
    );
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
