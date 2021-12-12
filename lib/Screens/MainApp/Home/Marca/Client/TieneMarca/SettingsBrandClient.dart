import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Dialogs/ConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/BrandLocations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/MyLocations.dart';
import 'package:mamba_castelldefels/Models/Conversation.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:mamba_castelldefels/Providers/LanguageProvider.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';

class SettingsBrandClient extends StatefulWidget {
  const SettingsBrandClient({Key? key}) : super(key: key);
  @override
  _SettingsBrandClientState createState() => _SettingsBrandClientState();
}

class _SettingsBrandClientState extends State<SettingsBrandClient> {

  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Boolean Loading
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
      Scaffold(
        appBar: null,
        body: LoadingViewPurple(),
      )
        :
      Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.settings, style: Theme.of(context).appBarTheme.titleTextStyle,),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 25,),
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.07),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.info,
                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeftWithFade,
                            child: BrandLocations(
                              brandId: currentBrand.id!,
                            ),
                          )
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined, color: Theme.of(context).primaryColor),
                        SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)!.brandLocations(currentBrand.name!),
                          style: Styles.purpleTextStyle,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  TextButton(
                    onPressed: () async {
                      // DeleteDialog
                      var result = await showDialog(
                          context: context,
                          builder: (_) {
                            return ConfirmationDialog(text: AppLocalizations.of(context)!.exitBrandConfirm);
                          }
                      );
                      if (result) {
                        NotificationService().userLeavesBrand(currentUser.id!, currentUser.brandID!);
                        Conversation conv = await _accessDatabase.getConversationByBrand(currentUser.brandID); //12/12/2021
                        await _accessDatabase.deleteUserFromAllBrandEvents(currentUser.id!, currentUser.brandID!, currentUser.isTrainer!);
                        await _accessDatabase.leaveBrand(currentUser.id!);
                        //12/12/2021
                        for(int i = 0; i < conv.users.length; ++i) {
                          if(conv.users[i]['uid'] == currentUser.id) {
                            conv.users.removeAt(i);
                          }
                        }
                        await _accessDatabase.updateConversationUsers(conv.conversationId, conv.users);
                         Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute<Null>(
                              builder: (context) =>
                                  SplashScreen(),
                              settings: RouteSettings(
                                  name: 'SplashScreen'),
                            )
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)!.exitBrand,
                          style: Styles.purpleTextStyle.copyWith(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
