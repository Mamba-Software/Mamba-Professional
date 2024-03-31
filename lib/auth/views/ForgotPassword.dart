import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/auth/cubit/AuthCubit.dart';
import 'package:mamba/auth/utils/enumAuth.dart';
import 'package:mamba/auth/widgets/RecoverPassword.dart';
import 'package:mamba/auth/widgets/responsive_login.dart';
import 'package:mamba/auth/widgets/signin_button.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/app/styles/AppColors.dart';
import 'package:mamba/commons/managers/language_manager.dart';

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
                context.read<AuthCubit>().forgotPassword(emailController.text.trim(), context);
              }
            },
            isLoading: () => context
                .read<AuthCubit>()
                .checkIfIsLoading(AuthProviderEnum.forgot),
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
