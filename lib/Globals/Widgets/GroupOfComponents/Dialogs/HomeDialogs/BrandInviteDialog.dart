import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:store_redirect/store_redirect.dart';

import '../../../../../Screens/Authentication/SplashScreen.dart';
import '../../../../GlobalVars.dart';
import '../../../Components/Images/CircularImage.dart';
import '../../LoadingViews/LoadingView.dart';

class BrandInviteDialog extends StatefulWidget {
  String brandId;
  BrandInviteDialog({Key? key, required this.brandId}) : super(key: key);

  @override
  _BrandInviteDialogState createState() => _BrandInviteDialogState();
}

class _BrandInviteDialogState extends State<BrandInviteDialog> {

  // Acceso a Base de Datos
  var _brandDataService = new BrandDataService();
  // Boolean Loading
  bool isLoading = true;
  bool isBodyLoading = false;
  // Brand
  Brand brand = Brand();

  @override
  void initState() {
    initDialog();
    super.initState();
  }

  Future<void> initDialog() async {
    brand = await _brandDataService.getBrandCoverDetails(widget.brandId);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> joinBrand() async {
    setState(() {
      isBodyLoading = true;
    });
    // Accept the user to Brand
    int role = 0;
    if (currentUser.isTrainer!) {
      role = 5;
    }
    await _brandDataService.addUserToBrand(currentUser.id!,widget.brandId, role);
    // Wait for CF
    await Future.delayed(const Duration(seconds: 3));
    // Push to Splash
    Navigator.pushReplacement(
        context,
        CupertinoPageRoute<Null>(
          builder: (context) => SplashScreen(),
          settings: RouteSettings(name: 'SplashScreen'),
        )
    );
    // Reset Dynamic Link
    dynamicLinkBrandId = null;
  }


  @override
  Widget build(BuildContext context) {
    return isLoading ?
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(MediaQuery.of(context).size.height*0.02),
        child: Container(
          height: MediaQuery.of(context).size.height*0.35,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              LoadingView(),
            ],
          ),
        ),
      )
        :
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(MediaQuery.of(context).size.height*0.02),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.1, bottom: MediaQuery.of(context).size.height*0.02, left: MediaQuery.of(context).size.height*0.02, right: MediaQuery.of(context).size.height*0.02),
          //height: MediaQuery.of(context).size.height*0.35,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.04, bottom: MediaQuery.of(context).size.height*0.03, right: 10, left: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context)!.brandInviteDialog,
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 0, bottom: MediaQuery.of(context).size.height*0.02, right: 10, left: 10),
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        elevation: 4.0,
                        backgroundColor: Colors.green,
                        fixedSize: Size(MediaQuery.of(context).size.width*0.35, MediaQuery.of(context).size.height*0.06),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                      ),
                      label: Text(
                        AppLocalizations.of(context)!.join,
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                      ),
                      icon: !isBodyLoading ? Icon(Icons.check_circle_outline, size: MediaQuery.of(context).size.width*0.06, color: Colors.white,) : Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.05,
                          height: MediaQuery.of(context).size.width * 0.05,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                      onPressed: () {
                        joinBrand();
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                  bottom: 0,
                  top: -MediaQuery.of(context).size.height*0.16,
                  child: Column(
                    children: <Widget>[
                      CircularImage(
                        size: MediaQuery.of(context).size.width*0.25,
                        image: brand.logoUrl,
                        color: Theme.of(context).colorScheme.secondary,
                        borderWidth: 2,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.02),
                      Container(
                        width: MediaQuery.of(context).size.width*0.9,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  brand.name!,
                                  style: Theme.of(context).textTheme.headline1?.copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
              ),
            ],
          ),
        ),
      );
  }

}