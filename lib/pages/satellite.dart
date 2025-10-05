import 'package:airshield/apis/openweather_api.dart';
import 'package:airshield/constants.dart';
import 'package:airshield/data/location_data.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../apis/nasa_api.dart';

class Satellite extends StatefulWidget {
  const Satellite({super.key});

  @override
  State<Satellite> createState() => _SatelliteState();
}

class _SatelliteState extends State<Satellite> {
  UbicacionApi clima = UbicacionApi();
  String descripcion = '';

  DateTime? _fechaSeleccionada;

  String mapaVisualizado = "NO₂";
  String? _imagenTempo;
  bool _cargando = true;
  int _imagenSeleccionada = 0;

  // Dentro de tu clase _SatelliteState
  bool _cargandoTemperatura = false;
  List<Map<String, dynamic>> _temperaturasHorarias = [];

  Future<void> _cargarTemperaturas() async {
    setState(() => _cargandoTemperatura = true);

    try {
      final ubicacion = await LocationData.getUserUbication();
      if (ubicacion == null) {
        setState(() => _cargandoTemperatura = false);
        return;
      }

      final pais = ubicacion.pais;
      final estado = ubicacion.estado;
      final municipio = ubicacion.ciudad;
      if (pais == null || estado == null || municipio == null) {
        setState(() => _cargandoTemperatura = false);
        return;
      }

      final coordenadas = await clima.obtenerCoordenadas(
        pais,
        municipio,
        estado,
      );
      if (coordenadas == null) {
        setState(() => _cargandoTemperatura = false);
        return;
      }

      final lat = coordenadas['lat']!;
      final lon = coordenadas['lon']!;

      // 🔹 Obtener temperatura por hora
      final temperaturas = await NasaApi.obtenerTemperaturasHorario(
        latitud: lat,
        longitud: lon,
        fechaSeleccionada:
            _fechaSeleccionada ??
            DateTime.now().subtract(const Duration(days: 1)),
      );

      // 🔹 Obtener AQI
      final dataAQI = await clima.obtenerContaminacion(lat, lon);
      int indiceAQI = -1;
      if (dataAQI != null && dataAQI['main']?['aqi'] != null) {
        indiceAQI = dataAQI['main']['aqi'] as int;
      }

      // 🔹 Combinar temperatura con AQI
      final List<Map<String, dynamic>> combinado = temperaturas.map((item) {
        return {
          'hora': item['hora'],
          'temperatura': item['temperatura'],
          'aqi': indiceAQI >= 0 ? indiceAQI.toString() : 'Not available',
        };
      }).toList();

      setState(() {
        _temperaturasHorarias = combinado;
        _cargandoTemperatura = false;
      });
    } catch (e) {
      setState(() {
        _temperaturasHorarias = [];
        _cargandoTemperatura = false;
      });
    }
  }

  final List<String> etiquetas = ['NO₂', 'HCHO', 'CLDO4'];

  final Map<String, String> descripciones = {
    'NO2':
        'The TEMPO satellite measures the amount of NO₂ in the atmosphere. The satellite provides a '
        'map that shows where there is more or less NO₂ using colors ranging from low to high levels. '
        'This gas mainly comes from the burning of fossil fuels, traffic, and industrial processes.',

    'HCHO':
        'TEMPO also measures the concentration of formaldehyde (HCHO), '
        'a gas that forms in the atmosphere from the breakdown of organic compounds and human emissions. '
        'The API generates a map with HCHO levels, from the lowest to the highest.',

    'CLDO4':
        'Cloud information is displayed, including how much of the sky they cover and how dense they are. '
        'The map provided by TEMPO visually indicates areas with fewer or more clouds, using colors that make it easy '
        'to see where the sky is clear and where cloud coverage is higher.',
  };

  final Map<int, String?> _mapasCargados = {};

  @override
  void initState() {
    super.initState();
    descripcion = descripciones['NO2']!; // Descripción inicial
    _cargarImagenTempo(); // Cargar primer mapa al inicio
  }

  Future<void> _cargarImagenTempo() async {
    setState(() => _cargando = true);

    try {
      if (_mapasCargados.containsKey(_imagenSeleccionada)) {
        setState(() {
          _imagenTempo = _mapasCargados[_imagenSeleccionada];
          _cargando = false;
        });
        return;
      }

      final ubicacion = await LocationData.getUserUbication();
      if (ubicacion == null) {
        setState(() => _cargando = false);
        return;
      }

      final pais = ubicacion.pais;
      final estado = ubicacion.estado;
      final municipio = ubicacion.ciudad;

      if (pais == null || estado == null || municipio == null) {
        setState(() => _cargando = false);
        return;
      }

      final coordenadas = await clima.obtenerCoordenadas(
        pais,
        municipio,
        estado,
      );
      if (coordenadas == null) {
        setState(() => _cargando = false);
        return;
      }

      final lat = coordenadas['lat']!;
      final lon = coordenadas['lon']!;
      String? urlPng;

      if (_imagenSeleccionada == 1) {
        urlPng = await NasaApi.obtenerImagenTempoHCHO(
          latitud: lat,
          longitud: lon,
          fecha: DateTime.now().subtract(const Duration(days: 1)),
        );
      } else if (_imagenSeleccionada == 2) {
        urlPng = await NasaApi.obtenerImagenTempoClodo4(
          latitud: lat,
          longitud: lon,
          fecha: DateTime.now().subtract(const Duration(days: 1)),
        );
      } else {
        urlPng = await NasaApi.obtenerImagenTempo(
          latitud: lat,
          longitud: lon,
          fecha: DateTime.now().subtract(const Duration(days: 1)),
        );
      }

      _mapasCargados[_imagenSeleccionada] = urlPng;

      setState(() {
        _imagenTempo = urlPng;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // 🔹 Encabezado
                  // 🔹 Encabezado con gradiente
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          Color.fromARGB(255, 65, 166, 249),
                          Color.fromARGB(255, 3, 50, 120),
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        Text(
                          mapaVisualizado,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_back,
                          color: Colors.transparent,
                          size: 32,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔹 Botones de selección del mapa
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _imagenSeleccionada = 0;
                            mapaVisualizado = 'NO₂';
                            descripcion = descripciones['NO2']!;
                          });
                          await _cargarImagenTempo();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _imagenSeleccionada == 0
                              ? colorFuerte
                              : Colors.grey[400],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('NO₂'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _imagenSeleccionada = 1;
                            mapaVisualizado = 'HCHO';
                            descripcion = descripciones['HCHO']!;
                          });
                          await _cargarImagenTempo();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _imagenSeleccionada == 1
                              ? colorFuerte
                              : Colors.grey[400],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('HCHO'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _imagenSeleccionada = 2;
                            mapaVisualizado = 'CLDO4';
                            descripcion = descripciones['CLDO4']!;
                          });
                          await _cargarImagenTempo();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _imagenSeleccionada == 2
                              ? colorFuerte
                              : Colors.grey[400],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('CLDO4'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 🔹 Contenedor de la imagen
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _cargando
                        ? const Center(child: CircularProgressIndicator())
                        : _imagenTempo != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              _imagenTempo!,
                              fit: BoxFit.cover,
                              alignment: Alignment.bottomCenter,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Text(
                                      'Error al cargar imagen.',
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                  ),
                            ),
                          )
                        : const Center(
                            child: Text(
                              'No se encontró imagen para esta ubicación.',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                  ),

                  // 🔹 Descripción dinámica con estilo de tarjeta
                  if (descripcion.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card(
                      elevation: 3,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          descripcion,
                          style: const TextStyle(
                            fontSize: 16, // 🔹 Más grande
                            color: Colors.black87,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // 🔹 Card secundaria
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Select date from history",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _fechaSeleccionada != null
                                    ? "${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}"
                                    : "Indefinite",
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        _fechaSeleccionada ??
                                        DateTime.now().subtract(
                                          const Duration(days: 1),
                                        ),
                                    firstDate: DateTime(2023, 1, 1),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null &&
                                      picked != _fechaSeleccionada) {
                                    setState(() {
                                      _fechaSeleccionada = picked;
                                    });
                                    await _cargarTemperaturas();
                                  }
                                },
                                icon: const Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                ),
                                label: const Text("Change date"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorFuerte,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // 🔹 Listado de temperaturas horarias
                          SizedBox(
                            height: 300, // Ajusta según necesidad
                            child: _cargandoTemperatura
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : (_temperaturasHorarias.isEmpty
                                      ? const Center(
                                          child: Text(
                                            "Find a date to display information",
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black54,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      : ListView.separated(
                                          itemCount:
                                              _temperaturasHorarias.length,
                                          separatorBuilder: (_, __) =>
                                              const Divider(),
                                          itemBuilder: (context, index) {
                                            final item =
                                                _temperaturasHorarias[index];
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  item['hora'],
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                Text(
                                                  "${item['temperatura']}  |  AQI: ${item['aqi']}",
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
