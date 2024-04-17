import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/Event/EventDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba/data/Models/Usuario.dart';

class DeleteFromBrandConfirmationDialog extends StatefulWidget {
  final String text;
  final String userId;
  const DeleteFromBrandConfirmationDialog(
      {super.key, required this.text, required this.userId});

  @override
  _DeleteFromBrandConfirmationDialogState createState() =>
      _DeleteFromBrandConfirmationDialogState();
}

class _DeleteFromBrandConfirmationDialogState
    extends State<DeleteFromBrandConfirmationDialog> {
  // Acceso a Base de Datos
  final _userDataService = UserDataService();
  final _eventDataService = EventDataService();
  final _brandDataService = BrandDataService();
  // Boolean Loading
  bool isLoading = false;
  bool isLoadingBody = false;
  // User Requesting
  Usuario user = Usuario();
  Brand? brand = Brand();

  @override
  void initState() {
    isLoading = true;
    getUser();
    super.initState();
  }

  // Gets the user info from firebase.
  void getUser() async {
    user = await _userDataService.getUserDetails(widget.userId);
    brand = currentBrand;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> deleteUser() async {
    await _eventDataService.deleteUserFromUpcomingEvents(
        widget.userId, user.isTrainer!);
    if (user.isTrainer! == false) {
      await _brandDataService.deleteUserBrandBonos(brand!.id!, widget.userId);
    }
    await _brandDataService.deleteUserFromBrand(widget.userId, brand!.id!);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  LoadingView(
                    hasLogo: false,
                    isSmall: true,
                  ),
                ],
              ),
            ),
          )
        : Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.only(
                  top: 80, bottom: 10, left: 10, right: 10),
              height: MediaQuery.of(context).size.height * 0.3,
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
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 24.0, right: 10, left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                widget.text,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(height: 1.5),
                                textAlign: TextAlign.center,
                              ),
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
                                backgroundColor: Colors.red,
                                fixedSize: Size(
                                    MediaQuery.of(context).size.width * 0.35,
                                    MediaQuery.of(context).size.height * 0.06),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30),
                                  ),
                                ),
                              ),
                              label: Text(
                                AppLocalizations.of(context)!.delete,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppColors.white),
                              ),
                              icon: isLoadingBody
                                  ? SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.05,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.025,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person_remove,
                                      size: MediaQuery.of(context).size.width *
                                          0.06,
                                      color: Colors.white,
                                    ),
                              onPressed: () async {
                                setState(() {
                                  isLoadingBody = true;
                                });
                                await deleteUser();
                                Navigator.pop(context, true);
                              },
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.01),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                elevation: 4.0,
                                backgroundColor: Theme.of(context).primaryColor,
                                fixedSize: Size(
                                    MediaQuery.of(context).size.width * 0.35,
                                    MediaQuery.of(context).size.height * 0.06),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30),
                                  ),
                                ),
                              ),
                              label: Text(
                                AppLocalizations.of(context)!.cancel,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                              ),
                              icon: Icon(
                                Icons.cancel_outlined,
                                size: MediaQuery.of(context).size.width * 0.06,
                                color: Theme.of(context).primaryColorDark,
                              ),
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
                            size: MediaQuery.of(context).size.width * 0.25,
                            image: user.imageUrl,
                            color: Theme.of(context).colorScheme.background,
                            borderWidth: 1,
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.03),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      user.name!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          );
  }
}
