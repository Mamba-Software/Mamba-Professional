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
  }

  Future<void> userCreatesBrand(String userId, String brandId) async {
    // Notification to the User Joining
    Brand brand = await _accessDatabase.getBrandDetails(brandId);
    var parameters = [brandId, brand.logoUrl, brand.name!];
    _accessDatabase.sendNotification(userId, "UserCreatesBrand_User", parameters);
  }

  Future<void> userJoinsBrand(String userId, String brandId) async {
    // Notification to the User Joining
    Usuario user = await _accessDatabase.getUserDetails(userId);
    Brand brand = await _accessDatabase.getBrandDetails(brandId);
    var parameters = [brandId, brand.logoUrl, brand.name!];
    _accessDatabase.sendNotification(userId, "UserJoinsBrand_User", parameters);
    // Notification to All Brand Trainers
    List<Usuario> listUsers = await _accessDatabase.getAllTrainersFromBrand(brandId);
    int members = brand.numberClients! + brand.numberTrainers!;
    parameters = [userId, user.imageUrl!, user.name!, brand.name!,members.toString()];
    for (var i=0; i<listUsers.length; i++) {
      Usuario trainer = listUsers[i];
      if (trainer.id! != userId) {
        _accessDatabase.sendNotification(trainer.id!, "UserJoinsBrand_Trainer", parameters);
      }
    }
  }

  Future<void> userLeavesBrand(String userId, String brandId) async {
    // Notification to the User Joining
    Usuario user = await _accessDatabase.getUserDetails(userId);
    Brand brand = await _accessDatabase.getBrandDetails(brandId);
    var parameters = [brandId, brand.logoUrl, brand.name!];
    _accessDatabase.sendNotification(userId, "UserLeavesBrand_User", parameters);
    // Notification to All Brand Trainers
    List<Usuario> listUsers = await _accessDatabase.getAllTrainersFromBrand(brandId);
    int members = brand.numberClients! + brand.numberTrainers!;
    parameters = [userId, user.imageUrl!, user.name!, brand.name!, members.toString()];
    for (var i=0; i<listUsers.length; i++) {
      Usuario trainer = listUsers[i];
      if (trainer.id! != userId) {
        _accessDatabase.sendNotification(trainer.id!, "UserLeavesBrand_Trainer", parameters);
      }
    }
  }

  Future<void> userSendRequestToBrand(String userId, String brandId) async {
    // Notification to the User Joining
    Usuario user = await _accessDatabase.getUserDetails(userId);
    RequestToBrand? req = await _accessDatabase.hasPendingRequest(userId);
    Brand brand = await _accessDatabase.getBrandDetails(brandId);
    var parameters = [brandId, brand.logoUrl, brand.name!];
    _accessDatabase.sendNotification(userId, "UserSendRequestToBrand_User", parameters);
    // Notification to All Brand Trainers
    List<Usuario> listUsers = await _accessDatabase.getAllTrainersFromBrand(brandId);
    parameters = [userId, user.imageUrl!, user.name!, req!.dateSent, brandId];
    for (var i=0; i<listUsers.length; i++) {
      Usuario trainer = listUsers[i];
      if (trainer.id! != userId) {
        _accessDatabase.sendNotification(trainer.id!, "UserSendRequestToBrand_Trainer", parameters);
      }
    }
  }

  Future<void> userCancelRequestToBrand(String userId, String brandId) async {
    // Notification to the User Canceling Request
    Usuario user = await _accessDatabase.getUserDetails(userId);
    Brand brand = await _accessDatabase.getBrandDetails(brandId);
    var parameters = [brandId, brand.logoUrl, brand.name!];
    _accessDatabase.sendNotification(userId, "UserCancelRequestToBrand_User", parameters);
    // Notification to All Brand Trainers
    List<Usuario> listUsers = await _accessDatabase.getAllTrainersFromBrand(brandId);
    parameters = [userId, user.imageUrl!, user.name!, brandId];
    for (var i=0; i<listUsers.length; i++) {
      Usuario trainer = listUsers[i];
      if (trainer.id! != userId) {
        _accessDatabase.sendNotification(trainer.id!, "UserCancelRequestToBrand_Trainer", parameters);
      }
    }
  }


  Future<void> joinEvent(String userId, String eventId) async {
    Usuario usuario = await _accessDatabase.getUserDetails(userId);
    Event event = await _accessDatabase.getSingleEvent(eventId);
    //String title = AppLocalizations.of(this.context!)!.joinEventTitleNotification(usuario.name!, event.title!);
    var startDate = DateTime(
      int.parse(event.year!),
      int.parse(event.month!),
      int.parse(event.day!),
      int.parse(event.hour!),
      int.parse(event.minute!),
    );
    //String eventTimeDay = DateFormat('EE dd/MM/yy', Localizations.localeOf(this.context!).languageCode).format(startDate);
    //String eventTimeTime = "${event.hour.toString()}:${event.minute=="0" ? "00" : event.minute.toString()}h";
    //String subtitle = AppLocalizations.of(this.context!)!.joinEventSubtitleNotification(eventTimeDay, eventTimeTime);
    var parameters = [usuario.imageUrl, eventId];
    for (var i=0; i<event.selectedTrainers.length!; i++) {
      //_accessDatabase.sendNotification(event.selectedTrainers[i], "EventJoined", false, title, subtitle, parameters);
    }
  }
}