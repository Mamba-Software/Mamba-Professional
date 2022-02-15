import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Conversation.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/GroupOfQuestions.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Data/Models/Message.dart';
import 'package:mamba_castelldefels/Data/Models/NotificationEvent.dart';
import 'package:mamba_castelldefels/Data/Models/Question.dart';
import 'package:mamba_castelldefels/Data/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'FirebaseDatabaseService.dart';

// This class gives access to all of the Firebase Backend. This is the Data provider for the UI.
class FeedbackDataService {

  final _firebase = FirebaseDatabaseService();

  // Check Data
  Future<bool> checkIfAnswersExist(String? groupOfQuestionsID) => _firebase.checkIfAnswersExist(groupOfQuestionsID);

  // Get Data
  Future<Question> getOneQuestion(String? id) => _firebase.getOneQuestion(id);
  Future<GroupOfQuestions?> getActiveGroupOfQuestions() => _firebase.getActiveGroupOfQuestions();

  // Add Data
  Future<bool> addError(String title, String description, String stepsReproduce) => _firebase.addError(title, description, stepsReproduce);
  Future<String> addQuestion(String? questionCat, String? questionSpn, String? type) => _firebase.addQuestion(questionCat, questionSpn, type);
  Future<String> addGroupOfQuestions(String? questionOne, String? questionTwo, String? questionThree, String? questionFour) => _firebase.addGroupOfQuestions(questionOne, questionTwo, questionThree, questionFour);
  Future<String> addAnswers(String? groupOfQuestionsID, String? answerOne, String? answerTwo, String? answerThree, String? answerFour) => _firebase.addAnswers(groupOfQuestionsID, answerOne, answerTwo, answerThree, answerFour);

  // Update Data

  // Delete Data

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Streams

  Stream<QuerySnapshot> getAllQuestions() => _firebase.getAllQuestions();

}