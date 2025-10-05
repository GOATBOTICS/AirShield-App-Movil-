import 'package:airshield/apis/openweather_api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  UbicacionApi clima = UbicacionApi();

  String date = "...";
  String pais = "...";
  String estado = "...";
  String ciudad = "...";

  double co = 0;
  double no = 0;
  double no2 = 0;
  double o3 = 0;
  double so2 = 0;
  double pm2_5 = 0;
  double pm10 = 0;
  double nh3 = 0;
  int indice = 0; // AQI

  String clasificacion = "...";
  String humedad = "...";
  String temperatura = "...";
  String presion = "...";
  String viento = "...";
  String sugerencia =
      "Air quality and atmospheric conditions report for the selected location. Includes levels of key pollutants and the Air Quality Index (AQI). Provides reliable information for environmental monitoring, risk assessment, and decision-making.";

  @override
  void initState() {
    super.initState();

    cargarDatos();
  }

  void cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    final fecha =
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

    // Leer datos almacenados localmente, con valores por defecto
    String paism = prefs.getString('pais') ?? 'Desconocido';
    String estadom = prefs.getString('estado') ?? 'Desconocido';
    String ciudadm = prefs.getString('ciudad') ?? 'Desconocido';
    setState(() {
      pais = paism;
      estado = estadom;
      ciudad = ciudadm;
      date = fecha;
    });

    final coordenadas = await clima.obtenerCoordenadas(pais, ciudad, estado);

    if (coordenadas != null) {
      final lat = coordenadas['lat'];
      final lon = coordenadas['lon'];
      cargarContaminacion(lat!, lon!);
      final condiciones = await clima.obtenerCondicionesActuales(lat, lon);
      setState(() {
        temperatura = "${condiciones['temperatura']}°C";
        humedad = "${condiciones['humedad']}%";
        viento = "${condiciones['velocidad']}km";
        presion = "${condiciones['presion']}";
      });
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
      debugPrint("Indicess");
      debugPrint(indice.toString());
      String clasificacionm;
      if (indice == 1) {
        clasificacionm = "Excellent";
      } else if (indice == 2) {
        clasificacionm = "Good";
      } else if (indice == 3) {
        clasificacionm = "Moderate";
      } else if (indice == 4) {
        clasificacionm = "Bad";
      } else if (indice == 5) {
        clasificacionm = "Caution";
      } else {
        clasificacionm = "...";
      }

      setState(() {
        clasificacion = clasificacionm;
      });
    } else {
      debugPrint('No se pudieron obtener datos de contaminación.');
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
                          "AirShield Report",
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
                  SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/logoReporte.jpg',
                            width: 175,
                            height: 140,
                            fit: BoxFit.contain,
                          ),
                          Text(
                            "Recognized data",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Generation date: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(date),
                            ],
                          ),
                          SizedBox(height: 4),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Country: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(pais),
                            ],
                          ),
                          SizedBox(height: 4),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "State: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(estado),
                            ],
                          ),
                          SizedBox(height: 4),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "City: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(ciudad),
                            ],
                          ),
                          SizedBox(height: 4),

                          Text(
                            "Report description",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),

                          Text(
                            "Air quality and atmospheric conditions report for the selected location. Includes levels of key pollutants and the Air Quality Index (AQI). Provides reliable information for environmental monitoring, risk assessment, and decision-making.",
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Monitored particles",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
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
                          Text(
                            "important factors",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "AQI:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(indice.toString()),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Clasification AQI",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(clasificacion),
                            ],
                          ),
                          SizedBox(height: 4),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Temperature",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(temperatura),
                            ],
                          ),
                          SizedBox(height: 4),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Humidity",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(humedad),
                            ],
                          ),
                          SizedBox(height: 4),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Pressure",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(presion),
                            ],
                          ),
                          SizedBox(height: 4),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Wind",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(viento),
                            ],
                          ),
                          SizedBox(height: 4),

                          Text(
                            "Suggestion based on the AQI",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),

                          Text(sugerencia),
                          Text(
                            "References",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "1. ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: Text(
                                  "Api Airpollution: https://openweathermap.org/api/air-pollution",
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "2. ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: Text(
                                  "EarthData: https://www.earthdata.nasa.gov/data/tools",
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "3. ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: Text(
                                  "PDF TEMPO: https://asdc.larc.nasa.gov/documents/tempo/guide/TEMPO_Level-2-3_trace_gas_clouds_user_guide_V2.0.pdf",
                                ),
                              ),
                            ],
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
