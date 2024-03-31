import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/auth/cubit/AuthCubit.dart';
import 'package:mamba/auth/models/enum_auth.dart';
import 'package:mamba/auth/widgets/responsive_login.dart';
import 'package:mamba/auth/widgets/signin_button.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/app/styles/AppColors.dart';
import 'package:mamba/commons/managers/language_manager.dart';

// Register Page that allows the User to create his profile. This is the same for Client and Trainer.
// After registering the page pop´s after 5 seconds and the user is sent to the Login page. Before Login in
// they need to verify his email.
class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> with PlatformMixin {
  // Scaffold Messenger Key
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
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
                                  .generalSignIn(
                                      AuthProviderEnum.apple, context),
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
                  validator: (val) =>
                      val!.isEmpty ? context.l10n.emailError : null,
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
                          !_passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
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
                      context.read<AuthCubit>().signUp(
                          emailController.text.trim(),
                          passwordController.text,
                          context);
                    }
                  },
                  isLoading: () => context
                      .read<AuthCubit>()
                      .checkIfIsLoading(AuthProviderEnum.normal),
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
                // Handle wrong same email.
                showInSnackBar(context.l10n.sameEmail);
                break;
              case AuthErrorEnum.manualRegisterError:
                // Handle register error here.
                showInSnackBar(context.l10n.registerError);
                break;
              case AuthErrorEnum.validateErrorRegister:
                // Handle validation error here.
                showInSnackBar(context.l10n.validateEmail);
                break;
              case AuthErrorEnum.wrongAppUser:
                break;
              case AuthErrorEnum.loginError:
                break;
              case AuthErrorEnum.validateError:
                break;
              case AuthErrorEnum.registerError:
                break;
              case AuthErrorEnum.forgotLoginError:
                break;
              case AuthErrorEnum.forgotEmailError:
                break;
              case AuthErrorEnum.forgotValidateEmailError:
                break;
            }
          }
          if (state is AuthRegistered) {
            showInSnackBar(context.l10n.validate);
            Future.delayed(const Duration(seconds: 5), () async {
              Navigator.pop(context, emailController.text.trim());
            });
          }
        },
        builder: (context, state) {
          return registerForm();
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
