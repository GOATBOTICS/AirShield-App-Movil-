import 'dart:convert';
import 'package:airshield/apis/variables.dart';
import 'package:http/http.dart' as http;

class UbicacionApi {
  final String apiKey = Variables.apiKey;

  // Método para obtener las coordenadas
  Future<Map<String, double>?> obtenerCoordenadas(
      String pais, String municipio, String estado) async {
    final geoUrl = Uri.parse(
        'http://api.openweathermap.org/geo/1.0/direct?q=$municipio,$estado,$pais&limit=1&appid=$apiKey');

    try {
      final response = await http.get(geoUrl);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isEmpty) {
          return null;
        }

        final lat = data[0]['lat'];
        final lon = data[0]['lon'];

        return {'lat': lat, 'lon': lon};
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
