import 'package:airshield/apis/variables.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NasaApi {
  Future<Map<String, dynamic>?> obtenerContaminacion(
    double lat,
    double lon,
  ) async {
    final String apiKey = Variables.apiKey;

    final airPollutionUrl = Uri.parse(
      'http://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey',
    );

    try {
      final response = await http.get(airPollutionUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['list'] != null && data['list'].isNotEmpty) {
          return data['list'][0];
        }
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
