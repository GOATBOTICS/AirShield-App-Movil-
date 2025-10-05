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
}
