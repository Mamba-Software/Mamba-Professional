import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Utils/Date/DateTimeUtils.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/01-Qui/001-Trainers/RolesInfo.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/01-Qui/015-AddMembers/ShareBrandLink.dart';
import '../../../../../../Data/Models/Usuario.dart';
import '../../../../../../Globals/Widgets/Components/Images/CircularImage.dart';


class BrandRoles extends StatefulWidget {
  String brandId;
  List<Usuario> trainers;

  BrandRoles({Key? key, required this.brandId, required this.trainers}) : super(key: key);

  @override
  _BrandRolesState createState() => _BrandRolesState();
}

class _BrandRolesState extends State<BrandRoles> {
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
    allMembers = widget.trainers;
    // Get List of All Trainers
    orderTrainersByRole(allMembers);
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
                            AppLocalizations.of(context)!.roles,
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
          AppLocalizations.of(context)!.roles,
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
              // Add Staff
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet<void>(
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
                            heightFactor: 0.8,
                            child: ShareBrandLink(
                              onlyStaff: true,
                            ),
                          );
                        },
                      );
                    },
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            color: Theme.of(context).colorScheme.secondary,
                            size: MediaQuery.of(context).size.width*0.10,
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width*0.05),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.add+" "+AppLocalizations.of(context)!.staff.toLowerCase(),
                                  style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  AppLocalizations.of(context)!.shareInvitationText.split(AppLocalizations.of(context)!.clients.toLowerCase())[0]+AppLocalizations.of(context)!.trainers.toLowerCase()+AppLocalizations.of(context)!.shareInvitationText.split(AppLocalizations.of(context)!.clients.toLowerCase())[1],
                                  style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.secondary),
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                  Divider(color: Theme.of(context).backgroundColor, thickness: 2, indent: MediaQuery.of(context).size.width*0.05, endIndent: MediaQuery.of(context).size.width*0.05),
                  SizedBox(height: MediaQuery.of(context).size.height*0.01)
                ],
              ),
              // Owners
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(10))
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.owner,
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.left,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.info_outline,
                              color: Theme.of(context).primaryColor,
                              size: MediaQuery.of(context).size.width*0.06,
                            ),
                            splashColor: Colors.transparent,
                            onPressed: navigateToRolesInformationModal,
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02),
                        scrollDirection: Axis.vertical,
                        itemCount: allOwners.length,
                        itemBuilder: (context, index) {
                          Usuario user = allOwners[index];
                          DateTime dateJoined = DateTimeUtils().formatStringToDateTimeDDMMYY(user.dateJoined!, Localizations.localeOf(context).languageCode);
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02, vertical: MediaQuery.of(context).size.width * 0.01),
                            child: ListTile(
                              leading: CircularImage(
                                size: MediaQuery.of(context).size.width*0.15,
                                image: user.imageUrl,
                                color: Theme.of(context).primaryColor,
                                borderWidth: 1.0,
                              ),
                              title: Text(
                                getUsersFullName(user),
                                style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.lastEventAt == null ? AppLocalizations.of(context)!.lastActiveIn(DateTimeUtils().formatDateTimeToStringMMMYYYY(dateJoined, Localizations.localeOf(context).languageCode)) :
                                    AppLocalizations.of(context)!.lastActiveIn(DateTimeUtils().formatDateTimeToStringMMMYYYY(user.lastEventAt!.toDate(), Localizations.localeOf(context).languageCode)),
                                    style: Theme.of(context).textTheme.caption,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                              trailing: Icon(Icons.edit, color: user.id! != currentUser.id ? Theme.of(context).primaryColor : Theme.of(context).backgroundColor, size: MediaQuery.of(context).size.width*0.05,),
                              onTap: () async {
                                await onEditTrainerRole(user);
                              },
                            ),
                          );
                        }
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.width * 0.05),
              // Admins
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    borderRadius:
                    const BorderRadius.all(Radius.circular(10))
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.administrador,
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.left,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.info_outline,
                              color: Theme.of(context).primaryColor,
                              size: MediaQuery.of(context).size.width*0.06,
                            ),
                            splashColor: Colors.transparent,
                            onPressed: navigateToRolesInformationModal,
                          ),
                        ],
                      ),
                    ),
                    allAdmins.isNotEmpty ? ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02),
                        itemCount: allAdmins.length,
                        itemBuilder: (context, index) {
                          Usuario user = allAdmins[index];
                          DateTime dateJoined = DateTimeUtils().formatStringToDateTimeDDMMYY(user.dateJoined!, Localizations.localeOf(context).languageCode);
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02, vertical: MediaQuery.of(context).size.width * 0.01),
                            child: ListTile(
                              leading: CircularImage(
                                size: MediaQuery.of(context).size.width*0.15,
                                image: user.imageUrl,
                                color: Theme.of(context).primaryColor,
                                borderWidth: 1.0,
                              ),
                              title: Text(
                                getUsersFullName(user),
                                style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.lastEventAt == null ? AppLocalizations.of(context)!.lastActiveIn(DateTimeUtils().formatDateTimeToStringMMMYYYY(dateJoined, Localizations.localeOf(context).languageCode)) :
                                    AppLocalizations.of(context)!.lastActiveIn(DateTimeUtils().formatDateTimeToStringMMMYYYY(user.lastEventAt!.toDate(), Localizations.localeOf(context).languageCode)),
                                    style: Theme.of(context).textTheme.caption,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                              trailing: Icon(Icons.edit, color: user.id! != currentUser.id ? Theme.of(context).primaryColor : Theme.of(context).backgroundColor, size: MediaQuery.of(context).size.width*0.05,),
                              onTap: () async {
                                await onEditTrainerRole(user);
                              },
                            ),
                          );
                        }
                    ) : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height*0.005),
                        Text(AppLocalizations.of(context)!.noData, style: Theme.of(context).textTheme.caption, textAlign: TextAlign.center,),
                        SizedBox(height: MediaQuery.of(context).size.width * 0.05)
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.width * 0.05),
              // Trainers
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    borderRadius:
                    const BorderRadius.all(Radius.circular(10))
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.trainer,
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.left,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.info_outline,
                              color: Theme.of(context).primaryColor,
                              size: MediaQuery.of(context).size.width*0.06,
                            ),
                            splashColor: null,
                            onPressed: navigateToRolesInformationModal,
                          ),
                        ],
                      ),
                    ),
                    allTrainers.isNotEmpty ? ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: allTrainers.length,
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02),
                        itemBuilder: (context, index) {
                          Usuario user = allTrainers[index];
                          DateTime dateJoined = DateTimeUtils().formatStringToDateTimeDDMMYY(user.dateJoined!, Localizations.localeOf(context).languageCode);
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02, vertical: MediaQuery.of(context).size.width * 0.01),
                            child: ListTile(
                              leading: CircularImage(
                                size: MediaQuery.of(context).size.width*0.15,
                                image: user.imageUrl,
                                color: Theme.of(context).primaryColor,
                                borderWidth: 1.0,
                              ),
                              title: Text(
                                getUsersFullName(user),
                                style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.lastEventAt == null ? AppLocalizations.of(context)!.lastActiveIn(DateTimeUtils().formatDateTimeToStringMMMYYYY(dateJoined, Localizations.localeOf(context).languageCode)) :
                                    AppLocalizations.of(context)!.lastActiveIn(DateTimeUtils().formatDateTimeToStringMMMYYYY(user.lastEventAt!.toDate(), Localizations.localeOf(context).languageCode)),
                                    style: Theme.of(context).textTheme.caption,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                              trailing: Icon(Icons.edit, color: user.id! != currentUser.id ? Theme.of(context).primaryColor : Theme.of(context).backgroundColor, size: MediaQuery.of(context).size.width*0.05,),
                              onTap: () async {
                                await onEditTrainerRole(user);
                              },
                            ),
                          );
                        }
                    ) : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height*0.005),
                        Text(AppLocalizations.of(context)!.noData, style: Theme.of(context).textTheme.caption, textAlign: TextAlign.center,),
                        SizedBox(height: MediaQuery.of(context).size.width * 0.05)
                      ],
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

  @override
  void dispose() {
    super.dispose();
  }
}
