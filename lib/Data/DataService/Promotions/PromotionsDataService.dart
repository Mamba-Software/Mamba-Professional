import 'package:mamba_castelldefels/Data/Models/Subscription.dart';
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