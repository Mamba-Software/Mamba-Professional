import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/CalendarView/Events/EventPageClient.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/CalendarView/Events/EventPageTrainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/CalendarView/Events/ViewEventClient.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Brand/BrandScreens/BrandMembers/BrandMembersClient.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Brand/BrandScreens/BrandMembers/BrandMembersTrainer.dart';

class BrandMembersPage extends StatefulWidget {
  String brandId;
  String brandAdmin;

  BrandMembersPage({Key? key, required this.brandId, required this.brandAdmin}) : super(key: key);

  @override
  _BrandMembersPageState createState() => _BrandMembersPageState();
}

class _BrandMembersPageState extends State<BrandMembersPage> {

  // init Widget state. Loading user info.
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return currentUser.isTrainer! ?
        BrandMembersTrainer()
          :
        BrandMembersClient(
          brandID: widget.brandId,
          brandAdmin: widget.brandAdmin,
          viewOnly: false
        );
  }
}
