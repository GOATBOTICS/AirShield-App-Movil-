import 'package:airshield/models/location_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationData {
  static Future<LocationModel?> getUserUbication(String uid) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('userLocation')
          .doc(uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;

        return LocationModel(
          pais: data['pais'] ?? 'Desconocido',
          estado: data['estado'] ?? 'Desconocido',
          ciudad: data['municipio'] ?? 'Desconocido',
          uid: uid,
        );
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }
}
