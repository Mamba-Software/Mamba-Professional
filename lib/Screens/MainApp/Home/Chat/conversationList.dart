import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
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
  ConversationList({required this.name,required this.messageText,required this.imageUrl,required this.time,required this.isMessageRead, required this.userId, required this.isGroup});
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
        padding: EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  CircularImage(
                    size: MediaQuery.of(context).size.width*0.2,
                    image: widget.imageUrl,
                    color: Theme.of(context).primaryColor,
                    borderWidth: 1.5,
                  ),
                 /* CircleAvatar(
                    backgroundImage: NetworkImage(widget.imageUrl),
                    maxRadius: 30,
                  ),*/
                  SizedBox(width: 16,),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(widget.name, style: TextStyle(fontSize: 16),),
                          SizedBox(height: 6,),
                          Text(widget.messageText,style: TextStyle(fontSize: 13,color: Colors.grey.shade600, fontWeight: widget.isMessageRead?FontWeight.bold:FontWeight.normal),),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(widget.time,style: TextStyle(fontSize: 12,fontWeight: widget.isMessageRead?FontWeight.bold:FontWeight.normal),),
          ],
        ),
      ),
    );
  }
}