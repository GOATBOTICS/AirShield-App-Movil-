import 'package:airshield/models/location_model.dart';

class LocationData {
  // Instancia privada
  static final LocationData _instance = LocationData._internal();

  LocationModel? _location;

  LocationData._internal();

  static LocationData get instance => _instance;

  void setLocation(LocationModel location) {
    _location = location;
  }

  LocationModel? get location => _location;

  void clear() {
    _location = null;
  }
}