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

  String mapaVisualizado = "Mapa Satelital";
  String? _imagenTempo;
  bool _cargando = true;
  int _imagenSeleccionada = 0;

  final List<String> etiquetas = ['NO₂', 'HCHO', 'CLDO4'];

  final Map<String, String> descripciones = {
    'NO2':
        'El satélite TEMPO mide la cantidad de NO₂ en la atmósfera. El satélite proporciona un '
        'mapa que muestra dónde hay más o menos NO₂ usando colores que van de bajos a altos niveles. '
        'Este gas proviene principalmente de la quema de combustibles fósiles, tráfico y procesos industriales',

    'HCHO':
        'TEMPO también mide la concentración de formaldehído (HCHO), '
        'un gas que se forma en la atmósfera por la descomposición de compuestos orgánicos y emisiones humanas.'
        'La API genera un mapa con los niveles de HCHO, desde los más bajos hasta los más altos.',

    'CLDO4':
        'Se muestra la información de las nubes, incluyendo cuánto cubren el cielo y qué tan densas son. '
        'El mapa que devuelve TEMPO indica de manera visual las zonas con menos o más nubes, usando colores que facilitan '
        'ver dónde hay cielo despejado y dónde hay mayor cobertura nubosa.',
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
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Histórico de ayer",
                        style: TextStyle(fontSize: 15),
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
