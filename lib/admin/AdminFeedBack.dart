import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/data/DataService/FeedBack/FeedbackDataService.dart';
import 'package:mamba/app/styles/AppColors.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/data/Models/Deprecated/Question.dart';
import 'package:mamba/data/Models/Usuario.dart';
import 'package:mamba/commons/widgets/loading/LoadingView.dart';

class AdminFeedBack extends StatefulWidget {
  final String title;

  const AdminFeedBack({super.key, required this.title});

  @override
  _AdminFeedBackState createState() => _AdminFeedBackState();
}

class _AdminFeedBackState extends State<AdminFeedBack> {
  //DataBase Access
  final _feedbackDataService = FeedbackDataService();

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
        title: Text(widget.title, style: context.textTheme.bodyMedium),
        centerTitle: true,
        elevation: 10,
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
      ),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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
                      onTap: (val) {},
                      tabs: [
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Questions",
                                  style: context.textTheme.bodyMedium,
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
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Group Of Questions",
                                  style: context.textTheme.bodyMedium,
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
                          DropdownButton<String>(
                            items: <String>[
                              'YesOrNo',
                              'OneToTen',
                              'Options',
                              'FreeAns'
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (item) {
                              setState(() {
                                displayType = item;
                              });
                            },
                          ),
                          Text(
                            displayType!,
                            style: const TextStyle(
                              fontSize: 17,
                            ),
                          ),
                          TextButton(
                            child: const Text(
                              'New question',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            onPressed: () {
                              _feedbackDataService.addQuestion(
                                  editingControllerCat.text,
                                  editingControllerSpn.text,
                                  displayType);
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
                            allQuestions =
                                documentsToQuestions(snapshot.data!.docs);
                            questionsTypeYesOrNo = allQuestions
                                .where((i) => i.type == "YesOrNo")
                                .toList();
                            questionsTypeOneToTen = allQuestions
                                .where((i) => i.type == "OneToTen")
                                .toList();
                            questionsTypeOptions = allQuestions
                                .where((i) => i.type == "Options")
                                .toList();
                            questionsTypeFreeAns = allQuestions
                                .where((i) => i.type == "FreeAns")
                                .toList();
                            return Column(
                              children: [
                                DropdownButton<Question>(
                                  items: questionsTypeYesOrNo
                                      .map<DropdownMenuItem<Question>>(
                                          (Question value) {
                                    return DropdownMenuItem<Question>(
                                      value: value,
                                      child: Text(value.questionCat!),
                                    );
                                  }).toList(),
                                  onChanged: (Question? newQuestion) {
                                    setState(() {
                                      displayQuestion1 =
                                          newQuestion!.questionCat;
                                      questionOne = newQuestion.id!;
                                    });
                                  },
                                ),
                                Text(
                                  displayQuestion1!,
                                  style: const TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                                DropdownButton<Question>(
                                  items: questionsTypeOneToTen
                                      .map<DropdownMenuItem<Question>>(
                                          (Question value) {
                                    return DropdownMenuItem<Question>(
                                      value: value,
                                      child: Text(value.questionCat!),
                                    );
                                  }).toList(),
                                  onChanged: (Question? newQuestion) {
                                    setState(() {
                                      displayQuestion2 =
                                          newQuestion!.questionCat;
                                      questionTwo = newQuestion.id!;
                                    });
                                  },
                                ),
                                Text(
                                  displayQuestion2!,
                                  style: const TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                                DropdownButton<Question>(
                                  items: questionsTypeOptions
                                      .map<DropdownMenuItem<Question>>(
                                          (Question value) {
                                    return DropdownMenuItem<Question>(
                                      value: value,
                                      child: Text(value.questionCat!),
                                    );
                                  }).toList(),
                                  onChanged: (Question? newQuestion) {
                                    setState(() {
                                      displayQuestion3 =
                                          newQuestion!.questionCat;
                                      questionThree = newQuestion.id!;
                                    });
                                  },
                                ),
                                Text(
                                  displayQuestion3!,
                                  style: const TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                                DropdownButton<Question>(
                                  items: questionsTypeFreeAns
                                      .map<DropdownMenuItem<Question>>(
                                          (Question value) {
                                    return DropdownMenuItem<Question>(
                                      value: value,
                                      child: Text(value.questionCat!),
                                    );
                                  }).toList(),
                                  onChanged: (Question? newQuestion) {
                                    setState(() {
                                      displayQuestion4 =
                                          newQuestion!.questionCat;
                                      questionFour = newQuestion.id!;
                                    });
                                  },
                                ),
                                Text(
                                  displayQuestion4!,
                                  style: const TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                                TextButton(
                                  child: const Text(
                                    'New group of questions',
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                  onPressed: () {
                                    _feedbackDataService.addGroupOfQuestions(
                                        questionOne,
                                        questionTwo,
                                        questionThree,
                                        questionFour);
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

  const UserTile(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
      child: ListTile(
        leading: CircularImage(
            size: MediaQuery.of(context).size.width * 0.15,
            image: user.imageUrl,
            borderWidth: 3,
            color: Colors.red),
        trailing: const Icon(Icons.east),
        title: Text(
          user.name!,
          style: const TextStyle(fontSize: 20.0),
        ),
        subtitle: const Text("Admin Tool"),
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
