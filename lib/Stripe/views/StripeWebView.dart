import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:mamba_castelldefels/Stripe/bloc/stripe_connect_bloc/stripe_connect_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StripeWebView extends StatefulWidget {
  StripeWebView({super.key});
  @override
  _StripeWebViewState createState() => _StripeWebViewState();
}

class _StripeWebViewState extends State<StripeWebView> {
  // Page View Controller
  final int _numPages = 3;
  PageController? _pageController;
  int? _currentPage;
  // Stripe Web View Controller
  late WebViewController controller;

  // Build Page Indicator
  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  // Page Indicator
  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: isActive ? 6.0 : 4.0,
      width: isActive ? 6.0 : 4.0,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).primaryColor
            : Theme.of(context).primaryColor.withOpacity(0.5),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StripeConnectCubit, StripeConnectState>(
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
              context.read<StripeConnectCubit>().emit(StripeConnectWebLoaded());
            });
        }
      },
      builder: (context, state) {
        if (state is StripeConnectGettingLink ||
            state is StripeConnectInitial ||
            state is Loading ||
            state is StripeConnectWebLoading) {
          return Center(
            child: LoadingView(
              color: Theme.of(context).primaryColor,
              hasLogo: false,
              isSmall: true,
            ),
          );
        } else if (state is StripeConnectGetLinkSuccess ||
            state is StripeConnectWebLoaded) {
          return Scaffold(            
            backgroundColor: AppColors.darkGrey,
            body: WebViewWidget(
                          controller: controller,
                        ),);
        } else if (state is StripeConnectGetLinkError) {
          return Center(child: Text(state.error));
        } else {
          return Center(child: Text('Something went wrong'));
        }
      },
    );
  }
}
