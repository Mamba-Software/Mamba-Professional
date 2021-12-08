import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';

import 'chatDetailPage.dart';
import 'chatDetailPageGroup.dart';

class ConversationList extends StatefulWidget{

  String name;
  String messageText;
  String imageUrl;
  String time;
  bool isMessageRead;
  bool isGroup;
  String userId;
  IconData? iconData;
  ConversationList({required this.name,required this.messageText,required this.imageUrl,required this.time,required this.isMessageRead, required this.userId, required this.isGroup, this.iconData});
  @override
  _ConversationListState createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {

  var _accessDatabase = new DatabaseAccess();
  bool isLoading = true;

  void initState() {
    super.initState();
    getUser();
  }

  Future<void> getUser() async {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
     return GestureDetector(
      onTap: () async {
        if(!widget.isGroup) {
          Usuario user = await this._accessDatabase.getUserDetails(widget.userId);
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ChatDetailPage(user);
          }));
        }
        else {
          Brand brand = await _accessDatabase.getBrandDetails(widget.userId);
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ChatDetailPageGroup(brand);
          }));
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal:
            MediaQuery.of(context)
                .size
                .width *
                0.04,
            vertical:
            MediaQuery.of(context)
                .size
                .height *
                0.01),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  CircularImage(
                    size: MediaQuery.of(context).size.width*0.15,
                    image: widget.imageUrl,
                    color: Theme.of(context).primaryColor,
                    borderWidth: 1.5,
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width*0.03,),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(widget.iconData == Icons.groups ? widget.name + "(Grupo)" : widget.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                          SizedBox(height: MediaQuery.of(context).size.height*0.005,),
                            TextField(
                              enabled: false,
                              decoration: InputDecoration(
                                hintStyle: TextStyle(fontSize: 13,color: Colors.grey.shade600, fontWeight: widget.isMessageRead?FontWeight.bold:FontWeight.normal),
                                hintText: widget.messageText,
                                contentPadding: EdgeInsets.all(0),
                                isDense: true,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),

                         // Text(widget.messageText,style: TextStyle(fontSize: 13,color: Colors.grey.shade600, fontWeight: widget.isMessageRead?FontWeight.bold:FontWeight.normal),),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width*0.04,),
            Icon(
              widget.iconData,
              color: Theme.of(context).primaryColor,
              size: widget.iconData == Icons.groups ? 25 : 20,
            ),
            SizedBox(width: MediaQuery.of(context).size.width*0.04,),
            Text(widget.time,style: TextStyle(fontSize: 12,fontWeight: widget.isMessageRead?FontWeight.bold:FontWeight.normal),),
          ],
        ),
      ),
    );
  }
}