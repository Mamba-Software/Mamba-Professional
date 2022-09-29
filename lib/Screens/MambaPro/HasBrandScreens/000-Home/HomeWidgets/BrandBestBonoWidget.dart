import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Bonos/BonosUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/BonoCard.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/AddEditBono.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef DateCallBack = void Function(int pageIndex);

class BrandBestBonoWidget extends StatefulWidget {
  String brandId;
  final DateCallBack navigateToPage;

  BrandBestBonoWidget({Key? key, required this.brandId, required this.navigateToPage}) : super(key: key);

  @override
  _BrandBestBonoWidgetState createState() => _BrandBestBonoWidgetState();
}

class _BrandBestBonoWidgetState extends State<BrandBestBonoWidget> {

  // Acceso a Base de Datos
  final _brandDataService = BrandDataService();
  // AlL Bonos
  Bono? bonoMostBuys;
  final _bonosUtils = BonosUtils();

  @override
  void initState() {
    super.initState();
  }

  // Navigate to Add Bonos
  Future<void> navigateToAddBonosScreen(Bono bono, Brand _brand, bool edit) async {
    await Navigator.push(
      context,
      CupertinoPageRoute<void>(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: AddEditBono(
            brand: _brand,
            bono: bono,
            edit: edit,
          ),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fitHeight,
      child: Material(
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            maxWidth: MediaQuery.of(context).size.width*0.84,
            minWidth: MediaQuery.of(context).size.width*0.84,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(15.0)),// BorderRadius
          ),// BoxDecoration
          child: Container(
            margin: const EdgeInsetsDirectional.only(start: 1, end: 1, bottom: 1, top: 1),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height,
              maxWidth: MediaQuery.of(context).size.width*0.84,
              minWidth: MediaQuery.of(context).size.width*0.84,
            ),
            padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.04),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),// BorderRadius
            ),// BoxDecoration
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.fitHeight,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height*0.04,
                    width: MediaQuery.of(context).size.width*0.84,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            widget.navigateToPage(5);
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.confirmation_number_outlined, size: MediaQuery.of(context).size.width*0.05, color: AppColors.grey,),
                              SizedBox(width: MediaQuery.of(context).size.width*0.02),
                              Text(
                                  AppLocalizations.of(context)!.bonos,
                                  style: Theme.of(context).textTheme.headline3?.copyWith(color: AppColors.grey),
                                  textAlign: TextAlign.center
                              ),
                            ],
                          ),
                        ),
                        bonoMostBuys == null ? Text("") : TextButton(
                          onPressed: null,
                          child: Text(
                              AppLocalizations.of(context)!.mostBuys,
                              style: Theme.of(context).textTheme.caption,
                              textAlign: TextAlign.center
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: _brandDataService.getAllBonosFromBrand(widget.brandId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return SizedBox(
                            height: MediaQuery.of(context).size.height*0.19,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                                child: LoadingView(
                                  isSmall: true,
                                  hasLogo: false,
                                )
                            )
                        );
                      } else {
                        bonoMostBuys = _bonosUtils.documentsToBonosMostBuys(snapshot.data!.docs);
                        if (bonoMostBuys != null) {
                          return Column(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.02,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: BonoCard(
                                      height: MediaQuery.of(context).size.height*0.18,
                                      width: MediaQuery.of(context).size.width*0.72,
                                      bono: bonoMostBuys!,
                                      brand: currentBrand,
                                      canExpand: false,
                                      onlyView: true,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.01,
                              ),
                            ],
                          );
                        } else {
                          return SizedBox(
                              height: MediaQuery.of(context).size.height*0.19,
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.01,
                                    ),
                                    Flexible(child: Text(AppLocalizations.of(context)!.noBonosCreated, style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.w400), textAlign: TextAlign.start)),
                                    TextButton(
                                      onPressed: () async {
                                        navigateToAddBonosScreen(
                                          Bono(color: "0", isActive: true, sessions: 0, opacity: 1, imageUrl: '', isDegradate: false,),
                                          currentBrand,
                                          false
                                        );
                                        await Future.delayed(const Duration(seconds: 1));
                                        widget.navigateToPage(5);
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.createFistBono,
                                        style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                          );
                        }
                      }
                    }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
