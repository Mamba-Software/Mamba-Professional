import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:mamba_castelldefels/Data/DataService/FeedbackDataService.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Data/Models/Question.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Perfil/PerfilModals/FeedBack.dart';

import '../MainApp/Home/Perfil/PerfilModals/UserFeedBack.dart';

class AdminFeedBack extends StatefulWidget {
  final String title;

  const AdminFeedBack({Key? key, required this.title}) : super(key: key);

  @override
  _AdminFeedBackState createState() => _AdminFeedBackState();
}

class _AdminFeedBackState extends State<AdminFeedBack> {
  //DataBase Access
  var _feedbackDataService = new FeedbackDataService();

  String? displayType = "Selecciona un tipus";
  String? displayQuestion1 = "Selecciona una pregunta",
      displayQuestion2 = "Selecciona una pregunta",
      displayQuestion3 = "Selecciona una pregunta",
      displayQuestion4 = "Selecciona una pregunta";
  List<DocumentSnapshot> item = [];
  var allQuestions1;
  List<Question> allQuestions = [],
      questionsTypeYesOrNo = [],
      questionsTypeOneToTen = [],
      questionsTypeOptions = [],
      questionsTypeFreeAns = [];
  bool isLoading = false;
  var editingControllerCat = TextEditingController();
  var editingControllerSpn = TextEditingController();
  var tabViewController;
  var fromDate;
  var toDate;
  var questionOne, questionTwo, questionThree, questionFour;

  @override
  void initState() {
    super.initState();
    isLoading = false;
    //this.getQuestions();
    //getUsersList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: Styles.whiteTextStyle
                .copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        elevation: 10,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
      ),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.70,
              ),
              padding: MediaQuery.of(context).viewInsets,
              child: DefaultTabController(
                length: 2,
                child: Scaffold(
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    centerTitle: true,
                    bottom: TabBar(
                      onTap: (val) {
                      },
                      tabs: [
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Questions",
                                  style: Styles.purpleTextStyle
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Group Of Questions",
                                  style: Styles.purpleTextStyle
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  body: TabBarView(
                    controller: tabViewController,
                    children: [
                      Column(
                        children: [
                          TextField(
                            controller: editingControllerCat,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'New question catalan'),
                          ),
                          TextField(
                            controller: editingControllerSpn,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'New question spanish'),
                          ),
                          new DropdownButton<String>(
                            items: <String>[
                              'YesOrNo',
                              'OneToTen',
                              'Options',
                              'FreeAns'
                            ].map((String value) {
                              return new DropdownMenuItem<String>(
                                value: value,
                                child: new Text(value),
                              );
                            }).toList(),
                            onChanged: (item) {
                              setState(() {
                                this.displayType = item;
                              });
                            },
                          ),
                          Text(
                            this.displayType!,
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                          TextButton(
                            child: Text(
                              'New question',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            onPressed: () {
                              this._feedbackDataService.addQuestion(
                                  editingControllerCat.text,
                                  editingControllerSpn.text,
                                  this.displayType);
                            },
                          ),
                        ],
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: _feedbackDataService.getAllQuestions(),
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return LoadingView();
                          } else {
                            this.allQuestions =
                                documentsToQuestions(snapshot.data!.docs);
                            this.questionsTypeYesOrNo = this
                                .allQuestions
                                .where((i) => i.type == "YesOrNo")
                                .toList();
                            this.questionsTypeOneToTen = this
                                .allQuestions
                                .where((i) => i.type == "OneToTen")
                                .toList();
                            this.questionsTypeOptions = this
                                .allQuestions
                                .where((i) => i.type == "Options")
                                .toList();
                            this.questionsTypeFreeAns = this
                                .allQuestions
                                .where((i) => i.type == "FreeAns")
                                .toList();
                            return Column(
                              children: [
                                new DropdownButton<Question>(
                                  items: this
                                      .questionsTypeYesOrNo
                                      .map<DropdownMenuItem<Question>>(
                                          (Question value) {
                                    return DropdownMenuItem<Question>(
                                      value: value,
                                      child: new Text(value.questionCat!),
                                    );
                                  }).toList(),
                                  onChanged: (Question? newQuestion) {
                                    setState(() {
                                      this.displayQuestion1 =
                                          newQuestion!.questionCat;
                                          this.questionOne = newQuestion.id!;
                                    });
                                  },
                                ),
                                Text(
                                  this.displayQuestion1!,
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                                new DropdownButton<Question>(
                                  items: this
                                      .questionsTypeOneToTen
                                      .map<DropdownMenuItem<Question>>(
                                          (Question value) {
                                    return DropdownMenuItem<Question>(
                                      value: value,
                                      child: new Text(value.questionCat!),
                                    );
                                  }).toList(),
                                  onChanged: (Question? newQuestion) {
                                    setState(() {
                                      this.displayQuestion2 =
                                          newQuestion!.questionCat;
                                      this.questionTwo = newQuestion.id!;
                                    });
                                  },
                                ),
                                Text(
                                  this.displayQuestion2!,
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                                new DropdownButton<Question>(
                                  items: this
                                      .questionsTypeOptions
                                      .map<DropdownMenuItem<Question>>(
                                          (Question value) {
                                    return DropdownMenuItem<Question>(
                                      value: value,
                                      child: new Text(value.questionCat!),
                                    );
                                  }).toList(),
                                  onChanged: (Question? newQuestion) {
                                    setState(() {
                                      this.displayQuestion3 =
                                          newQuestion!.questionCat;
                                      this.questionThree = newQuestion.id!;
                                    });
                                  },
                                ),
                                Text(
                                  this.displayQuestion3!,
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                                new DropdownButton<Question>(
                                  items: this
                                      .questionsTypeFreeAns
                                      .map<DropdownMenuItem<Question>>(
                                          (Question value) {
                                    return DropdownMenuItem<Question>(
                                      value: value,
                                      child: new Text(value.questionCat!),
                                    );
                                  }).toList(),
                                  onChanged: (Question? newQuestion) {
                                    setState(() {
                                      this.displayQuestion4 =
                                          newQuestion!.questionCat;
                                      this.questionFour = newQuestion.id!;
                                    });
                                  },
                                ),
                                Text(
                                  this.displayQuestion4!,
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                                TextButton(
                                  child: Text(
                                    'New group of questions',
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                  onPressed: () {
                                    this._feedbackDataService.addGroupOfQuestions(
                                        this.questionOne,
                                        this.questionTwo,
                                        this.questionThree,
                                        this.questionFour);
                                  },
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<Question> documentsToQuestions(List<DocumentSnapshot> documents) {
  List<Question> questions = [];
  for (int i = 0; i < documents.length; i++) {
    documents[i].id;
    questions.add(Question.fromObject(documents[i], documents[i].id));
  }
  return questions;
}

class UserTile extends StatelessWidget {
  final Usuario user;

  UserTile(this.user);

  @override
  Widget build(BuildContext context) {
    return new Card(
      margin: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
      child: ListTile(
        leading: CircularImage(
            size: MediaQuery.of(context).size.width * 0.15,
            image: user.imageUrl,
            borderWidth: 3,
            color: Colors.red),
        trailing: Icon(Icons.east),
        title: Text(
          user.name!,
          style: TextStyle(fontSize: 20.0),
        ),
        subtitle: Text("Admin Tool"),
        onTap: () {},
      ),
    );
  }
}

/*
 StreamBuilder<QuerySnapshot>(
                stream: _accessDatabase.getAllUsers(),
                builder: (context, snapshot) {
                  //if(snapshot == null || snapshot.data == null || snapshot.data.documents == null ) return EmptyView();
                  //else if(snapshot.hasError) return ErrorView();
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingView();
                  } else {
                    usersList = documentsToUsers(snapshot.data!.docs);
                    return Column(
                      children: [
                        ListView.builder(
                          itemBuilder: (context, int index) => UserTile(usersList[index]),
                          itemCount: usersList.length,
                          shrinkWrap: true,
                        ),
                      ],
                    );
                  }
                }
            ),
 */
