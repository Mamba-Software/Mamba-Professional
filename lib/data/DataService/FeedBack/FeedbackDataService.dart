import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba/data/DataService/FirebaseDatabaseService.dart';
import 'package:mamba/data/Models/Deprecated/GroupOfQuestions.dart';
import 'package:mamba/data/Models/Deprecated/Question.dart';

// This class gives access to all of the Firebase Backend. This is the Data provider for the UI.
class FeedbackDataService {
  final _firebase = FirebaseDatabaseService();

  // Check Data
  Future<bool> checkIfAnswersExist(String? groupOfQuestionsID) =>
      _firebase.checkIfAnswersExist(groupOfQuestionsID);

  // Get Data
  Future<Question> getOneQuestion(String? id) => _firebase.getOneQuestion(id);
  Future<GroupOfQuestions?> getActiveGroupOfQuestions() =>
      _firebase.getActiveGroupOfQuestions();

  // Add Data
  Future<bool> addError(
          String title, String description, String stepsReproduce) =>
      _firebase.addError(title, description, stepsReproduce);
  Future<String> addQuestion(
          String? questionCat, String? questionSpn, String? type) =>
      _firebase.addQuestion(questionCat, questionSpn, type);
  Future<String> addGroupOfQuestions(String? questionOne, String? questionTwo,
          String? questionThree, String? questionFour) =>
      _firebase.addGroupOfQuestions(
          questionOne, questionTwo, questionThree, questionFour);
  Future<String> addAnswers(String? groupOfQuestionsID, String? answerOne,
          String? answerTwo, String? answerThree, String? answerFour) =>
      _firebase.addAnswers(
          groupOfQuestionsID, answerOne, answerTwo, answerThree, answerFour);

  // Update Data

  // Delete Data

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Streams

  Stream<QuerySnapshot> getAllQuestions() => _firebase.getAllQuestions();
}
