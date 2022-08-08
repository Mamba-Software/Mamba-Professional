//YourBrand class used to have a list of your brands
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import '../../../../Data/Models/Brand.dart';
import '../../../../Screens/Authentication/SplashScreen.dart';
import '../../Components/Images/CircularImage.dart';
import '../LoadingViews/SplashScreenView.dart';

class YourBrandsListTile extends StatefulWidget {

  List<Brand> brands;

  // Screen Dimensions
  var safeAreaHeight;
  var safeAreaWidth;

  YourBrandsListTile(
      {Key? key, required this.brands, required this.safeAreaHeight, required this.safeAreaWidth})
      : super(key: key);

  @override
  _YourBrandsListTileState createState() => _YourBrandsListTileState();
}



class _YourBrandsListTileState extends State<YourBrandsListTile> {

  late Brand brand;

  @override
  void initState() {
    brand = currentBrand;
  }

  @override
  Widget build(BuildContext context) {
    /*
    return ListView.builder(
        itemCount: widget.brands.length,
        itemBuilder: (context, index) {
          Brand brand;
          brand = widget.brands[index];

     */
    return Container(
      height: widget.safeAreaHeight*0.15 * widget.brands.length,
      width: widget.safeAreaHeight*0.5,
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey)
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.safeAreaWidth*0.03, vertical: widget.safeAreaWidth * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
                AppLocalizations.of(context)!.yourBrands,
                style: Theme.of(context).textTheme.headline1,
                textAlign: TextAlign.center
            ),
    Expanded(
      child: ListView.builder(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
      itemCount: widget.brands.length,
      itemBuilder: (context, index) {
        Brand brand;
        brand = widget.brands[index];
        return Container(
          child:Padding(
            padding: EdgeInsets.symmetric(vertical: widget.safeAreaWidth * 0.03),
            child: ListTile(
              leading: CircleAvatar(
                  child: CircularImage(size: widget.safeAreaHeight * 0.08,
                    image: currentUser.imageUrl,
                    color: Theme
                        .of(context)
                        .backgroundColor,
                    borderWidth: 2,)
              ),
              title: Text(
                  brand.name!,
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyText2
                      ?.copyWith(color: Theme
                      .of(context)
                      .primaryColor,)
              ),
              onTap: () {
                setState(() {
                  currentBrand = brand;
                  Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute<Null>(
                        builder: (context) => SplashScreen(),
                        settings: RouteSettings(name: 'SplashScreen'),
                      )
                  );
                });
              },
            ),
          ),
        );
      }
      ),
    ),
            /*
            Flexible(
              child: ListTile(
                leading: CircleAvatar(
                    child: CircularImage(size: widget.safeAreaHeight * 0.08,
                      image: currentUser.imageUrl,
                      color: Theme
                          .of(context)
                          .backgroundColor,
                      borderWidth: 2,)
                ),
                title: Text(
                    brand.name!,
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyText2
                        ?.copyWith(color: Theme
                        .of(context)
                        .primaryColor,)
                ),
                onTap: () {
                  setState(() {
                    mambaProfessional = true;
                  });
                },
              ),
            ),

             */
          ],
        ),
      ),
    );


    //}
    //);
  }
}
