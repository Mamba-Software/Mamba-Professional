import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/DynamicLinks/DynamicLinkUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/RequestConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Data/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/01-Qui/015-AddMembers/ShareBrandLink.dart';
import 'package:share_plus/share_plus.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class MembershipRequestsPro extends StatefulWidget {
  String brandId;
  bool pinned;
  ValueChanged<bool?> pinnedChanged;
  MembershipRequestsPro({Key? key, required this.brandId, required this.pinned, required this.pinnedChanged}) : super(key: key);

  @override
  _MembershipRequestsProState createState() => _MembershipRequestsProState();
}

class _MembershipRequestsProState extends State<MembershipRequestsPro> {

  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    return _scrollController!.hasClients && _scrollController!.offset > (MediaQuery.of(context).size.height*0.15 - kToolbarHeight);
  }

  // Acceso a Base de Datos
  final _brandDataService = BrandDataService();
  final _userDataService = UserDataService();
  String? brandId = '';

  // Boolean Loading
  bool isLoading = false;
  // Request List
  List<RequestToBrand> requestList = [];

  @override
  initState() {
    super.initState();
    _scrollController = ScrollController()
    ..addListener(() => _isAppBarExpanded ?
    setState(() {
      appBarExpanded = true;
    }) :
    setState(() {
      appBarExpanded = false;
    }),
    );
  }

  List<RequestToBrand> documentsToRequests(List<DocumentSnapshot> documents) {
    List<RequestToBrand> requests = [];
    for(int i = 0; i < documents.length; i++) {
      RequestToBrand request = RequestToBrand.fromObjectAllData(documents[i].id, documents[i]);
      requests.add(request);
    }
    /*
    for (var i=0; i< 10; i++) {
      RequestToBrand request = RequestToBrand.fromObjectAllData(documents[0].id, documents[0]);
      requests.add(request);
    }
    */
    return requests;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.darkGrey,
            expandedHeight: MediaQuery.of(context).size.height*0.15,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            elevation: 4,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                height: MediaQuery.of(context).size.height*0.15,
                color: AppColors.darkGrey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.025),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.myRequests,
                            style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white,),
                          ),
                          FittedBox(
                            fit: BoxFit.fitHeight,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height*0.08,
                              width: MediaQuery.of(context).size.width*0.11,
                              child: TextButton(
                                onPressed: null,
                                child: Icon(
                                  Icons.filter_list,
                                  color: AppColors.darkGrey,
                                  size: MediaQuery.of(context).size.width*0.07,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                    Container(
                      color: AppColors.grey,
                      height: 1.0,
                    ),
                  ],
                ),
              ),
              titlePadding: EdgeInsets.zero,
              //centerTitle: true,
            ),
            title: appBarExpanded ? Text(AppLocalizations.of(context)!.myRequests, style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(color: AppColors.white,),) : Container(),
            centerTitle: true,
            leading: Builder(
              builder: (BuildContext innerContext) => Padding(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.02),
                child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: AppColors.white,
                      size: MediaQuery.of(context).size.height*0.04,
                    ),
                    onPressed: () => mambaProScaffoldKey.currentState?.openDrawer()
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.01),
                child: IconButton(
                  icon: Icon(
                    widget.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: widget.pinned ? AppColors.red :  AppColors.white.withOpacity(0.5),
                    size: MediaQuery.of(context).size.width*0.06,
                  ),
                  onPressed: () {
                    setState(() {
                      widget.pinned = !widget.pinned;
                    });
                    widget.pinnedChanged(widget.pinned);
                  },
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.03),
                GestureDetector(
                  onTap: () async {
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
                          heightFactor: 0.7,
                          child: ShareBrandLink(),
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.05),
                    height: MediaQuery.of(context).size.height*0.15,
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
                          Icons.qr_code,
                          color: Theme.of(context).colorScheme.secondary,
                          size: MediaQuery.of(context).size.width*0.10,
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width*0.05),
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context)!.scanQRCode + " o " + AppLocalizations.of(context)!.copyCodeMessage.toLowerCase(),
                            style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.secondary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width*0.05),
                        Icon(Icons.mobile_screen_share, color: Theme.of(context).colorScheme.secondary, size: MediaQuery.of(context).size.width*0.1,)
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.02),
                Divider(color: Theme.of(context).backgroundColor, thickness: 2, indent: MediaQuery.of(context).size.width*0.05, endIndent: MediaQuery.of(context).size.width*0.05),                
              ],
            )
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _brandDataService.getBrandRequestsStream(widget.brandId),
            builder: (context, snapshot) {
              if (snapshot == null || snapshot.data == null || snapshot.data!.docs == null ) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                            child: LoadingView()
                        )
                      ),
                    ],
                  ),
                );
              } else {
                requestList = documentsToRequests(snapshot.data!.docs);
                if (requestList.isNotEmpty) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                      RequestToBrand request = requestList[index];
                      String type;
                      if (request.isTrainer!) {
                        type = AppLocalizations.of(context)!.trainer.toLowerCase();
                      } else {
                        type = AppLocalizations.of(context)!.client.toLowerCase();
                      }
                      return ListTile(
                        leading: Icon(request.isTrainer! ? Icons.record_voice_over : Icons.directions_run, color: Theme.of(context).primaryColor, size: 25,),
                        title: Container(
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyText2,
                              children: [
                                TextSpan(text: request.name!, style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold),),
                                TextSpan(text: AppLocalizations.of(context)!.requestFromUser(type), style: Theme.of(context).textTheme.bodyText2),
                              ],
                            ),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height*0.01),
                            Text(
                                AppLocalizations.of(context)!.requestSent(request.dateSent!),
                                style: Theme.of(context).textTheme.caption
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.help_outline, color: Theme.of(context).primaryColor, size: 30,),
                        onTap: () async {
                          var result = await showDialog(
                              context: context,
                              builder: (_) {
                                return RequestConfirmationDialog(
                                  text: AppLocalizations.of(context)!.requestConfirmation,
                                  userId: request.userId!,
                                );
                              }
                          );
                          if (result) {
                            NotificationService().userJoinsBrand(request.userId!, request.brandId!);
                            _brandDataService.acceptRequestFromUser(request);
                          } else if (!result) {
                            _userDataService.deleteRequestToBrand(request);
                          }
                        },
                      );
                    },
                      childCount: requestList.length,
                    ),
                  );
                } else {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width*0.30,
                            child: Image.asset(Constants.emptyCalendar)
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.005),
                        Text(AppLocalizations.of(context)!.noRequestsFound, style: Theme.of(context).textTheme.caption, textAlign: TextAlign.center,),
                        SizedBox(height: MediaQuery.of(context).size.height*0.12),
                      ],
                    ),
                  );
                }
              }
            }
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}