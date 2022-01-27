import 'package:mamba_castelldefels/Data/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DatabaseAccess.dart';
import 'package:mamba_castelldefels/Data/EventDataService.dart';
import 'package:mamba_castelldefels/Data/UserDataService.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';

class NotificationService {

  // Acceso a Base de Datos
  var _userDataService = new UserDataService();
  var _brandDataService = new BrandDataService();
  var _eventDataService = new EventDataService();

  NotificationService();

  Future<void> wellcomeUser(String userId) async {
    var parameters = [];
    // New Notification
    _userDataService.sendNotificationToUser(userId, "Wellcome_User", parameters);
  }

  Future<void> userCreatesBrand(String userId, String brandId) async {
    // Notification to the User Joining
    var parameters = ["null", brandId, "null"];
    // New Notification
    _userDataService.sendNotificationToUser(userId, "UserCreatesBrand_User", parameters);
  }

  Future<void> userDeletesBrand(String userId, String brandId) async {
    // Notification to the User Joining
    var parameters = ["null", brandId, "null"];
    // New Notification
    _userDataService.sendNotificationToUser(userId, "UserDeletesBrand_Owner", parameters);
    /*
    List<Usuario> brandUsers = await _userDataService.getAllClientsFromBrand(brandId);
    brandUsers.addAll(await _userDataService.getAllTrainersFromBrand(brandId));
    for (var i=0; i<brandUsers.length; i++) {
      Usuario user = brandUsers[i];
      if (user.id! != userId) {
        _userDataService.sendNotification(user.id!, "UserDeletesBrand_User", parameters);
      }
    }
     */
  }

  Future<void> userJoinsBrand(String userId, String brandId) async {
    // Notification to the User Joining
    Brand brand = await _brandDataService.getBrandDetails(brandId);
    var parameters = ["null", brandId, "null"];
    // New Notification
    _userDataService.sendNotificationToUser(userId, "UserJoinsBrand_User", parameters);
    // Notification to All Brand Trainers
    List<Usuario> listUsers = await _brandDataService.getBrandTrainers(brandId);
    int members = brand.numClients! + brand.numTrainers! + 1;
    parameters = [userId, brandId, "null", members.toString()];
    for (var i=0; i<listUsers.length; i++) {
      Usuario trainer = listUsers[i];
      if (trainer.id! != userId) {
        // New Notification
        _userDataService.sendNotificationToUser(trainer.id!, "UserJoinsBrand_Trainer", parameters);
      }
    }
  }

  Future<void> userLeavesBrand(String userId, String brandId) async {
    // Notification to the User Joining
    Brand brand = await _brandDataService.getBrandDetails(brandId);
    var parameters = ["null", brandId, "null"];
    // New Notification
    _userDataService.sendNotificationToUser(userId, "UserLeavesBrand_User", parameters);
    // Notification to All Brand Trainers
    int members = brand.numClients! + brand.numTrainers! - 1;
    parameters = [userId, brandId, "null", members.toString()];
    List<Usuario> listUsers = await _brandDataService.getBrandTrainers(brandId);
    for (var i=0; i<listUsers.length; i++) {
      Usuario trainer = listUsers[i];
      if (trainer.id! != userId) {
        // New Notification
        _userDataService.sendNotificationToUser(trainer.id!, "UserLeavesBrand_Trainer", parameters);
      }
    }
  }

  Future<void> userSendRequestToBrand(String userId, String brandId) async {
    // Notification to the User Joining
    // TODO: Adapt to New Database
    List<RequestToBrand> requests = await _userDataService.getUserRequests(userId);
    RequestToBrand req = requests[0];
    var parameters = ["null", brandId, "null",];
    // New Notification
    _userDataService.sendNotificationToUser(userId, "UserSendRequestToBrand_User", parameters);
    // Notification to All Brand Trainers
    parameters = [userId, brandId, "null", req.dateSent!,];
    List<Usuario> listUsers = await _brandDataService.getBrandTrainers(brandId);
    for (var i=0; i<listUsers.length; i++) {
      Usuario trainer = listUsers[i];
      if (trainer.id! != userId) {
        // New Notification
        _userDataService.sendNotificationToUser(trainer.id!, "UserSendRequestToBrand_Trainer", parameters);
      }
    }
  }

  Future<void> userCancelRequestToBrand(String userId, String brandId) async {
    // Notification to the User Canceling Request
    var parameters = ["null", brandId, "null",];
    // New Notification
    _userDataService.sendNotificationToUser(userId, "UserCancelRequestToBrand_User", parameters);
    // Notification to All Brand Trainers
    List<Usuario> listUsers = await _brandDataService.getBrandTrainers(brandId);
    parameters = [userId, brandId, "null",];
    for (var i=0; i<listUsers.length; i++) {
      Usuario trainer = listUsers[i];
      if (trainer.id! != userId) {
        // New Notification
        _userDataService.sendNotificationToUser(trainer.id!, "UserCancelRequestToBrand_Trainer", parameters);
      }
    }
  }

  Future<void> userJoinEvent(String userId, String brandId, String eventId) async {
    // Notification to the User Joining Event
    var parameters = ["null", brandId, eventId];
    // New Notification
    _userDataService.sendNotificationToUser(userId, "UserJoinEvent_User", parameters);
    // Notification to All Event Trainers
    parameters = [userId, "null", eventId];
    Event event = await _eventDataService.getSingleEvent(eventId);
    for (var i=0; i < event.selectedTrainers.length; i++) {
      String trainerId = event.selectedTrainers[i];
      if (trainerId != userId) {
        // New Notification
        _userDataService.sendNotificationToUser(trainerId, "UserJoinEvent_Trainer", parameters);
      }
    }
  }

  Future<void> userLeaveEvent(String userId, String brandId, String eventId) async {
    // Notification to the User Joining Event
    var parameters = ["null", brandId, eventId];
    // New Notification
    _userDataService.sendNotificationToUser(userId, "UserLeaveEvent_User", parameters);
    // Notification to All Event Trainers
    parameters = [userId, "null", eventId];
    Event event = await _eventDataService.getSingleEvent(eventId);
    for (var i=0; i < event.selectedTrainers.length; i++) {
      String trainerId = event.selectedTrainers[i];
      if (trainerId != userId) {
        // New Notification
        _userDataService.sendNotificationToUser(trainerId, "UserLeaveEvent_Trainer", parameters);
      }
    }
  }
}