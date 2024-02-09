import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:mamba_castelldefels/Stripe/bloc/stripe_connect_bloc/stripe_connect_cubit.dart';

class OnboardingWebView extends StatelessWidget {
  OnboardingWebView({super.key});
  late WebViewController controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connecting to Stripe ...'),
      ),
      body: BlocConsumer<StripeConnectCubit, StripeConnectState>(
        listener: (context, state) {
          if (state is StripeConnectSuccess) {
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
          if (state is StripeConnectGettingLink ||
              state is StripeConnectInitial ||
              state is Loading ||
              state is StripeConnectWebLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StripeConnectGetLinkSuccess ||
              state is StripeConnectWebLoaded) {
            return WebViewWidget(
              controller: controller,
            );
          } else if (state is StripeConnectGetLinkError) {
            return Center(child: Text(state.error));
          } else {
            return Center(child: Text('Something went wrong'));
          }
        },
      ),
    );
  }
}
