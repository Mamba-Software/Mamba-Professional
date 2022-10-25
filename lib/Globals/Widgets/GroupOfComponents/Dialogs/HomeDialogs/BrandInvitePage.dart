import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/NoBrandScreens/BrandImagesContainer.dart';
import '../../../../../Screens/Authentication/SplashScreen.dart';
import '../../../../GlobalVars.dart';
import '../../../Components/Images/CircularImage.dart';

class BrandInvitePage extends StatefulWidget {
  String brandId;
  BrandInvitePage({Key? key, required this.brandId}) : super(key: key);

  @override
  _BrandInvitePageState createState() => _BrandInvitePageState();
}

class _BrandInvitePageState extends State<BrandInvitePage> {

  // Acceso a Base de Datos
  final _brandDataService = BrandDataService();
  // Boolean Loading
  bool isLoading = true;
  bool isBodyLoading = false;
  // Brand
  Brand brand = Brand();
  // List Trainers
  List<Usuario> brandTrainers = [];
  @override
  void initState() {
    initDialog();
    super.initState();
  }

  Future<void> initDialog() async {
    brand = await _brandDataService.getBrandDetails(widget.brandId);
    print(brand.imagesList);
    // Brand Trainers
    brandTrainers = await _brandDataService.getBrandTrainers(widget.brandId);
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
      role = 3;
    }
    await _brandDataService.addUserToBrand(currentUser.id!,widget.brandId, role);
    // Wait for CF
    await Future.delayed(const Duration(seconds: 3));
    // Push to Splash
    Navigator.pushReplacement(
        context,
        CupertinoPageRoute<Null>(
          builder: (context) => const SplashScreen(),
          settings: const RouteSettings(name: 'SplashScreen'),
        )
    );
    // Reset Dynamic Link
    dynamicLinkBrandId = null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLoading ? Column(
          children: [
            Expanded(child: LoadingView()),
          ],
        ) : SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: BrandImagesContainer(
                    height: MediaQuery.of(context).size.height * 0.2,
                    brand: brand,
                    images: brand.imagesList,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width*0.05),
                
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                  child: Row(
                    children: [
                      CircularImage(
                        size: MediaQuery.of(context).size.width*0.15,
                        image: brand.logoUrl,
                        borderWidth: 1,
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width*0.05),
                      Text(brand.name!, style: Theme.of(context).textTheme.headline1),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.03,
                ),
                
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.description,
                        style: Theme.of(context).textTheme.caption,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.02,
                ),                
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          brand.description!,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.staff,
                        style: Theme.of(context).textTheme.caption,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.01,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.15,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: brandTrainers.length,
                    itemBuilder: (context, int index) {
                      var user = brandTrainers[index];
                      return Padding(
                        padding: !(index == 0 || index == brandTrainers.length-1) ?
                        const EdgeInsets.symmetric(horizontal: 8.0) : (index == 0) ?
                        EdgeInsets.only(
                            left: MediaQuery.of(context).size.width*0.05,
                            right: 8.0
                        ) :
                        EdgeInsets.only(
                            right: brandTrainers.length != 1 ? MediaQuery.of(context).size.width*0.05 : 8.0,
                            left: 8.0
                        ),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height*0.2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CircularImage(
                                size: MediaQuery.of(context).size.width*0.18,
                                image: user.imageUrl,
                                color: Theme.of(context).primaryColor,
                                borderWidth: 1,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width*0.2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        user.name!,
                                        style: Theme.of(context).textTheme.bodyText2,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.memberSince(brand.dateJoined!),
                        style: Theme.of(context).textTheme.caption,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomSheet: !isLoading ? GestureDetector(
          onTap: () async {
            setState(() {
              isBodyLoading = true;
            });
            joinBrand();
          },
          child: Container(
              height: MediaQuery.of(context).size.height*0.1,
              width: double.infinity,
              color: Theme.of(context).primaryColor,
              child: isBodyLoading ? Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.06,
                  height: MediaQuery.of(context).size.height * 0.03,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColorDark,
                    strokeWidth: 2.5,
                  ),
                ),
              ) : Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.00),
                  child: Text(
                    AppLocalizations.of(context)!.join,
                    style: Theme.of(context).textTheme.headline1?.copyWith(color: Theme.of(context).primaryColorDark,),
                  ),
                ),
              )
          ),
        ) : const Text(''),
      );
  }

}