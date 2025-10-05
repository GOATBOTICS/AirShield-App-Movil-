import 'package:airshield/models/location_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationData {
  static Future<LocationModel?> getUserUbication() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Leer datos almacenados localmente, con valores por defecto
      final pais = prefs.getString('pais') ?? 'Desconocido';
      final estado = prefs.getString('estado') ?? 'Desconocido';
      final ciudad = prefs.getString('ciudad') ?? 'Desconocido';

      // Retornar el LocationModel con los datos locales
      return LocationModel(
        pais: pais,
        estado: estado,
        ciudad: ciudad,
      );
    } catch (e) {
      rethrow;
    }
  }
}
