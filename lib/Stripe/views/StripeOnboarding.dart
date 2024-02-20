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

class StripeOnboarding extends StatefulWidget {
  StripeOnboarding({super.key});
  @override
  _StripeOnboardingState createState() => _StripeOnboardingState();
}

class _StripeOnboardingState extends State<StripeOnboarding> {
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
            appBar: AppBar(
              surfaceTintColor: AppColors.darkGrey,
              backgroundColor: AppColors.darkGrey,
              toolbarHeight: MediaQuery.of(context).size.height * 0.02,
              systemOverlayStyle: Platform.isIOS
                  ? SystemUiOverlayStyle.light
                  : const SystemUiOverlayStyle(
                      statusBarBrightness: Brightness.light,
                      statusBarColor: Colors.transparent,
                      statusBarIconBrightness: Brightness.light,
                    ),
            ),
            backgroundColor: AppColors.darkGrey,
            body: Container(
              height: MediaQuery.of(context).size.height * 0.95,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  GestureDetector(                    
                    onVerticalDragStart: (DragDownDetails) {
                      Navigator.pop(context);
                    },
                    child: Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.007,
                          width: MediaQuery.of(context).size.width * 0.15,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.025),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _buildPageIndicator(),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width * 0.84,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _currentPage == 0
                            ? Flexible(
                                child: Text(
                                    "AppLocalizations.of(context)!.reviewBuy",
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge,
                                    textAlign: TextAlign.left),
                              )
                            : _currentPage == 1
                                ? Flexible(
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .paymentMethod,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayLarge,
                                        textAlign: TextAlign.left),
                                  )
                                : Flexible(
                                    child: Text(
                                        "${AppLocalizations.of(context)!.buy} ${AppLocalizations.of(context)!.rate.toLowerCase()}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayLarge,
                                        textAlign: TextAlign.left),
                                  ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                        switch (page) {
                          case 0:
                            mixpanel!.track('brand_bonos_buy_details');
                            break;
                          case 1:
                            mixpanel!.track('brand_bonos_buy_paymentMethod');
                            break;
                          case 2:
                            mixpanel!.track('brand_bonos_buy_request');
                            break;
                        }
                      },
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                              width: MediaQuery.of(context).size.width * 0.84,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Flexible(
                                    child: Text(
                                        "AppLocalizations.of(context)!.whichPaymentMethodText",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        textAlign: TextAlign.center),
                                  ),
                                ],
                              ),
                            ), // Pagos Intermediario
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.075),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                              width: MediaQuery.of(context).size.width * 0.84,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Flexible(
                                    child: Text(
                                        "AppLocalizations.of(context)!.whichPaymentMethodText",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        textAlign: TextAlign.center),
                                  ),
                                ],
                              ),
                            ), // Pagos Intermediario
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.075),
                          ],
                        ),
                        WebViewWidget(
                          controller: controller,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is StripeConnectGetLinkError) {
          return Center(child: Text(state.error));
        } else {
          return Center(child: Text('Something went wrong'));
        }
      },
    );
  }
}
