import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Deprecated/Conversation.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Deprecated/GroupOfQuestions.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Data/Models/Deprecated/Message.dart';
import 'package:mamba_castelldefels/Data/Models/Notifications/NotificationEvent.dart';
import 'package:mamba_castelldefels/Data/Models/Deprecated/Question.dart';
import 'package:mamba_castelldefels/Data/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Data/Models/Subscription.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import '../../Models/Promotion.dart';
import '../FirebaseDatabaseService.dart';

// This class gives access to all of the Firebase Backend. This is the Data provider for the UI.
class PromotionsDataService {

  final _firebase = FirebaseDatabaseService();

  Future<List<Subscription>> getSubscriptions(String? promotion, String brandId) => _firebase.getSubscriptions(promotion, brandId);
  Future<Subscription> getValidSubscription(String subscriptionId, String brandId) => _firebase.getValidSubscription(subscriptionId, brandId);
  Future<Promotion> getValidPromotion(String promotionId) => _firebase.getValidPromotion(promotionId);
  Future<bool> checkIfBrandUsedSubscription(String subscriptionId, String brandId) => _firebase.checkIfBrandUsedSubscription(subscriptionId, brandId);
}