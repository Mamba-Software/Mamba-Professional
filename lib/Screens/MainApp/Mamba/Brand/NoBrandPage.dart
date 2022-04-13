import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/RoomDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/CalendarView/Calendars/CalendarWidgetClient.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/SendRequestConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/CancelRequestConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/ImageFullScreen.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/RectangularImage.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Marca/Client/TieneMarca/TodosMiembrosClient.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Chat/ChatCore/Chat.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class NoBrandPage extends StatefulWidget {
  const NoBrandPage({Key? key}) : super(key: key);

  @override
  _NoBrandPageState createState() => _NoBrandPageState();
}

class _NoBrandPageState extends State<NoBrandPage> {
// Acceso a Base de Datos
  var _userDataService = new UserDataService();
  var _brandDataService = new BrandDataService();
  var _roomDataService = new RoomDataService();
  // Boolean isLoading
  bool isLoading = false;
  // Brand List
  List<Brand> brandList = [];
  // Codigo
  var _codigo;
  bool codigoError = false;
  bool codigoClicked = false;
  bool isLoadingCodigo = false;
  var _codigoController = TextEditingController();
  // Request To Brand
  String brandIdRequest = "";
  RequestToBrand? request;
  RequestToBrand? newRequest;

  // init Widget state. Loading user info.
  @override
  void initState() {
    isLoading = true;
    getUserPendingRequests();
    getAllBrands();
    super.initState();
  }

  // Get user pending requests
  Future<void> getUserPendingRequests() async {
    List<RequestToBrand> req = await _userDataService.getUserRequests(currentUser.id!);
    if (req.isNotEmpty) {
      // At this moment, only 1 requests possible
      setState(() {
        request = req[0];
        brandIdRequest = request!.brandId!;
      });
    } else {
      setState(() {
        request = null;
        brandIdRequest = "";
      });
    }
  }

  Future<void> getAllBrands() async {
    brandList = await _brandDataService.getAllBrands();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
    Center(
        child: LoadingViewPurple()
    )
        :
    Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: MediaQuery.of(context).size.width*0.01,),
            Container(
                width: MediaQuery.of(context).size.width*0.30,
                child: Image.asset(Constants.logoExtendedYellow)
            ),
          ],
        ),
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          request != null ?
          Row(
            children: [
              IconButton(
                  icon: Icon(Icons.schedule_send,
                      size: MediaQuery.of(context).size.width*0.07,
                      color: Theme.of(context).accentColor),
                  onPressed: () async {
                    Brand brand = brandList.singleWhere((element) => element.id == request!.brandId!);
                    var result = await showDialog(
                        context: context,
                        builder: (_) {
                          return CancelRequestConfirmationDialog(
                            text: AppLocalizations.of(context)!.cancelRequestConfirmation,
                            brand: brand,
                          );
                        }
                    );
                    if (result) {
                      setState(() {
                        brandIdRequest = "";
                      });
                      NotificationService().userCancelRequestToBrand(currentUser.id!, request!.brandId!);
                      // New DataBase
                      await _userDataService.deleteRequestToBrand(request!);
                      getUserPendingRequests();
                    }
                  }
              ),
              SizedBox(width: MediaQuery.of(context).size.width*0.03,),
            ],
          ) :
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.qr_code_outlined, size: MediaQuery.of(context).size.width*0.07, color: !codigoClicked ? Theme.of(context).primaryColor : Theme.of(context).scaffoldBackgroundColor,),
                onPressed: !codigoClicked ? () {
                  setState(() {
                    codigoClicked = true;
                  });
                } : null,
              ),
              SizedBox(width: MediaQuery.of(context).size.width*0.03,),
            ],
          ),
        ],
        bottom: codigoClicked ? PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.10,),
          child: Container(
            height: MediaQuery.of(context).size.height*0.10,
            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.01),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Flexible(
                          child: Material(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13)
                            ),
                            elevation: 5,
                            child: new TextFormField(
                              controller: _codigoController,
                              onChanged: (val) {
                                setState(() {
                                  codigoError = false;
                                  _codigo = val;
                                });
                              },
                              style: Theme.of(context).textTheme.bodyText2?.copyWith(color: codigoError ? Colors.red: Colors.green),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!.codigo,
                                hintStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: codigoError ? Colors.red: Colors.green),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: codigoError ? Colors.red: Colors.green, width: 1.0),
                                  borderRadius: BorderRadius.circular(13.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: codigoError ? Colors.red: Colors.green, width: 1.0),
                                  borderRadius: BorderRadius.circular(13.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        !isLoadingCodigo ?
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: FloatingActionButton(
                                heroTag: "23",
                                child: Icon(Icons.login),
                                backgroundColor: Colors.green,
                                foregroundColor: AppColors.white,
                                onPressed: () async {
                                  if(_codigo == null || _codigo=="") {
                                    setState(() {
                                      codigoError = true;
                                    });
                                  } else {
                                    setState(() {
                                      isLoadingCodigo = true;
                                    });
                                    var result = await _brandDataService.checkIfBrandExists(_codigo);
                                    if (!result) {
                                      Future.delayed(const Duration(milliseconds: 500), () {
                                        setState(() {
                                          isLoadingCodigo = false;
                                          codigoError = true;
                                        });
                                      });
                                    } else {
                                      NotificationService().userJoinsBrand(currentUser.id!, _codigo);
                                      // New DataBase
                                      int role = 0;
                                      if (currentUser.isTrainer!) {
                                        role = 5;
                                      }
                                      await _brandDataService.addUserToBrand(currentUser.id!, _codigo.id!, role);
                                      // Push To Splash Screen
                                      setState(() {
                                        currentIndex = 1;
                                      });
                                      await Future.delayed(const Duration(seconds: 3));
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
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: FloatingActionButton(
                                heroTag: "24",
                                child: Icon(Icons.close),
                                backgroundColor: Colors.red,
                                foregroundColor: AppColors.white,
                                onPressed: () async {
                                  setState(() {
                                    codigoClicked = !codigoClicked;
                                    codigoError = false;
                                    _codigoController.text = "";
                                  });
                                },
                              ),
                            ),
                          ],
                        ) :
                        SizedBox(
                          width: 130,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FloatingActionButton(
                                  heroTag: "25",
                                  child: SizedBox(
                                    width: 100,
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  backgroundColor: Colors.orangeAccent,
                                  foregroundColor: AppColors.white,
                                  onPressed: false ? () {} : null
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                ),
              ],
            ),
          ),
        ) :  PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Container(),
        ),
      ),
      body: brandList.length > 0 ? RefreshIndicator(
        displacement: MediaQuery.of(context).size.height*0.05,
        color: Theme.of(context).accentColor,
        onRefresh: () {
          return Future.delayed(
            Duration(seconds: 1), () {
            getAllBrands();
            getUserPendingRequests();
          },
          );
        },
        child: ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: brandList.length,
            itemBuilder: (context, int index) {
              Brand brand = brandList[index];
              return Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  Container(
                    height: MediaQuery.of(context).size.height*0.05,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircularImage(
                            size: MediaQuery.of(context).size.width*0.10,
                            image: brand.logoUrl,
                            color: Theme.of(context).accentColor,
                            borderWidth: 1,
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width*0.03),
                          Expanded(
                            child: Text(
                              brand.name!,
                              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.015),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute<Null>(
                              builder: (context) => FullScreenPage(
                                child:  Image.network(
                                  brand.logoUrl!,
                                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: Theme.of(context).accentColor,
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                                dark: false,
                              )
                          )
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: RectangularImage(
                        image: brand.logoUrl!,
                        size: MediaQuery.of(context).size.width,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.005),
                  Row(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height*0.08,
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.calendar_today_outlined,
                                        size: MediaQuery.of(context).size.width*0.07,
                                        color: Theme.of(context).primaryColor),
                                    padding: EdgeInsets.all(0),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          CupertinoPageRoute<Null>(
                                              builder: (context) => CalendarWidgetClient(
                                                brandID: brand.id!,
                                                onlyView: true,
                                              )
                                          )
                                      ).whenComplete(() {
                                        getUserPendingRequests();
                                      });
                                    },
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.calendar,
                                    style: Theme.of(context).textTheme.bodyText2,
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.groups_outlined,
                                        size: MediaQuery.of(context).size.width*0.07,
                                        color: Theme.of(context).primaryColor),
                                    padding: EdgeInsets.all(0),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          CupertinoPageRoute<Null>(
                                              builder: (context) => TodosMiembrosClient(
                                                brandID: brand.id!,
                                                brandAdmin: brand.adminID!,
                                                viewOnly: true,
                                              )
                                          )
                                      ).whenComplete(() {
                                        getUserPendingRequests();
                                      });
                                    },
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.members,
                                    style: Theme.of(context).textTheme.bodyText2,
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.question_answer_outlined, size: MediaQuery.of(context).size.width*0.07, color: Theme.of(context).primaryColor),
                                    padding: EdgeInsets.all(0),
                                    onPressed: () async {
                                      Usuario adminUser = await _userDataService.getUserDetails(brand.adminID!);
                                      if(adminUser == null) LoadingView();
                                      else {
                                        types.User otherUser = types.User(
                                          firstName: adminUser.firstName,
                                          lastName: adminUser.lastName,
                                          id: adminUser.id!, // UID from Firebase Authentication
                                          imageUrl: adminUser.imageUrl,
                                        );
                                        final room = await FirebaseChatCore.instance.createRoom(otherUser,metadata: {
                                          "trainer" + adminUser.id!: adminUser.isTrainer,
                                          "trainer" + currentUser.id!: currentUser.isTrainer,
                                          "active" + adminUser.id!: false,
                                          "active" + currentUser.id!: true,
                                        });
                                        bool? deleteRoom = await Navigator.push(
                                          context,
                                          CupertinoPageRoute<bool>(
                                              builder: (context) => ChatPage(room: room)),).whenComplete(() async {
                                          room.metadata!["active" + currentUser.id!] = false;
                                          _roomDataService.updateRoom(room.id, room.metadata!);
                                        });
                                        if (!deleteRoom!) {
                                          _roomDataService.deleteRoom(room.id);
                                        }
                                      }
                                    },
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.contact,
                                    style: Theme.of(context).textTheme.bodyText2,
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(brandIdRequest == brand.id! ? Icons.schedule_send : Icons.send_outlined, size: MediaQuery.of(context).size.width*0.07, color: brandIdRequest == brand.id! ? Theme.of(context).accentColor : request == null ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.3)),
                                    padding: EdgeInsets.all(0),
                                    onPressed: request == null || brandIdRequest == brand.id! ? () async {
                                      if (brandIdRequest == brand.id!) {
                                        var result = await showDialog(
                                            context: context,
                                            builder: (_) {
                                              return CancelRequestConfirmationDialog(
                                                text: AppLocalizations.of(context)!.cancelRequestConfirmation,
                                                brand: brand,
                                              );
                                            }
                                        );
                                        if (result) {
                                          setState(() {
                                            brandIdRequest = "";
                                          });
                                          NotificationService().userCancelRequestToBrand(currentUser.id!, request!.brandId!);
                                          // New DataBase
                                          await _userDataService.deleteRequestToBrand(request!);
                                          getUserPendingRequests();
                                        }
                                      } else {
                                        var result = await showDialog(
                                            context: context,
                                            builder: (_) {
                                              return SendRequestConfirmationDialog(
                                                text: AppLocalizations.of(context)!.sendRequestConfirmation,
                                                brand: brand,
                                              );
                                            }
                                        );
                                        if (result) {
                                          setState(() {
                                            brandIdRequest = brand.id!;
                                          });
                                          // New DataBase
                                          await _userDataService.sendRequestToBrand(brand.id!, currentUser.name! ,currentUser.isTrainer!);
                                          NotificationService().userSendRequestToBrand(currentUser.id!, brand.id!);
                                          getUserPendingRequests();
                                        }
                                      }
                                    } : null,
                                  ),
                                  Text(
                                    brandIdRequest == brand.id! ? AppLocalizations.of(context)!.sent : AppLocalizations.of(context)!.join,
                                    style: Theme.of(context).textTheme.bodyText2?.copyWith(color: brandIdRequest == brand.id! ? Theme.of(context).accentColor : request == null ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.3)),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                    child: Row(
                      children: [
                        Expanded(
                          child: RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyText2,
                              children: [
                                TextSpan(text: '${brand.name!} ', style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold),),
                                TextSpan(text: brand.description!),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.memberSince(brand.dateJoined!),
                            style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                ],
              );
            }
        ),
      ) : Container(
        height: MediaQuery.of(context).size.height *0.70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                  height: MediaQuery.of(context).size.height*0.25,
                  child: Image.asset(Constants.arroundLocation)
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.2),
                child: Text(
                  AppLocalizations.of(context)!.noBrandsFound,
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.center,),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
