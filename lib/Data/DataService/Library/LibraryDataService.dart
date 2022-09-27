import 'package:mamba_castelldefels/Data/DataService/Library/LibraryFirebaseCalls.dart';
import 'package:mamba_castelldefels/Data/LibraryModels/lColor.dart';
import 'package:mamba_castelldefels/Data/LibraryModels/lDegradate.dart';
import 'package:mamba_castelldefels/Data/LibraryModels/lPaymentMethod.dart';

// This class gives access to all of the Firebase Backend. This is the Data provider for the UI.
class LibraryDataService {

  final _firebase = LibraryFirebaseCalls();

  // Colors Data
  Future<List<lColor>> getColors() => _firebase.getColors();
  Future<List<lDegradate>> getDegradates() => _firebase.getDegradates();

  // Payment Methods Data
  Future<List<lPaymentMethod>> getPaymentMethods() => _firebase.getPaymentMethods();

  // Event Photos
  Future<String> getRandomEventPhoto() => _firebase.getRandomEventPhoto();

}