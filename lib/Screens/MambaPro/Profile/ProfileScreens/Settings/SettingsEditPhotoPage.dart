import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Utils/Images/ImageUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsEditPhotoPage extends StatefulWidget {
  @override
  _SettingsEditPhotoPageState createState() => _SettingsEditPhotoPageState();
}

class _SettingsEditPhotoPageState extends State<SettingsEditPhotoPage> {

  // Acceso a Base de Datos
  var _userDataService = new UserDataService();
  // Boolean Loading
  bool isLoading = false;
  bool isLoadingBody = false;
  // _Image File
  String? _imageUrl;
  // _Image File
  File? _image;
  // Settings when permission not given
  bool isSettingsOpened = false;

  @override
  void initState() {
    mixpanel!.timeEvent('user_profile_settings_picture_change');
    isLoading = true;
    getUser();
    super.initState();
    //WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    //WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Selects image from Gallery and updates in firebase.
  Future getImage() async {
    mixpanel!.timeEvent('user_profile_settings_picture');
    setState(() {
      isLoadingBody = true;
    });
    try {
      File? temp = await ImageUtils().pickImage();
      setState(() {
        _image = temp;
        isLoadingBody = false;
      });
      mixpanel!.track('user_profile_settings_picture');
    } catch (e) {
      setState(() {
        isLoadingBody = false;
      });
      var status = await Permission.photos.status;
      if (status.isDenied) {
        print('Access Denied');
        showCupertinoDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: const Text('Permission Denied'),
            content: const Text('Allow access to gallery and photos'),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => openAppSettings(),
                child: const Text('Settings'),
              ),
            ],
          ),
        );
      } else {
        print('Exception occured!');
      }
    }
  }

  // Upload Image
  Future<void> uploadPhoto() async {
    setState(() {
      isLoading = true;
    });
    String temp = await _userDataService.updateUserPhoto(currentUser.id!, _image!);
    setState(() {
      _imageUrl = temp;
      currentUser.imageUrl = _imageUrl;
      isLoading = false;
      _image = null;
    });
    mixpanel!.track('user_profile_settings_picture_change_completed');
  }

  // Gets the user info from firebase.
  Future<void> getUser() async {
    currentUser.setBasicData = await _userDataService.getUserDetails(currentUser.id!);
    _imageUrl = currentUser.imageUrl;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.uploadPhoto, style: Theme.of(context).appBarTheme.titleTextStyle,),
        centerTitle: true,
      ),
      body: isLoading ?
        Center(
            child: LoadingView()
        )
          :
        Center(
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Center(
                  child: CircularImage(size: MediaQuery.of(context).size.height * 0.35, image: _imageUrl,),
                ),
              ),
              const Icon(Icons.arrow_upward,size: 40,),
              Container(
                padding: const EdgeInsets.all(30.0),
                height: MediaQuery.of(context).size.height * 0.4,
                child: Center(
                  child: _image == null ?
                  OutlinedButton(
                    onPressed: getImage,
                    child: Column(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        !isLoadingBody ? Icon(
                          Icons.face,
                          color: Theme.of(context).primaryColor,
                          size: MediaQuery.of(context).size.width * 0.1,
                        ) : SizedBox(
                          height: MediaQuery.of(context).size.width * 0.1,
                          width: MediaQuery.of(context).size.width * 0.1,
                          child: Center(
                            child: SizedBox(
                              height: MediaQuery.of(context).size.width * 0.07,
                              width: MediaQuery.of(context).size.width * 0.07,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 1.5
                      ),
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      elevation: 10,
                      shape: const CircleBorder(),
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.height * 0.13, right: MediaQuery.of(context).size.height * 0.13, top: MediaQuery.of(context).size.height * 0.14),
                    ),
                  )
                      :
                  GestureDetector(
                    onTap: getImage,
                    child: Stack(
                      children: <Widget>[
                        const Center(child: CircularProgressIndicator()),
                        Center(child: CircularImage(size: MediaQuery.of(context).size.height * 0.35, file: _image,)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
      ),
      floatingActionButton: _image != null ? FloatingActionButton(
        heroTag: "38",
        onPressed: uploadPhoto,
        tooltip: AppLocalizations.of(context)!.save,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(
          Icons.check,
          color: Colors.white,
        ),
      ) : Container(),
    );
  }
}