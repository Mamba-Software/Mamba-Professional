import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/Conversation.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Models/GroupOfQuestions.dart';
import 'package:mamba_castelldefels/Models/Location.dart';
import 'package:mamba_castelldefels/Models/Message.dart';
import 'package:mamba_castelldefels/Models/NotificationEvent.dart';
import 'package:mamba_castelldefels/Models/Question.dart';
import 'package:mamba_castelldefels/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'FirebaseDatabaseService.dart';

// This class gives access to all of the Firebase Backend. This is the Data provider for the UI.
class FeedbackDataService {

  final _firebase = FirebaseDatabaseService();

  //Questions
  Future<Question> getOneQuestion(String? id) => _firebase.getOneQuestion(id);
  Future<String> addQuestion(String? questionCat, String? questionSpn, String? type) => _firebase.addQuestion(questionCat, questionSpn, type);

  //GroupOfQuestions
  Future<String> addGroupOfQuestions(String? questionOne, String? questionTwo, String? questionThree, String? questionFour) => _firebase.addGroupOfQuestions(questionOne, questionTwo, questionThree, questionFour);
  Future<GroupOfQuestions?> getActiveGroupOfQuestions() => _firebase.getActiveGroupOfQuestions();

  //Answers
  Future<String> addAnswers(String? groupOfQuestionsID, String? answerOne, String? answerTwo, String? answerThree, String? answerFour) => _firebase.addAnswers(groupOfQuestionsID, answerOne, answerTwo, answerThree, answerFour);
  Future<bool> checkIfAnswersExist(String? groupOfQuestionsID) => _firebase.checkIfAnswersExist(groupOfQuestionsID);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Streams



}