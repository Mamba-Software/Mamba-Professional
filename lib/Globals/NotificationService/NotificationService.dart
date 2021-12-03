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

  // Contexto per al Idioma
  BuildContext? context;
  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();

  NotificationService(BuildContext context) {
    this.context = context;
  }

  Future<void> wellcomeUser(String userId) async {
    String title = AppLocalizations.of(this.context!)!.wellcomeToMAMBA;
    String subtitle = AppLocalizations.of(this.context!)!.onlyImportantNotifications;
    var parameters = [];
    _accessDatabase.sendNotification(userId, "Wellcome_User", false, title, subtitle, parameters);
  }

  Future<void> userJoinsBrand(String userId, String brandId) async {
    // Notification to the User Joining
    Usuario user = await _accessDatabase.getUserDetails(userId);
    Brand brand = await _accessDatabase.getBrandDetails(brandId);
    String title = AppLocalizations.of(this.context!)!.userJoinsBrandUser(brand.name!);
    String subtitle = AppLocalizations.of(this.context!)!.userJoinsBrandSubtitleUser;
    var parameters = [brandId, brand.logoUrl];
    _accessDatabase.sendNotification(userId, "UserJoinsBrand_User", false, title, subtitle, parameters);
    // Notification to All Brand Trainers
    List<Usuario> listUsers = await _accessDatabase.getAllTrainersFromBrand(brandId);
    title = AppLocalizations.of(this.context!)!.userJoinsBrandBrand(user.name!, brand.name!);
    subtitle = AppLocalizations.of(this.context!)!.userJoinsBrandBrandSubtitle(brand.maxMembers.toString());
    parameters = [userId, user.imageUrl!];
    for (var i=0; i<listUsers.length; i++) {
      Usuario trainer = listUsers[i];
      if (trainer.id! != userId) {
        _accessDatabase.sendNotification(trainer.id!, "UserJoinsBrand_Trainer", false, title, subtitle, parameters);
      }
    }
  }

  Future<void> userLeavesBrand(String userId, String brandId) async {
    // Notification to the User Joining
    Usuario user = await _accessDatabase.getUserDetails(userId);
    Brand brand = await _accessDatabase.getBrandDetails(brandId);
    String title = AppLocalizations.of(this.context!)!.userLeavesBrandUser(brand.name!);
    String subtitle = AppLocalizations.of(this.context!)!.userLeavesBrandUserSubtitle;
    var parameters = [brandId, brand.logoUrl];
    _accessDatabase.sendNotification(userId, "UserLeavesBrand_User", false, title, subtitle, parameters);
    // Notification to All Brand Trainers
    List<Usuario> listUsers = await _accessDatabase.getAllTrainersFromBrand(brandId);
    title = AppLocalizations.of(this.context!)!.userLeavesBrandBrand(user.name!, brand.name!);
    subtitle = AppLocalizations.of(this.context!)!.userLeavesBrandBrandSubtitle(brand.maxMembers.toString());
    parameters = [userId, user.imageUrl!];
    for (var i=0; i<listUsers.length; i++) {
      Usuario trainer = listUsers[i];
      if (trainer.id! != userId) {
        _accessDatabase.sendNotification(trainer.id!, "UserLeavesBrand_Trainer", false, title, subtitle, parameters);
      }
    }
  }

  Future<void> userSendRequestToBrand(String userId, String brandId) async {
    // Notification to the User Joining
    Usuario user = await _accessDatabase.getUserDetails(userId);
    RequestToBrand? req = await _accessDatabase.hasPendingRequest(userId);
    Brand brand = await _accessDatabase.getBrandDetails(brandId);
    String title = AppLocalizations.of(this.context!)!.userSendRequestToBrandUser(brand.name!);
    String subtitle = AppLocalizations.of(this.context!)!.userSendRequestToBrandUserSubtitle;
    var parameters = [brandId, brand.logoUrl];
    _accessDatabase.sendNotification(userId, "UserSendRequestToBrand_User", false, title, subtitle, parameters);
    // Notification to All Brand Trainers
    List<Usuario> listUsers = await _accessDatabase.getAllTrainersFromBrand(brandId);
    title = AppLocalizations.of(this.context!)!.userSendRequestToBrandBrand(user.name!);
    var startDate = DateTime(
      int.parse(req!.year!),
      int.parse(req.month!),
      int.parse(req.day!),
    );
    String eventTimeDay = DateFormat('EE dd/MM/yy', Localizations.localeOf(this.context!).languageCode).format(startDate);
    subtitle = AppLocalizations.of(this.context!)!.userSendRequestToBrandBrandSubtitle(eventTimeDay);
    parameters = [userId, user.imageUrl!, brandId];
    for (var i=0; i<listUsers.length; i++) {
      Usuario trainer = listUsers[i];
      if (trainer.id! != userId) {
        _accessDatabase.sendNotification(trainer.id!, "UserSendRequestToBrand_Trainer", false, title, subtitle, parameters);
      }
    }
  }

  Future<void> joinEvent(String userId, String eventId) async {
    Usuario usuario = await _accessDatabase.getUserDetails(userId);
    Event event = await _accessDatabase.getSingleEvent(eventId);
    String title = AppLocalizations.of(this.context!)!.joinEventTitleNotification(usuario.name!, event.title!);
    var startDate = DateTime(
      int.parse(event.year!),
      int.parse(event.month!),
      int.parse(event.day!),
      int.parse(event.hour!),
      int.parse(event.minute!),
    );
    String eventTimeDay = DateFormat('EE dd/MM/yy', Localizations.localeOf(this.context!).languageCode).format(startDate);
    String eventTimeTime = "${event.hour.toString()}:${event.minute=="0" ? "00" : event.minute.toString()}h";
    String subtitle = AppLocalizations.of(this.context!)!.joinEventSubtitleNotification(eventTimeDay, eventTimeTime);
    var parameters = [usuario.imageUrl, eventId];
    for (var i=0; i<event.selectedTrainers.length!; i++) {
      _accessDatabase.sendNotification(event.selectedTrainers[i], "EventJoined", false, title, subtitle, parameters);
    }
  }
}