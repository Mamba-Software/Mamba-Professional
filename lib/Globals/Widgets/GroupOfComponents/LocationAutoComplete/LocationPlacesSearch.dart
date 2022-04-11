import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';

class Place {
  String? streetNumber;
  String? street;
  String? city;
  String? zipCode;
  String? fullAddress;

  Place({
    this.streetNumber,
    this.street,
    this.city,
    this.zipCode,
    this.fullAddress,
  });

  @override
  String toString() {
    return 'Place(streetNumber: $streetNumber, street: $street, city: $city, zipCode: $zipCode, fullAddress: $fullAddress)';
  }
}

class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}

class LocationPlacesSearch {

  static final String androidKey = placesAPIAndroid;
  static final String iosKey = placesAPIIOS;
  final apiKey = Platform.isAndroid ? androidKey : iosKey;
  var sessionToken;
  var language;
  var radius = 10000;

  LocationPlacesSearch(String sessionToken, String language) {
    this.sessionToken = sessionToken;
    this.language = language;
  }

  Future<List<Suggestion>> fetchSuggestions(String input) async {
    String coordinates = "";
    if (currentPosition != null) {
      var latitude = currentPosition!.latitude;
      var longitude = currentPosition!.longitude;
      coordinates = "&location=$latitude,$longitude&radius=$radius";
    }
    final request = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&language=$language$coordinates&key=$apiKey&sessiontoken=$sessionToken';
    final response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions']
            .map<Suggestion>((p) => Suggestion(p['place_id'], p['description']))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<Place> getPlaceDetailFromId(String placeId) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=address_component&key=$apiKey&sessiontoken=$sessionToken';
    final response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        final components =
        result['result']['address_components'] as List<dynamic>;
        // build result
        final place = Place();
        components.forEach((c) {
          final List type = c['types'];
          if (type.contains('route')) {
            place.street = c['long_name'];
            place.fullAddress = "${c['long_name']},";
          }
          if (type.contains('street_number')) {
            place.streetNumber = c['long_name'];
            place.fullAddress = "${place.fullAddress} ${c['long_name']},";
          }
          if (type.contains('locality')) {
            place.city = c['long_name'];
            place.fullAddress = "${place.fullAddress} ${c['long_name']},";
          }
          if (type.contains('postal_code')) {
            place.zipCode = c['long_name'];
            place.fullAddress = "${place.fullAddress} ${c['long_name']}";
          }
        });
        return place;
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}