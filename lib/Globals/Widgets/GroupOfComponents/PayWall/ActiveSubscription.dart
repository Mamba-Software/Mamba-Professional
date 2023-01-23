import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Subscription.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/PayWall/PayWall.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/01-Qui/001-Trainers/RolesInfo.dart';
import '../../../../../../Data/Models/Usuario.dart';
import '../../../../../../Globals/Widgets/Components/Images/CircularImage.dart';


class ActiveSubscription extends StatefulWidget {
  Subscription subscription;
  String brandId;

  ActiveSubscription({Key? key, required this.subscription, required this.brandId}) : super(key: key);

  @override
  _ActiveSubscriptionState createState() => _ActiveSubscriptionState();
}

class _ActiveSubscriptionState extends State<ActiveSubscription> {
  // Acceso a Base de Datos
  final _brandDataService = BrandDataService();
  // Boolean
  bool hasChanged = false;
  // All Trainers
  List<Usuario> allMembers = [];
  // Trainers Roles
  List<Usuario> allOwners = [];
  List<Usuario> allAdmins = [];
  List<Usuario> allTrainers = [];

  @override
  initState() {
    super.initState();
  }

  Future<void> navigateToSubscriptionsScreen() async {
    //mixpanel!.track('brand_membership_requests_view');
    await Navigator.push(
        context,
        CupertinoPageRoute<bool?>(
          builder: (context) => PayWall(
            brandId: widget.brandId,
          ),
        )
    );
    setState(() {
    });
  }

  void orderTrainersByRole(List<Usuario> trainers) {
    List<Usuario> allOwners = [];
    List<Usuario> allAdmins = [];
    List<Usuario> allTrainers = [];
    for (var i=0; i< trainers.length; i++) {
      Usuario user = trainers[i];
      if (user.brandRole == 1) {
        allOwners.add(user);
      } else if (user.brandRole == 2) {
        allAdmins.add(user);
      } else {
        allTrainers.add(user);
      }
    }
    allOwners.sort((a, b) {
      return a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase());
    });
    allAdmins.sort((a, b) {
      return a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase());
    });
    allTrainers.sort((a, b) {
      return a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase());
    });
    setState(() {
      this.allOwners = allOwners;
      this.allAdmins = allAdmins;
      this.allTrainers = allTrainers;
    });
  }

  Future<void> onEditTrainerRole(Usuario trainer) async {
    await showModalBottomSheet<int?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateBottom) {
            return FractionallySizedBox(
              heightFactor: 0.33,
              child: SizedBox(height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                            'Suscripciones',
                            style: Theme.of(context).textTheme.caption,
                            textAlign: TextAlign.left
                        ),
                        dense: true,
                      ),
                      ListTile(
                        onTap: () async {
                          // Update the Check
                          setStateBottom(() {
                            trainer.brandRole = 1;
                          });
                          // Change the User Role
                          await _brandDataService.updateUserBrandRole(trainer.id!, widget.brandId, 1);
                          // Remove the old Trainer Object from AllMembers Array
                          allMembers.removeWhere((element) => element.id! == trainer.id!);
                          // Add New Trainer Obeject
                          allMembers.add(trainer);
                          // Call Init Function
                          orderTrainersByRole(allMembers);
                          // Has Changed
                          hasChanged = true;
                          Navigator.pop(context);
                        },
                        title: Text(
                            AppLocalizations.of(context)!.owner,
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.left
                        ),
                        trailing: trainer.brandRole == 1 ? SizedBox(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: Center(child: Icon(Icons.check, size:MediaQuery.of(context).size.width * 0.08,color: Theme.of(context).colorScheme.secondary)),
                        ) : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                      ),
                      ListTile(
                        onTap: () async {
                          // Update the Check
                          setStateBottom(() {
                            trainer.brandRole = 2;
                          });
                          // Change the User Role
                          await _brandDataService.updateUserBrandRole(trainer.id!, widget.brandId, 2);
                          // Remove the old Trainer Object from AllMembers Array
                          allMembers.removeWhere((element) => element.id! == trainer.id!);
                          // Add New Trainer Obeject
                          allMembers.add(trainer);
                          // Call Init Function
                          orderTrainersByRole(allMembers);
                          // Has Changed
                          hasChanged = true;
                          Navigator.pop(context);
                        },
                        title: Text(
                            AppLocalizations.of(context)!.administrador,
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.left
                        ),
                        trailing: trainer.brandRole == 2 ? SizedBox(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: Center(child: Icon(Icons.check, size:MediaQuery.of(context).size.width * 0.08,color: Theme.of(context).colorScheme.secondary)),
                        ) : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                      ),
                      ListTile(
                        onTap: () async {
                          // Update the Check
                          setStateBottom(() {
                            trainer.brandRole = 3;
                          });
                          // Change the User Role
                          await _brandDataService.updateUserBrandRole(trainer.id!, widget.brandId, 3);
                          // Remove the old Trainer Object from AllMembers Array
                          allMembers.removeWhere((element) => element.id! == trainer.id!);
                          // Add New Trainer Obeject
                          allMembers.add(trainer);
                          // Call Init Function
                          orderTrainersByRole(allMembers);
                          // Has Changed
                          hasChanged = true;
                          Navigator.pop(context);
                        },
                        title: Text(
                            AppLocalizations.of(context)!.trainer,
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.left
                        ),
                        trailing: trainer.brandRole == 3 ? SizedBox(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: Center(child: Icon(Icons.check, size:MediaQuery.of(context).size.width * 0.08,color: Theme.of(context).colorScheme.secondary)),
                        ) : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } ,
        );
      },
    );
  }

  String getUsersFullName(Usuario user) {
    return "${user.firstName} ${user.lastName}";
  }

  // Navigate to Bonos Request Screen
  void navigateToRolesInformationModal() async {
    mixpanel!.track('brand_trainers_roles_info');
    showModalBottomSheet<bool?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return const FractionallySizedBox(
          heightFactor: 0.935,
          child: RolesInfo()
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Suscripciones',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        /*
        actions: [
          Padding(
            padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.02),
            child: IconButton(
              icon: Icon(
                Icons.info_outline,
                color: Theme.of(context).primaryColor,
                size: MediaQuery.of(context).size.width*0.06,
              ),
              onPressed: navigateToRolesInformationModal,
            ),
          ),
        ],
        */
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: MediaQuery.of(context).size.width * 0.06,
          ),
          onPressed: () {
            Navigator.pop(context, hasChanged);
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05, vertical: MediaQuery.of(context).size.width * 0.05),
          child: Column(
            children: [
              // Owners
              Column(
                children: [
                  GestureDetector(
                    onTap: navigateToSubscriptionsScreen,
                    child: Container(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.05),
                      height: MediaQuery.of(context).size.height*0.1,
                      width: MediaQuery.of(context).size.width*0.9,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.card_membership,
                            color: Theme.of(context).colorScheme.secondary,
                            size: MediaQuery.of(context).size.width*0.10,
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width*0.05),
                          Flexible(
                            child:  Text(
                              'Tienes la subscripcion ' + widget.subscription.title!,
                              style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.secondary),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width*0.05),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  Divider(color: Theme.of(context).backgroundColor, thickness: 2, indent: MediaQuery.of(context).size.width*0.05, endIndent: MediaQuery.of(context).size.width*0.05),
                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                  getAll(),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                          context,
                          CupertinoPageRoute<bool?>(
                            builder: (context) =>
                                PayWall(
                                  brandId: widget.brandId,
                                ),
                          )
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.mainColor,
                          width: 1,
                        ),
                        borderRadius: BorderRadius
                            .circular(10),
                      ),
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.90,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.05,
                      child: Center(
                          child: Text(
                            'Ver más planes',
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyText1
                                ?.copyWith(
                                fontWeight: FontWeight
                                    .bold,
                                color: AppColors.black
                            ),
                          )

                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.width * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  Widget getAll()
  {
    return  Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal:  MediaQuery.of(context).size.height *
            0.005),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tienes todo',
              style: Theme.of(context)
                  .textTheme
                  .headline1
                  ?.copyWith(fontSize: 30, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            Text(
              'Desbloquea todo el potencial de mamba pro con una subscripción única',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1,
              textAlign: TextAlign.center,
            ),
            SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.03),
            listTileGetAll(Icons.all_inclusive, 'Todo ilimitado', 'Haz cosas muchas cosas para ser mejor en todo lo quye hagas'),
            listTileGetAll(Icons.model_training, 'Todo ilimitado', 'Haz cosas muchas cosas para ser mejor en todo lo quye hagas'),
            listTileGetAll(Icons.sports_mma, 'Todo ilimitado', 'Haz cosas muchas cosas para ser mejor en todo lo quy hagas'),
            listTileGetAll(Icons.local_fire_department, 'Todo ilimitado', 'Haz cosas muchas cosas para ser mejor en todo lo quy hagas'),
            listTileGetAll(Icons.quiz, 'Todo ilimitado', 'Haz cosas muchas cosas para ser mejor en todo lo quy hagas'),
            SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.01),
            Divider(color: Theme.of(context).dividerColor, thickness: 1.5),
          ],
        ),
      ),
    );
  }

  Widget listTileGetAll(var icon, String title, String subtitle)
  {
    return Padding(
      padding: EdgeInsets.only(bottom:  MediaQuery.of(context).size.height *
          0.01,),
      child: ListTile(
        leading: Icon(
          icon,
          size: 50,
        ),
        title: Text(
            title,
            style: Theme.of(context).textTheme.bodyText1,
            textAlign: TextAlign.left
        ),
        subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.caption
        ),
        dense: true,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
