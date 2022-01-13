import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';

class NotificationService {

  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();

  NotificationService();

  Future<void> wellcomeUser(String userId) async {
    var parameters = [];
    _accessDatabase.sendNotification(userId, "Wellcome_User", parameters);
    // New Notification
    _accessDatabase.sendNotificationToUser(userId, "Wellcome_User", parameters);
  }

  Future<void> userCreatesBrand(String userId, String brandId) async {
    // Notification to the User Joining
    var parameters = ["null", brandId, "null"];
    _accessDatabase.sendNotification(userId, "UserCreatesBrand_User", parameters);
    // New Notification
    _accessDatabase.sendNotificationToUser(userId, "UserCreatesBrand_User", parameters);
  }

  Future<void> userDeletesBrand(String userId, String brandId) async {
    // Notification to the User Joining
    var parameters = ["null", brandId, "null"];
    _accessDatabase.sendNotification(userId, "UserDeletesBrand_Owner", parameters);
    // New Notification
    _accessDatabase.sendNotificationToUser(userId, "UserDeletesBrand_Owner", parameters);
    /*
    List<Usuario> brandUsers = await _accessDatabase.getAllClientsFromBrand(brandId);
    brandUsers.addAll(await _accessDatabase.getAllTrainersFromBrand(brandId));
    for (var i=0; i<brandUsers.length; i++) {
      Usuario user = brandUsers[i];
      if (user.id! != userId) {
        _accessDatabase.sendNotification(user.id!, "UserDeletesBrand_User", parameters);
      }
    }
     */
  }

  Future<void> userJoinsBrand(String userId, String brandId) async {
    // Notification to the User Joining
    Brand brand = await _accessDatabase.getBrandDetails(brandId);
    var parameters = ["null", brandId, "null"];
    _accessDatabase.sendNotification(userId, "UserJoinsBrand_User", parameters);
    // New Notification
    _accessDatabase.sendNotificationToUser(userId, "UserJoinsBrand_User", parameters);
    // Notification to All Brand Trainers
    List<Usuario> listUsers = await _accessDatabase.getAllTrainersFromBrand(brandId);
    int members = brand.numberClients! + brand.numberTrainers! + 1;
    parameters = [userId, brandId, "null", members.toString()];
    for (var i=0; i<listUsers.length; i++) {
      Usuario trainer = listUsers[i];
      if (trainer.id! != userId) {
        _accessDatabase.sendNotification(trainer.id!, "UserJoinsBrand_Trainer", parameters);
        // New Notification
        _accessDatabase.sendNotificationToUser(trainer.id!, "UserJoinsBrand_Trainer", parameters);
      }
    }
  }

  Future<void> userLeavesBrand(String userId, String brandId) async {
    // Notification to the User Joining
    Brand brand = await _accessDatabase.getBrandDetails(brandId);
    var parameters = ["null", brandId, "null"];
    _accessDatabase.sendNotification(userId, "UserLeavesBrand_User", parameters);
    // New Notification
    _accessDatabase.sendNotificationToUser(userId, "UserLeavesBrand_User", parameters);
    // Notification to All Brand Trainers
    int members = brand.numberClients! + brand.numberTrainers! - 1;
    parameters = [userId, brandId, "null", members.toString()];
    List<Usuario> listUsers = await _accessDatabase.getAllTrainersFromBrand(brandId);
    for (var i=0; i<listUsers.length; i++) {
      Usuario trainer = listUsers[i];
      if (trainer.id! != userId) {
        _accessDatabase.sendNotification(trainer.id!, "UserLeavesBrand_Trainer", parameters);
        // New Notification
        _accessDatabase.sendNotificationToUser(trainer.id!, "UserLeavesBrand_Trainer", parameters);
      }
    }
  }

  Future<void> userSendRequestToBrand(String userId, String brandId) async {
    // Notification to the User Joining
    RequestToBrand? req = await _accessDatabase.hasPendingRequest(userId);
    var parameters = ["null", brandId, "null",];
    _accessDatabase.sendNotification(userId, "UserSendRequestToBrand_User", parameters);
    // New Notification
    _accessDatabase.sendNotificationToUser(userId, "UserSendRequestToBrand_User", parameters);
    // Notification to All Brand Trainers
    parameters = [userId, brandId, "null", req!.dateSent!,];
    List<Usuario> listUsers = await _accessDatabase.getAllTrainersFromBrand(brandId);
    for (var i=0; i<listUsers.length; i++) {
      Usuario trainer = listUsers[i];
      if (trainer.id! != userId) {
        _accessDatabase.sendNotification(trainer.id!, "UserSendRequestToBrand_Trainer", parameters);
        // New Notification
        _accessDatabase.sendNotificationToUser(trainer.id!, "UserSendRequestToBrand_Trainer", parameters);
      }
    }
  }

  Future<void> userCancelRequestToBrand(String userId, String brandId) async {
    // Notification to the User Canceling Request
    var parameters = ["null", brandId, "null",];
    _accessDatabase.sendNotification(userId, "UserCancelRequestToBrand_User", parameters);
    // New Notification
    _accessDatabase.sendNotificationToUser(userId, "UserCancelRequestToBrand_User", parameters);
    // Notification to All Brand Trainers
    List<Usuario> listUsers = await _accessDatabase.getAllTrainersFromBrand(brandId);
    parameters = [userId, brandId, "null",];
    for (var i=0; i<listUsers.length; i++) {
      Usuario trainer = listUsers[i];
      if (trainer.id! != userId) {
        _accessDatabase.sendNotification(trainer.id!, "UserCancelRequestToBrand_Trainer", parameters);
        // New Notification
        _accessDatabase.sendNotificationToUser(trainer.id!, "UserCancelRequestToBrand_Trainer", parameters);
      }
    }
  }

  Future<void> userJoinEvent(String userId, String brandId, String eventId) async {
    // Notification to the User Joining Event
    var parameters = ["null", brandId, eventId];
    _accessDatabase.sendNotification(userId, "UserJoinEvent_User", parameters);
    // New Notification
    _accessDatabase.sendNotificationToUser(userId, "UserJoinEvent_User", parameters);
    // Notification to All Event Trainers
    parameters = [userId, "null", eventId];
    Event event = await _accessDatabase.getSingleEvent(eventId);
    for (var i=0; i < event.selectedTrainers.length; i++) {
      String trainerId = event.selectedTrainers[i];
      if (trainerId != userId) {
        _accessDatabase.sendNotification(trainerId, "UserJoinEvent_Trainer", parameters);
        // New Notification
        _accessDatabase.sendNotificationToUser(trainerId, "UserJoinEvent_Trainer", parameters);
      }
    }
  }

  Future<void> userLeaveEvent(String userId, String brandId, String eventId) async {
    // Notification to the User Joining Event
    var parameters = ["null", brandId, eventId];
    _accessDatabase.sendNotification(userId, "UserLeaveEvent_User", parameters);
    // New Notification
    _accessDatabase.sendNotificationToUser(userId, "UserLeaveEvent_User", parameters);
    // Notification to All Event Trainers
    parameters = [userId, "null", eventId];
    Event event = await _accessDatabase.getSingleEvent(eventId);
    for (var i=0; i < event.selectedTrainers.length; i++) {
      String trainerId = event.selectedTrainers[i];
      if (trainerId != userId) {
        _accessDatabase.sendNotification(trainerId, "UserLeaveEvent_Trainer", parameters);
        // New Notification
        _accessDatabase.sendNotificationToUser(trainerId, "UserLeaveEvent_Trainer", parameters);
      }
    }
  }
}