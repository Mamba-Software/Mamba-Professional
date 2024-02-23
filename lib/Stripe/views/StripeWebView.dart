import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:mamba_castelldefels/Stripe/bloc/stripe_connect_bloc/stripe_connect_cubit.dart';

class StripeWebView extends StatefulWidget {
  const StripeWebView({super.key});

  @override
  State<StripeWebView> createState() => _StripeWebViewState();
}

class _StripeWebViewState extends State<StripeWebView> {
  late WebViewController controller;

  @override
  void initState() {
    // Check Initial Cubit State
    final initialState = context.read<StripeConnectCubit>().state;
    print("initialState");
    print(initialState);
    // Get the Stripe Link
    context.read<StripeConnectCubit>().getLink(currentBrand);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.04,
        backgroundColor:
            Theme.of(context).colorScheme.secondary.withOpacity(0.33),
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<StripeConnectCubit, StripeConnectState>(
        listener: (context, state) async {
          if (state is StripeConnectSuccess) {
            await Future.delayed(const Duration(milliseconds: 1000));
            Navigator.pop(context, state.user);
          }
          if (state is StripeConnectGetLinkSuccess) {
            controller = WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..setNavigationDelegate(NavigationDelegate(
                onNavigationRequest: (NavigationRequest request) {
                  if (request.url
                          .startsWith('https://www.mambafitness.es/return') ||
                      request.url
                          .startsWith('https://www.mambafitness.es/reauth/')) {
                    if (request.url
                        .startsWith('https://www.mambafitness.es/reauth')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please try again')));
                    }
                    context.read<StripeConnectCubit>().getUser();
                  }
                  return NavigationDecision.navigate;
                },
              ))
              ..loadRequest(Uri.parse(state.url)).then((value) {
                context
                    .read<StripeConnectCubit>()
                    .emit(StripeConnectWebLoaded());
              });
          }
        },
        builder: (context, state) {
          if (state is Loading ||
              state is StripeConnectGettingLink ||
              state is StripeConnectInitial ||
              state is StripeConnectGetLinkSuccess ||
              state is StripeConnectWebLoading) {
            return Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LoadingView(
                    color: AppColors.black,
                    hasLogo: false,
                    isSmall: true,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    AppLocalizations.of(context)!.stripeConnecting,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (state is StripeConnectWebLoaded) {
            return WebViewWidget(
              controller: controller,
            );
          } else if (state is StripeConnectSuccess) {
            return Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LoadingView(
                    color: AppColors.black,
                    hasLogo: false,
                    isSmall: true,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    AppLocalizations.of(context)!.stripeConnectionSuccessfull,                    
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );          
          } else if (state is StripeConnectGetLinkError) {
            return Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.report_outlined,
                    size: MediaQuery.of(context).size.width * 0.15,
                    color: AppColors.black,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    state.error,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          } else {
            return Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.report_outlined,
                    size: MediaQuery.of(context).size.width * 0.15,
                    color: AppColors.black,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    AppLocalizations.of(context)!.stripeError,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
