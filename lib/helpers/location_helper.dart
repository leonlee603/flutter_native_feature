import 'dart:convert';
import 'package:http/http.dart' as http;

const googleApiKey = 'YOUR API KEY HERE';

class LocationHelper {
  static String generateLocationPreviewImage(
      {required double latitude, required double longitude}) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=&$latitude,$longitude&zoom=17&size=600x300&maptype=roadmap&markers=color:red%7Clabel:C%7C$latitude,$longitude&key=$googleApiKey';
  }

  static Future<String> getPlaceAddress(double lat, double lng) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleApiKey');
    final response = await http.get(url);
    // print(json.decode(response.body));
    return json.decode(response.body)['results'][0]['formatted_address'] ??
        'Unknown place';
  }
}
