import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/TitleDescriptionWidget.dart';

Widget InformationPage(BuildContext context, FocusNode focusNodetitleController,
    final formKeyInfo) {
  return Scaffold(
    body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            Form(
              key: formKeyInfo,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.05),
                      child: Column(
                        children: [
                          TitleDescriptionWidget(
                            focusNodetitleController: focusNodetitleController,
                          )
                          /*
                            Padding(
                                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.05),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          AppLocalizations.of(context)!.location,
                                          style: Theme.of(context).textTheme.headline1,
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.018),
                              child: GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  var result = await Navigator.push(
                                      context,
                                      CupertinoPageRoute<String>(
                                        builder: (context) => MyLocationsSelect(
                                          brandId: currentBrand.id!,
                                        ),
                                      )
                                  );
                                  if (result != null) {
                                    getLocation(result);
                                  } else {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                },
                                child: Material(
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(15),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                                        borderRadius: const BorderRadius.all(Radius.circular(15.0))
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context).size.height*0.1,
                                          width: MediaQuery.of(context).size.height*0.1,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              bottomLeft: Radius.circular(15),
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              bottomLeft: Radius.circular(15),
                                            ),
                                            child: GoogleMap(
                                              onMapCreated: _onMapCreated,
                                              initialCameraPosition: _initialPosition,
                                              scrollGesturesEnabled: false,
                                              zoomGesturesEnabled: false,
                                              rotateGesturesEnabled: false,
                                              mapToolbarEnabled: false,
                                              zoomControlsEnabled: false,
                                              minMaxZoomPreference: const MinMaxZoomPreference(16,16),
                                              myLocationButtonEnabled: false,
                                              mapType: MapType.satellite,
                                              markers: markers,
                                              trafficEnabled: false,
                                              indoorViewEnabled: false,
                                              buildingsEnabled: false,
                                              onTap: null,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                                        LocationView(context, true, event!),
                                        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                                        Icon(Icons.swap_horiz, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.08),
                                        SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                             */
                        ],
                      ),
                    ),
                    /*
                      allBonos.isNotEmpty ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                        child: Column(
                          children: [
                            Padding(
                                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.05),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          AppLocalizations.of(context)!.bonos,
                                          style: Theme.of(context).textTheme.headline1,
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                            ),
                            Padding(
                                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01, bottom: MediaQuery.of(context).size.height*0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                      child: Text(
                                        AppLocalizations.of(context)!.bonosDescription,
                                        style: Theme.of(context).textTheme.caption,
                                      ),
                                    ),
                                  ],
                                )
                            ),
                            selectedBonos.isEmpty ? Container(
                              width: MediaQuery.of(context).size.width*0.9,
                              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.025, bottom: MediaQuery.of(context).size.height*0.01),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.red.withOpacity(0.2),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                border: Border.all(color: AppColors.red, width: 2),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outlined, color: AppColors.red, size:  MediaQuery.of(context).size.width*0.08,),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      AppLocalizations.of(context)!.bonosDescriptionWarning,
                                      textAlign: TextAlign.left,
                                      style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red, height: 1.3),
                                    ),
                                  ),
                                ],
                              ),
                            ) : Container(
                              width: MediaQuery.of(context).size.width*0.9,
                              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.025, bottom: MediaQuery.of(context).size.height*0.01),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                border: Border.all(color: Colors.green, width: 2),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outlined, color: Colors.green, size:  MediaQuery.of(context).size.width*0.08,),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      AppLocalizations.of(context)!.bonosDescriptionGreat,
                                      textAlign: TextAlign.left,
                                      style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.green, height: 1.3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  child: Text(
                                    AppLocalizations.of(context)!.selectAll,
                                    style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  style: TextButton.styleFrom(
                                    primary: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () async {
                                    FocusScopeNode currentFocus = FocusScope.of(context);
                                    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                    }
                                    for (var bono in allBonos) {
                                      int index = selectedBonos.indexWhere((element) => element == bono.id);
                                      if (index == -1) {
                                        setState(() {
                                          selectedBonos.add(bono.id!);
                                        });
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                            errorBonos? Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.01, right:  MediaQuery.of(context).size.width * 0.01),
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)!.deleteClientsWithPurchasesBonos,
                                  style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ) : Container(),
                            ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: allBonos.length,
                                itemBuilder: (context, int index) {
                                  var bono = allBonos[index];
                                  return Container(
                                    height: MediaQuery.of(context).size.height * 0.075,
                                    width: MediaQuery.of(context).size.width * 0.9,
                                    margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              BonoCard(
                                                height: MediaQuery.of(context).size.height * 0.05,
                                                width: MediaQuery.of(context).size.width * 0.18,
                                                bono: bono,
                                                brand: currentBrand,
                                                canExpand: false,
                                                onlyView: true,
                                                hideActive: true,
                                              ),
                                            ]
                                        ),
                                        SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                bono.title!.toUpperCase(),
                                                style: Theme.of(context).textTheme.bodyText1,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Flexible(
                                                child: Text(
                                                  (bono.sessions! == 10000 ? AppLocalizations.of(context)!.sessions+" "+AppLocalizations.of(context)!.ilimitadas : bono.sessions!.toString()+" "+AppLocalizations.of(context)!.sessions.toLowerCase())
                                                      +" desde "+bono.price!.toStringAsFixed(2)+"€",
                                                  style: Theme.of(context).textTheme.caption,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                                        SizedBox(
                                          height: MediaQuery.of(context).size.height * 0.034,
                                          width: MediaQuery.of(context).size.width * 0.1,
                                          child: MaterialButton(
                                            elevation: 4,
                                            color: selectedBonos.contains(bono.id!) ? Theme.of(context).primaryColor : Theme.of(context).backgroundColor,
                                            textColor: selectedBonos.contains(bono.id!) ? Theme.of(context).primaryColor : Theme.of(context).backgroundColor,
                                            child: selectedBonos.contains(bono.id!) ? Icon(Icons.check, color: Theme.of(context).primaryColorDark, size: MediaQuery.of(context).size.width*0.05) : SizedBox(height: MediaQuery.of(context).size.width*0.03, width: MediaQuery.of(context).size.width*0.03,),
                                            padding: EdgeInsets.zero,
                                            shape: const CircleBorder(),
                                            onPressed: () {
                                              FocusScopeNode currentFocus = FocusScope.of(context);
                                              if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                                                FocusManager.instance.primaryFocus?.unfocus();
                                              }
                                              setState(() {
                                                if (selectedBonos.contains(bono.id!)) {
                                                  if(brandClientsSelected.any((client) => client.purchaseId != "")) {
                                                    errorBonos = true;
                                                  }
                                                  else {
                                                    errorBonos = false;
                                                    selectedBonos.remove(bono.id!);
                                                  }
                                                } else {
                                                  selectedBonos.add(bono.id!);
                                                }
                                              });
                                            },
                                          ),
                                        ),

                                      ],
                                    ),
                                  );
                                }
                            ),
                          ],
                        ),
                      ) : Container(),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.15),

                       */
                  ]),
            ),
          ],
        )),
    resizeToAvoidBottomInset: true,
  );
}
