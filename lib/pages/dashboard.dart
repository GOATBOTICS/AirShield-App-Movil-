import 'dart:async';

import 'package:airshield/apis/openweather_api.dart';
import 'package:airshield/constants.dart';
import 'package:airshield/data/location_data.dart';
import 'package:airshield/pages/location.dart';
import 'package:airshield/pages/report.dart';
import 'package:airshield/pages/satellite.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  UbicacionApi clima = UbicacionApi();
  String temperatura = '...';
  String humedad = '...';
  String velocidad = '...';
  String presion = '...';
  String ciudad = "...";
  // Dentro de tu clase State<>
  double co = 0;
  double no = 0;
  double no2 = 0;
  double o3 = 0;
  double so2 = 0;
  double pm2_5 = 0;
  double pm10 = 0;
  double nh3 = 0;
  int indice = 0; // AQI

  Timer? _updateTimer;
  int _minutesRemaining = 10;

  @override
  void initState() {
    super.initState();
    obtenerClima();

    _updateTimer = Timer.periodic(const Duration(minutes: 10), (_) async {
      setState(() {
        co = 0;
        no = 0;
        no2 = 0;
        o3 = 0;
        so2 = 0;
        pm2_5 = 0;
        pm10 = 0;
        nh3 = 0;
        indice = 0;

        temperatura = '...';
        humedad = '...';
        velocidad = '...';
        presion = '...';
      });

      // Pequeña espera antes de recargar
      await Future.delayed(const Duration(milliseconds: 500));

      // Recargar datos de clima y contaminación
      obtenerClima();
    });
    iniciarTimerActualizacion();
  }

  @override
  void dispose() {
    // Cancelar timer al cerrar el widget
    _updateTimer?.cancel();
    super.dispose();
  }

  void iniciarTimerActualizacion() {
    _updateTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (_minutesRemaining > 1) {
        setState(() {
          _minutesRemaining--;
        });
      } else {
        // Reiniciar contador y actualizar datos
        setState(() {
          co = 0;
          no = 0;
          no2 = 0;
          o3 = 0;
          so2 = 0;
          pm2_5 = 0;
          pm10 = 0;
          nh3 = 0;
          indice = 0;

          temperatura = '...';
          humedad = '...';
          velocidad = '...';
          presion = '...';
          _minutesRemaining = 10; // reiniciar el contador a 10 minutos
        });

        await Future.delayed(const Duration(milliseconds: 500));
        obtenerClima();
      }
    });
  }

  Map<String, String> getRecomendacion(int indice) {
    switch (indice) {
      case 1:
        return {
          'subtitulo': 'Excellent for outdoor sports',
          'descripcion':
              'Air quality is perfect for exercising and outdoor activities.',
        };
      case 2:
        return {
          'subtitulo': 'Good for outdoor activities',
          'descripcion':
              'Air quality is acceptable; safe to go outside for sports.',
        };
      case 3:
        return {
          'subtitulo': 'Moderate caution',
          'descripcion':
              'Air quality is moderate; sensitive people should limit prolonged outdoor activity.',
        };
      case 4:
        return {
          'subtitulo': 'Poor air quality',
          'descripcion': 'Air quality is bad; avoid long outdoor activities.',
        };
      case 5:
        return {
          'subtitulo': 'Very poor air quality',
          'descripcion': 'Air quality is unhealthy; stay indoors if possible.',
        };
      default:
        return {
          'subtitulo': 'Loading...',
          'descripcion': 'Air quality data is being retrieved.',
        };
    }
  }

  Map<String, dynamic> getIndiceInfo(int indice) {
    switch (indice) {
      case 1:
        return {'texto': 'Excellent', 'color': Color(0xFF27AE60)};
      case 2:
        return {'texto': 'Good', 'color': Color(0xFFFFD700)};
      case 3:
        return {'texto': 'Moderate', 'color': Color(0xFFFFA500)};
      case 4:
        return {'texto': 'Bad', 'color': Color(0xFFFF6B6B)};
      case 5:
        return {'texto': 'Caution', 'color': Color(0xFFC44569)};
      default:
        return {'texto': 'Cargando...', 'color': Colors.grey};
    }
  }

  Future<void> cargarContaminacion(double lat, double lon) async {
    final data = await clima.obtenerContaminacion(lat, lon);

    if (data != null) {
      setState(() {
        // Partículas
        co = (data['components']['co'] as num).toDouble();
        no = (data['components']['no'] as num).toDouble();
        no2 = (data['components']['no2'] as num).toDouble();
        o3 = (data['components']['o3'] as num).toDouble();
        so2 = (data['components']['so2'] as num).toDouble();
        pm2_5 = (data['components']['pm2_5'] as num).toDouble();
        pm10 = (data['components']['pm10'] as num).toDouble();
        nh3 = (data['components']['nh3'] as num).toDouble();

        // AQI
        indice = data['main']['aqi'] as int;
      });

      // Debug
      debugPrint('AQI: $indice');
      debugPrint(
        'CO: $co, NO: $no, NO2: $no2, O3: $o3, SO2: $so2, PM2.5: $pm2_5, PM10: $pm10, NH3: $nh3',
      );
    } else {
      debugPrint('No se pudieron obtener datos de contaminación.');
    }
  }

  Color getRecomendacionColor(int indice) {
    switch (indice) {
      case 1:
        return Color(0xFF27AE60); // Excellent - verde
      case 2:
        return Color(0xFFFFD700); // Good - amarillo
      case 3:
        return Color(0xFFFFA500); // Moderate - naranja
      case 4:
        return Color(0xFFFF6B6B); // Bad - rojo claro
      case 5:
        return Color(0xFFC44569); // Caution - rojo oscuro
      default:
        return Colors.grey.shade300; // Cargando o sin datos
    }
  }

  Future<void> obtenerClima() async {
    final ubicacion = await LocationData.getUserUbication();

    if (ubicacion != null) {
      final pais = ubicacion.pais;
      final estado = ubicacion.estado;
      final municipio = ubicacion.ciudad;

      if (pais != null && estado != null && municipio != null) {
        setState(() {
          ciudad = municipio;
        });
        final coordenadas = await clima.obtenerCoordenadas(
          pais,
          municipio,
          estado,
        );

        if (coordenadas != null) {
          final lat = coordenadas['lat'];
          final lon = coordenadas['lon'];

          debugPrint(lat.toString());
          debugPrint(lon.toString());

          if (lat != null && lon != null) {
            cargarContaminacion(lat, lon);
            final condiciones = await clima.obtenerCondicionesActuales(
              lat,
              lon,
            );
            setState(() {
              temperatura = "${condiciones['temperatura']}°C";
              humedad = "${condiciones['humedad']}%";
              velocidad = "${condiciones['velocidad']}km";
              presion = "${condiciones['presion']}";
            });
            debugPrint(temperatura);
            debugPrint(humedad);
            debugPrint(velocidad);
            debugPrint(presion);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> cardsData = [
      {
        "icon": Icons.thermostat,
        "iconColor": Colors.red,
        "circleColor": Colors.red,
        "value": temperatura,
        "label": "Temperature",
      },
      {
        "icon": Icons.water_drop,
        "iconColor": Colors.blue,
        "circleColor": Colors.blue,
        "value": humedad,
        "label": "Humidity",
      },
      {
        "icon": Icons.speed,
        "iconColor": Colors.purple,
        "circleColor": Colors.purple,
        "value": presion,
        "label": "Pressure (hPa)",
      },
      {
        "icon": Icons.air,
        "iconColor": Color(0xFF06B6D4),
        "circleColor": Color(0xFF06B6D4),
        "value": velocidad,
        "label": "Wind",
      },
    ];

    final info = getIndiceInfo(indice);

    final recomendacion = getRecomendacion(indice);
    final colorContenedor = getRecomendacionColor(indice);

    return Scaffold(
      backgroundColor: Color(0xFFEFF8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Padding(
              padding: EdgeInsetsGeometry.all(12),
              child: Column(
                children: [
                  // Barra de airshield
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: [
                                  Color.fromARGB(255, 65, 166, 249),
                                  Color.fromARGB(255, 3, 50, 120),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.shield,
                              size: 26,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "AirShield",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 21,
                                  color: colorFuerte,
                                ),
                              ),
                              Text(
                                "Dashboard",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              setState(() {
                                co = 0;
                                no = 0;
                                no2 = 0;
                                o3 = 0;
                                so2 = 0;
                                pm2_5 = 0;
                                pm10 = 0;
                                nh3 = 0;
                                indice = 0;

                                temperatura = '...';
                                humedad = '...';
                                velocidad = '...';
                                presion = '...';
                              });
                              await Future.delayed(
                                const Duration(milliseconds: 500),
                              );
                              obtenerClima();
                            },
                            style: ButtonStyle(
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11),
                                ),
                              ),
                              backgroundColor: WidgetStatePropertyAll(
                                Colors.white,
                              ),
                            ),
                            icon: Icon(Icons.refresh),
                          ),
                          IconButton(
                            style: ButtonStyle(
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11),
                                ),
                              ),
                              backgroundColor: WidgetStatePropertyAll(
                                Colors.white,
                              ),
                            ),
                            onPressed: () async {
                              // Limpiar datos locales de ubicación
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.remove('pais');
                              await prefs.remove('estado');
                              await prefs.remove('ciudad');
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const Location(),
                                ),
                                (Route<dynamic> route) => false,
                              );
                            },
                            icon: Icon(Icons.location_on),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Card azul
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Air Quality Index",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 29,
                                  ),
                                ),
                                Text(
                                  "Real-time monitoring",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                color: Color(0x33ffffff),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.air,
                                size: 35,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  indice.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 45,
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  info['texto'],
                                  style: TextStyle(
                                    color: info['color'],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                TextButton.icon(
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E88E5),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    shadowColor: Colors.blueAccent.withValues(
                                      alpha: 0.4,
                                    ),
                                    elevation: 4,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Satellite(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.satellite_alt,
                                    size: 22,
                                  ),
                                  label: const Text(
                                    "Satellite view",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF27AE60),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Center(
                              child: Text(
                                "Excellent",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(color: Color(0xFFFFD700)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Center(
                              child: Text(
                                "Good",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(color: Color(0xFFFFA500)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Center(
                              child: Text(
                                "Moderate",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(color: Color(0xFFFF6B6B)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Center(
                              child: Text(
                                "Bad",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFC44569),
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Center(
                              child: Text(
                                "Caution",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Grid de temperatura, humedad, presion, viento
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(10),
                    itemCount: cardsData.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600
                          ? 4
                          : 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: MediaQuery.of(context).size.width > 900
                          ? 1
                          : MediaQuery.of(context).size.width > 600
                          ? 0.65
                          : 0.7,
                    ),
                    itemBuilder: (context, index) {
                      final card = cardsData[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    card["icon"],
                                    color: card["iconColor"],
                                    size: 28,
                                  ),
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: card["circleColor"],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 100),
                              Column(
                                children: [
                                  Text(
                                    card["value"],
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    card["label"],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12),

                  // Calidad del aire a detalle
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Air Quality Details",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              Icon(Icons.info_outline),
                            ],
                          ),
                          SizedBox(height: 16),
                          _buildParticleRow("CO", co, "ppm", Colors.teal),
                          SizedBox(height: 16),
                          _buildParticleRow("NO", no, "ppb", Colors.purple),
                          SizedBox(height: 16),
                          _buildParticleRow("NO2", no2, "ppb", Colors.blue),
                          SizedBox(height: 16),
                          _buildParticleRow("O3", o3, "ppb", Colors.orange),
                          SizedBox(height: 16),
                          _buildParticleRow(
                            "SO2",
                            so2,
                            "ppb",
                            Colors.yellow.shade700,
                          ),
                          SizedBox(height: 16),
                          _buildParticleRow(
                            "PM2.5",
                            pm2_5,
                            "µg/m³",
                            Colors.green,
                          ),
                          SizedBox(height: 16),
                          _buildParticleRow(
                            "PM10",
                            pm10,
                            "µg/m³",
                            Colors.brown,
                          ),
                          SizedBox(height: 16),
                          _buildParticleRow(
                            "NH3",
                            nh3,
                            "ppb",
                            Colors.redAccent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Temperature prediction",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 12),
                          Image.asset("assets/temperatureprediction.jpg"),
                          SizedBox(height: 8),
                          Text(
                            "Prediction of the temperature to the next days",
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Air quality",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 12),
                          Image.asset("assets/airquality.png"),
                          SizedBox(height: 8),
                          Text(
                            "Quality of the next days ",
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Recomendaciones de la salud
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Health Recommendations",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              Icon(Icons.shield_rounded, color: Colors.green),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorContenedor.withValues(
                                alpha: .2,
                              ), // versión suave para el fondo
                              border: Border.all(
                                color: colorContenedor,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: colorContenedor,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        recomendacion['subtitulo']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(recomendacion['descripcion']!),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Report(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.insert_drive_file, // Icono de reporte
                        size: 20,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Generate Report",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: Colors.blueAccent.withAlpha(100),
                        elevation: 4,
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  // Localización y siguiente update
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Card 1 - Location
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.blueAccent,
                                  size: 28,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Location",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    height: 0.9,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(ciudad, style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),

                      // Card 2 - Next Update
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: Colors.blueAccent,
                                  size: 28,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Next update",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    height: 0.9,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "In $_minutesRemaining minutes",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParticleRow(
    String name,
    double value,
    String unit,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: 10),
            Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Row(
          children: [
            Text(value.toStringAsFixed(2)), // muestra dos decimales
            SizedBox(width: 4),
            Text(unit),
          ],
        ),
      ],
    );
  }
}
