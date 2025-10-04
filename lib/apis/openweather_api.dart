import 'dart:convert';
import 'package:airshield/apis/variables.dart';
import 'package:http/http.dart' as http;

class UbicacionApi {
  final String apiKey = Variables.apiKey;

  Future<Map<String, dynamic>> obtenerCondicionesActuales(
    double lat,
    double lon,
  ) async {
    final String apiKey = Variables.apiKey;

    final String url =
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final Map<String, dynamic> main = data['main'];
        final Map<String, dynamic> viento = data['wind'];

        final double temperatura = main['temp']; // Temperatura °C
        final int humedad = main['humidity']; // Humedad %
        double velocidad = viento['speed'] * 3.6; // Viento en km/h
        velocidad = double.parse(velocidad.toStringAsFixed(1));

        // Solo agrega presión si existe en la respuesta
        Map<String, dynamic> resultado = {
          "temperatura": temperatura,
          "humedad": humedad,
          "velocidad": velocidad,
        };

        if (main.containsKey('pressure')) {
          resultado["presion"] = main['pressure']; // Presión en hPa
        }

        return resultado;
      } else {
        return {
          "error":
              "Error al obtener las condiciones actuales. Código: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "error": "Error al obtener las condiciones actuales. Detalle: $e",
      };
    }
  }

  // Método para obtener las coordenadas
  Future<Map<String, double>?> obtenerCoordenadas(
    String pais,
    String municipio,
    String estado,
  ) async {
    final geoUrl = Uri.parse(
      'http://api.openweathermap.org/geo/1.0/direct?q=$municipio,$estado,$pais&limit=1&appid=$apiKey',
    );

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
