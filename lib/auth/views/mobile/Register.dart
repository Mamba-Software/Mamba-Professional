import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/auth/cubit/AuthCubit.dart';
import 'package:mamba/auth/utils/enumAuth.dart';
import 'package:mamba/auth/widgets/mobile/NormalRegister.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/commons/managers/language_manager.dart';

// Register Page that allows the User to create his profile. This is the same for Client and Trainer.
// After registering the page pop´s after 5 seconds and the user is sent to the Login page. Before Login in
// they need to verify his email.
class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // Access to DataBaseService
  final _userDataService = UserDataService();
  // Password Visible
  bool isLoading = false;
  // Scaffold Messenger Key
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  // FormVariables
  final _formKey = GlobalKey<FormState>();
  // Email
  String email = '';
  String? emailTemp;
  // Password
  bool _passwordVisible = false;
  String password1 = '';
  String password2 = '';
  FocusNode focusNodePassword1 = FocusNode();
  FocusNode focusNodePassword2 = FocusNode();

  @override
  void initState() {
    mixpanel!.track('mamba_register_view');
    mixpanel!.timeEvent('mamba_register_completed');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.l10n.createAccount,
            style: Theme.of(context)
                .textTheme
                .displaySmall!
                .copyWith(color: Colors.white),
          ),
          centerTitle: false,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          iconTheme: const IconThemeData(
            color: Colors.white, //change your color here
          ),
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
          backgroundColor: AppColors.black,
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
                      onFieldSubmitted: (val) {
                        focusNodePassword1.requestFocus();
                      },
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.white),
                      decoration: InputDecoration(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.passwordError,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.white),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  TextFormField(
                      focusNode: focusNodePassword1,
                      validator: (val) =>
                          val!.length < 6 ? context.l10n.passwordError : null,
                      onChanged: (val) {
                        setState(() => password1 = val);
                      },
                      onFieldSubmitted: (val) {
                        focusNodePassword2.requestFocus();
                      },
                      obscureText: !_passwordVisible,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.white),
                      decoration: InputDecoration(
                          labelText: context.l10n.password,
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
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  })),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(0.0),
                            child: Icon(
                              Icons.vpn_key_outlined,
                              color: AppColors.white,
                            ), // icon is 48px widget.
                          ))),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  TextFormField(
                      focusNode: focusNodePassword2,
                      validator: (val) => val == password1
                          ? null
                          : context.l10n.passwordNotSameError,
                      onChanged: (val) {
                        setState(() => password2 = val);
                      },
                      obscureText: !_passwordVisible,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.white),
                      decoration: InputDecoration(
                          labelText: context.l10n.passworRepeat,
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
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  })),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(0.0),
                            child: Icon(
                              Icons.vpn_key_outlined,
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
    return normalRegister(context, state, _formKey, email, password1);
  }

  // Validate email and pwd format
  bool emailValidator(String value) {
    Pattern pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern.toString());
    if (!regex.hasMatch(value)) {
      return false;
    } else {
      return true;
    }
  }

  void onSignUpButtonPressed() {
    setState(() {
      isLoading = true;
    });
    if (emailValidator(email)) {
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
      signUp();
    } else {
      setState(() {
        isLoading = false;
      });
      showInSnackBar(context.l10n.validateEmail);
    }
  }

  void signUp() async {
    var result = await _userDataService.addUser(email.trim(), password1,
        Localizations.localeOf(context).languageCode, true);
    if (result == 0) {
      setState(() {
        isLoading = false;
      });
      showInSnackBar(context.l10n.validate);
      mixpanel!.track('mamba_register_completed');
      Future.delayed(const Duration(seconds: 5), () async {
        Navigator.pop(context, email.trim());
      });
    } else if (result == -1) {
      setState(() {
        isLoading = false;
      });
      mixpanel!.track('mamba_register_existing_email_error');
      showInSnackBar(context.l10n.sameEmail);
    } else {
      setState(() {
        isLoading = false;
      });
      showInSnackBar(context.l10n.registerError);
    }
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
