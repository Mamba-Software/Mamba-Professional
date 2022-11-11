import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';


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
    List<Usuario> listUsers = await _eventDataService.getEventUsers(eventId);
    for (var i=0; i<listUsers.length; i++) {
      Usuario trainer = listUsers[i];
      if (trainer.isTrainer! && trainer.id! != userId) {
        // New Notification
        _userDataService.sendNotificationToUser(trainer.id!, "UserJoinEvent_Trainer", parameters);
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
    List<Usuario> listUsers = await _eventDataService.getEventUsers(eventId);
    for (var i=0; i<listUsers.length; i++) {
      Usuario trainer = listUsers[i];
      if (trainer.isTrainer! && trainer.id! != userId) {
        // New Notification
        _userDataService.sendNotificationToUser(trainer.id!, "UserLeaveEvent_Trainer", parameters);
      }
    }
  }

  Future<void> userBuysBono(String userId, String brandId, Bono bono) async {
    // Notification to the User Joining
    var parameters = ["null", brandId, "null", "null", bono.id];
    _userDataService.sendNotificationToUser(userId, "UserBuysBono_User", parameters);
    // Notification to All Brand Trainers
    parameters = [userId, brandId, "null", "null", bono.id,];
    List<Usuario> listUsers = await _brandDataService.getBrandTrainers(brandId);
    for (var i=0; i<listUsers.length; i++) {
      Usuario trainer = listUsers[i];
      if (trainer.id! != userId) {
        // New Notification
        _userDataService.sendNotificationToUser(trainer.id!, "UserBuysBono_Trainer", parameters);
      }
    }
  }
}