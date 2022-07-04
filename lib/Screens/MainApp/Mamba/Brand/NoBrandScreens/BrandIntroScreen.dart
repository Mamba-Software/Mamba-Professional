import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BrandIntroScreen extends StatefulWidget {
  @override
  _BrandIntroScreenState createState() => _BrandIntroScreenState();
}

class _BrandIntroScreenState extends State<BrandIntroScreen> {
  final int _numPages = 4;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? AppColors.white : AppColors.whiteTrans,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.mainColor
            /*
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.1, 0.4, 0.7, 0.9],
                colors: [
                  AppColors.mainColor,
                  AppColors.mainColorGrad1,
                  AppColors.mainColorGrad1,
                  AppColors.mainColorGrad2,
                ],
              ),
               */
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.05),
            child: PageView(
              physics: ClampingScrollPhysics(),
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: <Widget>[
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.height*0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              child: Text(
                                AppLocalizations.of(context)!.skip,
                                style: Theme.of(context).textTheme.headline3?.copyWith(color: AppColors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.05),
                          Center(
                            child: Image(
                              image: AssetImage(Constants.onboardingApp),
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.05),
                          Text(
                            'Connect people\naround the world',
                            style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white),
                          ),
                          SizedBox(height: 15.0),
                          Text(
                            'Lorem ipsum dolor sit amet, consect adipiscing elit, sed do eiusmod tempor incididunt ut labore et.',
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildPageIndicator(),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.height*0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              child: Text(
                                AppLocalizations.of(context)!.skip,
                                style: Theme.of(context).textTheme.headline3?.copyWith(color: AppColors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.05),
                          Center(
                            child: Image(
                              image: AssetImage(Constants.onboardingApp),
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.05),
                          Text(
                            'Connect people\naround the world',
                            style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white),
                          ),
                          SizedBox(height: 15.0),
                          Text(
                            'Lorem ipsum dolor sit amet, consect adipiscing elit, sed do eiusmod tempor incididunt ut labore et.',
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildPageIndicator(),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.height*0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              child: Text(
                                AppLocalizations.of(context)!.skip,
                                style: Theme.of(context).textTheme.headline3?.copyWith(color: AppColors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.05),
                          Center(
                            child: Image(
                              image: AssetImage(Constants.onboardingApp),
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.05),
                          Text(
                            'Connect people\naround the world',
                            style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white),
                          ),
                          SizedBox(height: 15.0),
                          Text(
                            'Lorem ipsum dolor sit amet, consect adipiscing elit, sed do eiusmod tempor incididunt ut labore et.',
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildPageIndicator(),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.height*0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: null,
                              child: Text(
                                AppLocalizations.of(context)!.skip,
                                style: Theme.of(context).textTheme.headline3?.copyWith(color: AppColors.mainColor),
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.05),
                          Center(
                            child: Image(
                              image: AssetImage(Constants.onboardingApp),
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.05),
                          Text(
                            'Connect people\naround the world',
                            style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white),
                          ),
                          SizedBox(height: 15.0),
                          Text(
                            'Lorem ipsum dolor sit amet, consect adipiscing elit, sed do eiusmod tempor incididunt ut labore et.',
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildPageIndicator(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: _currentPage == _numPages - 1
          ? GestureDetector(
            onTap: () {
              Navigator.pop(context, true);
            },
            child: Container(
                height: MediaQuery.of(context).size.height*0.1,
                width: double.infinity,
                color: Colors.white,
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.letsGo,
                    style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.black),
                  ),
                ),
              ),
          )
          : Text(''),
    );
  }
}
