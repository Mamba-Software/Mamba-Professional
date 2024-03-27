import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mamba/l10n/language_manager.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/notifications/NotificationService/NotificationService.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Dialogs/ActionDialogs/RequestConfirmationDialog.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba/data/Models/RequestToBrand.dart';

class MembershipRequestsPro extends StatefulWidget {
  String brandId;
  MembershipRequestsPro({super.key, required this.brandId});

  @override
  _MembershipRequestsProState createState() => _MembershipRequestsProState();
}

class _MembershipRequestsProState extends State<MembershipRequestsPro> {
  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    return _scrollController!.hasClients &&
        _scrollController!.offset >
            (MediaQuery.of(context).size.height * 0.15 - kToolbarHeight);
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
      ..addListener(
        () => _isAppBarExpanded
            ? setState(() {
                appBarExpanded = true;
              })
            : setState(() {
                appBarExpanded = false;
              }),
      );
  }

  List<RequestToBrand> documentsToRequests(List<DocumentSnapshot> documents) {
    List<RequestToBrand> requests = [];
    for (int i = 0; i < documents.length; i++) {
      RequestToBrand request =
          RequestToBrand.fromObjectAllData(documents[i].id, documents[i]);
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
            surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
            systemOverlayStyle:
                Theme.of(context).appBarTheme.systemOverlayStyle,
            elevation: 4,
            forceElevated: true, //* here//* question having 0 here
            pinned: true,
            floating: false,
            title: Text(context.l10n.myRequests,
                style: Theme.of(context).appBarTheme.titleTextStyle),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: MediaQuery.of(context).size.width * 0.06,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          StreamBuilder<QuerySnapshot>(
              stream: _brandDataService.getBrandRequestsStream(widget.brandId),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        Expanded(child: Center(child: LoadingView())),
                      ],
                    ),
                  );
                } else {
                  requestList = documentsToRequests(snapshot.data!.docs);
                  if (requestList.isNotEmpty) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          RequestToBrand request = requestList[index];
                          String type;
                          if (request.isTrainer!) {
                            type = context.l10n.trainer.toLowerCase();
                          } else {
                            type = context.l10n.client.toLowerCase();
                          }
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ListTile(
                              minLeadingWidth:
                                  MediaQuery.of(context).size.width * 0.1,
                              leading: Icon(
                                request.isTrainer!
                                    ? Icons.record_voice_over
                                    : Icons.directions_run,
                                color: Theme.of(context).primaryColor,
                                size: MediaQuery.of(context).size.width * 0.1,
                              ),
                              title: RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  children: [
                                    TextSpan(
                                      text: request.name!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                        text:
                                            context.l10n.requestFromUser(type),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium),
                                  ],
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  Text(
                                      context.l10n
                                          .requestSent(request.dateSent!),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                ],
                              ),
                              onTap: () async {
                                mixpanel!
                                    .track('brand_membership_requests_open');
                                var result = await showDialog(
                                    context: context,
                                    builder: (_) {
                                      return RequestConfirmationDialog(
                                        text: context.l10n.requestConfirmation,
                                        userId: request.userId!,
                                      );
                                    });
                                if (result == null) {
                                  mixpanel!
                                      .track('brand_membership_requests_close');
                                } else {
                                  if (result) {
                                    NotificationService().userJoinsBrand(
                                        request.userId!, request.brandId!);
                                    _brandDataService
                                        .acceptRequestFromUser(request);
                                    mixpanel!.track(
                                        'brand_membership_requests_accept');
                                  } else {
                                    _userDataService
                                        .deleteRequestToBrand(request);
                                    mixpanel!.track(
                                        'brand_membership_requests_delete');
                                  }
                                }
                              },
                            ),
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
                              width: MediaQuery.of(context).size.width * 0.30,
                              child: Image.asset(Assets.emptyCalendar)),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.005),
                          Text(
                            context.l10n.noData,
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.12),
                        ],
                      ),
                    );
                  }
                }
              }),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
