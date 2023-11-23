import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
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
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? AppColors.white : AppColors.whiteTrans,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.black,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.05),
            child: PageView(
              physics: const ClampingScrollPhysics(),
              controller: _pageController,
              onPageChanged: (int page) {
                if (page == 0) {
                  mixpanel!.track('register_brand_onboarding_cover');
                } else if (page == 1) {
                  mixpanel!.track('register_brand_onboarding_info');
                } else if (page == 2) {
                  mixpanel!.track('register_brand_onboarding_location');
                } else if (page == 3) {
                  mixpanel!.track('register_brand_onboarding_workday');
                }
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
                                mixpanel!.track('register_brand_onboarding_skip');
                                Navigator.pop(context, true);
                              },
                              child: Text(
                                AppLocalizations.of(context)!.skip,
                                style: Theme.of(context).textTheme.headline3?.copyWith(color: AppColors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.05),
                          Container(
                            height: MediaQuery.of(context).size.height*0.3,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                      height: MediaQuery.of(context).size.height*0.2,
                                      decoration: new BoxDecoration(
                                          border: Border.all(
                                            width: 1,
                                            color: AppColors.white,
                                            style: BorderStyle.solid,
                                          ),
                                          shape: BoxShape.circle,
                                          image: new DecorationImage(
                                            fit: BoxFit.fitHeight,
                                            image: AssetImage(Constants.portadaCreateBrandIntro),
                                          ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.black.withOpacity(0.5),
                                            spreadRadius: 1,
                                            blurRadius: 1,
                                            offset: const Offset(0, 3), // changes position of shadow
                                          ),
                                        ],
                                      )
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                                  Text(
                                    "La Era Fitness",
                                    style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white, fontStyle: FontStyle.italic, fontSize: 28),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.04),
                          Text(
                            AppLocalizations.of(context)!.createBrandCover,
                            style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.02),
                          Container(
                            height: MediaQuery.of(context).size.height*0.1,
                            child: Text(
                              AppLocalizations.of(context)!.createBrandPortada,
                              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white),
                            ),
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
                                mixpanel!.track('register_brand_onboarding_skip');
                                Navigator.pop(context, true);
                              },
                              child: Text(
                                AppLocalizations.of(context)!.skip,
                                style: Theme.of(context).textTheme.headline3?.copyWith(color: AppColors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.05),
                          Container(
                            height: MediaQuery.of(context).size.height*0.3,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Image(
                                image: AssetImage(Constants.informationCreateBrandIntro),
                                width: MediaQuery.of(context).size.width,
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.05),
                          Text(
                            AppLocalizations.of(context)!.info,
                            style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.02),
                          Container(
                            height: MediaQuery.of(context).size.height*0.1,
                            child: Text(
                              AppLocalizations.of(context)!.createBrandInfo,
                              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white),
                            ),
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
                                mixpanel!.track('register_brand_onboarding_skip');
                                Navigator.pop(context, true);
                              },
                              child: Text(
                                AppLocalizations.of(context)!.skip,
                                style: Theme.of(context).textTheme.headline3?.copyWith(color: AppColors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.05),
                          Container(
                            height: MediaQuery.of(context).size.height*0.3,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Image(
                                image: AssetImage(Constants.locationCreateBrandIntro),
                                height: MediaQuery.of(context).size.height*0.3,
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.05),
                          Text(
                            AppLocalizations.of(context)!.createBrandBaseLocation,
                            style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.02),
                          Container(
                            height: MediaQuery.of(context).size.height*0.1,
                            child: Text(
                              AppLocalizations.of(context)!.createBrandLocation,
                              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white),
                            ),
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
                                style: Theme.of(context).textTheme.headline3?.copyWith(color: AppColors.black,),
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.05),
                          Container(
                            height: MediaQuery.of(context).size.height*0.3,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Image(
                                image: AssetImage(Constants.horarioCreateBrandIntro),
                                height: MediaQuery.of(context).size.height*0.3,
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.05),
                          Text(
                            AppLocalizations.of(context)!.createBrandWorkshift,
                            style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.02),
                          Container(
                            height: MediaQuery.of(context).size.height*0.1,
                            child: Text(
                              AppLocalizations.of(context)!.createBrandWorkshiftDescription,
                              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white),
                            ),
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
              mixpanel!.track('register_brand_onboarding_go');
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
          : const Text(''),
    );
  }
}
