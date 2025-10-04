class LocationModel {
  String? pais;
  String? estado;
  String? ciudad;
  String? uid;

  LocationModel({this.pais, this.estado, this.ciudad, this.uid});

  operator [](String other) {}
}
