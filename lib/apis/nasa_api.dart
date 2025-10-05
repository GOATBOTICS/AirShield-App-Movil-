import 'dart:convert';
import 'package:http/http.dart' as http;

class NasaApi {
  static Future<String?> obtenerImagenTempo({
    required double latitud,
    required double longitud,
    required DateTime fecha,
  }) async {
    try {
      final fechaStr = fecha.toIso8601String().split('T').first;

      final temporal = '${fechaStr}T00:00:00Z,${fechaStr}T23:59:59Z';

      final double delta = 0.5;
      final double minLon = longitud - delta;
      final double minLat = latitud - delta;
      final double maxLon = longitud + delta;
      final double maxLat = latitud + delta;

      final url =
          'https://cmr.earthdata.nasa.gov/search/granules.json?short_name=TEMPO_NO2_L3&temporal=$temporal&bounding_box=$minLon,$minLat,$maxLon,$maxLat';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body);

      // Validar estructura
      final entries = data['feed']?['entry'];
      if (entries == null || entries.isEmpty) {
        return null;
      }

      // Primer entry
      final entry = entries.first;

      // Buscar link con .png
      if (entry['links'] != null) {
        for (final link in entry['links']) {
          final href = link['href'];
          if (href != null && href.toString().endsWith('.png')) {
            return href.toString();
          }
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// 🔹 Nuevo método para obtener imagen TEMPO CLDO4 (nubes o ozono)
  static Future<String?> obtenerImagenTempoClodo4({
    required double latitud,
    required double longitud,
    required DateTime fecha,
  }) async {
    try {
      final fechaStr = fecha.toIso8601String().split('T').first;
      final temporal = '${fechaStr}T00:00:00Z,${fechaStr}T23:59:59Z';
      const delta = 0.5;
      final minLon = longitud - delta;
      final minLat = latitud - delta;
      final maxLon = longitud + delta;
      final maxLat = latitud + delta;

      final url =
          'https://cmr.earthdata.nasa.gov/search/granules.json?short_name=TEMPO_CLDO4_L3&temporal=$temporal&bounding_box=$minLon,$minLat,$maxLon,$maxLat';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body);
      final entries = data['feed']?['entry'];
      if (entries == null || entries.isEmpty) {
        return null;
      }

      final entry = entries.first;

      if (entry['links'] != null) {
        for (final link in entry['links']) {
          final href = link['href'];
          if (href != null && href.toString().endsWith('.png')) {
            return href.toString();
          }
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// 🔹 Nuevo método para obtener imagen TEMPO HCHO
  static Future<String?> obtenerImagenTempoHCHO({
    required double latitud,
    required double longitud,
    required DateTime fecha,
  }) async {
    try {
      final fechaStr = fecha.toIso8601String().split('T').first;
      final temporal = '${fechaStr}T00:00:00Z,${fechaStr}T23:59:59Z';
      const delta = 0.5;
      final minLon = longitud - delta;
      final minLat = latitud - delta;
      final maxLon = longitud + delta;
      final maxLat = latitud + delta;

      final url =
          'https://cmr.earthdata.nasa.gov/search/granules.json?short_name=TEMPO_HCHO_L2&temporal=$temporal&bounding_box=$minLon,$minLat,$maxLon,$maxLat';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body);
      final entries = data['feed']?['entry'];
      if (entries == null || entries.isEmpty) {
        return null;
      }

      final entry = entries.first;

      if (entry['links'] != null) {
        for (final link in entry['links']) {
          final href = link['href'];
          if (href != null && href.toString().endsWith('.png')) {
            return href.toString();
          }
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// 🔹 Nuevo método para obtener temperaturas horarias (NASA POWER API) de una sola fecha
  static Future<List<Map<String, dynamic>>> obtenerTemperaturasHorario({
    required double latitud,
    required double longitud,
    required DateTime fechaSeleccionada,
  }) async {
    try {
      // 🔹 Convertir fecha al formato YYYYMMDD
      final fechaStr =
          "${fechaSeleccionada.year}"
          "${fechaSeleccionada.month.toString().padLeft(2, '0')}"
          "${fechaSeleccionada.day.toString().padLeft(2, '0')}";

      final url =
          'https://power.larc.nasa.gov/api/temporal/hourly/point?latitude=$latitud&longitude=$longitud&community=ag&parameters=T2M&start=$fechaStr&end=$fechaStr';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        return [];
      }

      final data = json.decode(response.body);

      // 🔹 Acceso a los valores horarios
      final Map<String, dynamic>? valoresT2M =
          data['properties']?['parameter']?['T2M']?.cast<String, dynamic>();

      if (valoresT2M == null) {
        return [];
      }

      // 🔹 Convertir cada clave (ej. "2025100400") a formato legible
      final List<Map<String, dynamic>> listaTemperaturas = [];

      valoresT2M.forEach((hora, valor) {
        final horaLocal = hora.substring(8, 10); // "00", "01", etc.
        final fechaFormateada =
            "${hora.substring(6, 8)}/${hora.substring(4, 6)}/${hora.substring(0, 4)}";

        listaTemperaturas.add({
          "fecha": fechaFormateada,
          "hora": "$horaLocal:00",
          "temperatura": (valor == -999)
              ? "Not available"
              : "${valor.toString()} °C",
        });
      });

      return listaTemperaturas;
    } catch (e) {
      return [];
    }
  }
}
