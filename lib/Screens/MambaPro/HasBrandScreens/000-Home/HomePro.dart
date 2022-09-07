import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/RectangularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/04-Quan/010-Calendar/BrandCalendarWeekWidget.dart';
import 'package:provider/provider.dart';

import '../../../../Globals/Providers/ThemeProvider.dart';

class HomePro extends StatefulWidget {
  String brandId;
  int numClients;
  int numTrainers;

  HomePro({Key? key, required this.brandId, required this.numTrainers, required this.numClients}) : super(key: key);

  @override
  _HomePro createState() => _HomePro();
}

class _HomePro extends State<HomePro> {

  // Brand Data Service
  final _brandDataService = BrandDataService();
  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    return _scrollController!.hasClients && _scrollController!.offset > (MediaQuery.of(context).size.height*0.22 - kToolbarHeight);
  }
  // Boolean Loading
  bool isLoading = false;
  // Brand Image
  String imageUrl = currentBrand.logoUrl!;

  @override
  initState() {
    super.initState();
    _scrollController = ScrollController()
    ..addListener(() => _isAppBarExpanded ?
    setState(() {
      appBarExpanded = true;
    }) :
    setState(() {
      appBarExpanded = false;
    }),
    );
    getBrandImage();
  }

  Future<void> getBrandImage() async {
    var temp = await _brandDataService.getRandomBrandPhoto(currentBrand.id!);
    setState(() {
      imageUrl = temp;
    });
  }

  // Build Places Left Event
  SystemUiOverlayStyle returnSystemBarColor() {
    if (Platform.isAndroid) {
      return SystemUiOverlayStyle.light;
    } else {
      bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
      if (isDark) {
        return SystemUiOverlayStyle.light;
      } else {
        return !appBarExpanded ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height*0.22,
            elevation: 0,
            systemOverlayStyle: returnSystemBarColor(),
            floating: true,
            pinned: true,
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: RectangularImage(
                height: MediaQuery.of(context).size.height*0.3,
                width: MediaQuery.of(context).size.width,
                image: imageUrl,
              ),
              titlePadding: EdgeInsets.zero,
            ),
            leadingWidth: MediaQuery.of(context).size.width*0.2,
            leading: Builder(
              builder: (BuildContext innerContext) => Padding(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.02),
                child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: AppColors.white,
                      size: MediaQuery.of(context).size.height*0.04,
                    ),
                    onPressed: () => mambaProScaffoldKey.currentState?.openDrawer()
                ),
              ),
            ),
          ),
          isLoading ? SliverFillRemaining(
            child: Center(
                child: LoadingView()
            )
          ) : SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.0, horizontal:  MediaQuery.of(context).size.width*0.04,),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.04),
                      child: Text(
                        AppLocalizations.of(context)!.calendarWeekBrandText(currentBrand.name!),
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.01,
                    ),
                    BrandCalendarWeekWidget(brandId: widget.brandId, width: MediaQuery.of(context).size.width*0.90, height: MediaQuery.of(context).size.height*0.4,),
                    SizedBox(height: MediaQuery.of(context).size.height*0.05),

                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.01,
                    ),
                    BrandCalendarWeekWidget(brandId: widget.brandId, width: MediaQuery.of(context).size.width*0.90, height: MediaQuery.of(context).size.height*0.4,),
                    SizedBox(height: MediaQuery.of(context).size.height*0.05),
                  ]
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}