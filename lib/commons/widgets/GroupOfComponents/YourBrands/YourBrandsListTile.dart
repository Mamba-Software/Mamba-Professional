//YourBrand class used to have a list of your brands
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/l10n/language_manager.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/auth/views/mobile/SplashScreen.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/data/Models/Brand.dart';

class YourBrandsListTile extends StatefulWidget {
  List<Brand> brands;

  // Screen Dimensions
  var safeAreaHeight;
  var safeAreaWidth;

  YourBrandsListTile(
      {super.key,
      required this.brands,
      required this.safeAreaHeight,
      required this.safeAreaWidth});

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
      height: widget.safeAreaHeight * 0.15 * widget.brands.length,
      width: widget.safeAreaHeight * 0.5,
      decoration: BoxDecoration(border: Border.all(color: AppColors.grey)),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: widget.safeAreaWidth * 0.03,
            vertical: widget.safeAreaWidth * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(context.l10n.yourBrands,
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center),
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: widget.brands.length,
                  itemBuilder: (context, index) {
                    Brand brand;
                    brand = widget.brands[index];
                    return Container(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: widget.safeAreaWidth * 0.03),
                        child: ListTile(
                          leading: CircleAvatar(
                              child: CircularImage(
                            size: widget.safeAreaHeight * 0.08,
                            image: currentUser.imageUrl,
                            color: Theme.of(context).colorScheme.background,
                            borderWidth: 2,
                          )),
                          title: Text(brand.name!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  )),
                          onTap: () {
                            setState(() {
                              currentBrand = brand;
                              Navigator.pushReplacement(
                                  context,
                                  CupertinoPageRoute<Null>(
                                    builder: (context) => const SplashScreen(),
                                    settings: const RouteSettings(
                                        name: 'SplashScreen'),
                                  ));
                            });
                          },
                        ),
                      ),
                    );
                  }),
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
