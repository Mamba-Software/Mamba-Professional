import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    // Check the current state directly and handle it if necessary
    final currentState = context.read<StripeConnectCubit>().state;
    if (currentState is StripeConnectGetLinkSuccess) {
      // Handle the state as needed, similar to what's done in the listener
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
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
          ),
        )
        ..loadRequest(Uri.parse(currentState.url)).then(
          (value) {
            context.read<StripeConnectCubit>().emit(StripeConnectWebLoaded());
          },
        );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.04,
        backgroundColor:
            Theme.of(context).colorScheme.secondary.withOpacity(0.33),
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<StripeConnectCubit, StripeConnectState>(
        listener: (context, state) {
          if (state is StripeConnectSuccess) {
            Navigator.pop(context, state.user);
          }
        },
        builder: (context, state) {
          if (state is Loading ||
              state is StripeConnectGettingLink ||
              state is StripeConnectInitial ||
              state is StripeConnectGetLinkSuccess ||
              state is StripeConnectWebLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StripeConnectWebLoaded) {
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
