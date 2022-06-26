import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:store_redirect/store_redirect.dart';

import '../../../Components/Images/CircularImage.dart';
import '../../LoadingViews/LoadingViewPurple.dart';

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

  @override
  Widget build(BuildContext context) {
    return isLoading ?
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Container(
          height: MediaQuery.of(context).size.height*0.3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              LoadingViewPurple(),
            ],
          ),
        ),
      )
        :
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Container(
          padding: EdgeInsets.only(top: 80, bottom: 10, left: 10, right: 10),
          height: MediaQuery.of(context).size.height*0.3,
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
                    padding: const EdgeInsets.only(top: 8.0, bottom: 24.0, right: 10, left: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(" holahgoalhasldkfjalsjkdlf", style: Theme.of(context).textTheme.bodyText2?.copyWith(height: 1.5),textAlign: TextAlign.center,),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton.icon(
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
                            AppLocalizations.of(context)!.accept,
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                          ),
                          icon: Icon(Icons.check_circle_outline, size: MediaQuery.of(context).size.width*0.06, color: Colors.white,),
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width*0.01),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            elevation: 4.0,
                            backgroundColor: Colors.red,
                            fixedSize: Size(MediaQuery.of(context).size.width*0.35, MediaQuery.of(context).size.height*0.06),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                            ),
                          ),
                          label: Text(
                            AppLocalizations.of(context)!.delete,
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                          ),
                          icon: Icon(Icons.cancel_outlined, size: MediaQuery.of(context).size.width*0.06,color: AppColors.white),
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                  bottom: 0,
                  top: -150,
                  child: Column(
                    children: <Widget>[
                      CircularImage(
                        size: MediaQuery.of(context).size.width*0.25,
                        image: brand.logoUrl,
                        color: Theme.of(context).accentColor,
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