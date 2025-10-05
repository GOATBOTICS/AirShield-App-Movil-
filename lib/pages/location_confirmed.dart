import 'package:airshield/constants.dart';
import 'package:airshield/data/location_data.dart';
import 'package:airshield/pages/dashboard.dart';
import 'package:airshield/util/responsive.dart';
import 'package:airshield/widgets/card_white.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationConfirmed extends StatefulWidget {
  const LocationConfirmed({super.key});

  @override
  State<LocationConfirmed> createState() => _LocationConfirmedState();
}

class _LocationConfirmedState extends State<LocationConfirmed> {
  String pais = "Searching...";
  String estado = "Searching...";
  String municipio = "Searching...";

  void _datosUbicacion() async {
    final ubicacion = await LocationData.getUserUbication();

    if (ubicacion != null) {
      setState(() {
        pais = ubicacion.pais ?? "";
        estado = ubicacion.estado ?? "";
        municipio = ubicacion.ciudad ?? "";
      });
    } else {
      debugPrint('No se encontraron datos en el singleton.');
    }
  }

  void _irAlDashboard() {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _datosUbicacion();
    _datosUbicacionm();
  }

  void _datosUbicacionm() async {
    final prefs = await SharedPreferences.getInstance();

    // Leer datos almacenados
    final pais = prefs.getString('pais') ?? 'Desconocido';
    final estado = prefs.getString('estado') ?? 'Desconocido';
    final ciudad = prefs.getString('ciudad') ?? 'Desconocido';

    // Mostrar en consola para debug
    debugPrint('Pais: $pais');
    debugPrint('Estado: $estado');
    debugPrint('Ciudad: $ciudad');

    // Si quieres, actualizar estado del widget
    setState(() {
      // opcional: guardarlos en variables locales del widget si las tienes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFuerte,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Center(
              child: Column(
                children: [
                  // Ubicacion guardada
                  SizedBox(
                    width: 600,
                    child: CardWhite(
                      borroso: 6,
                      child: Column(
                        children: [
                          // Gif
                          Image.asset(
                            "assets/verificado.gif",
                            width: 75,
                            height: 75,
                          ),
                          SizedBox(height: 15),
                          // Texto
                          Text(
                            "Location Successfully Selected",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            "Your location has been successfully registered in our system.",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  // Detalles de la ubicacion
                  SizedBox(
                    width:
                        (Responsive.isDesktop(context) ||
                            Responsive.isTablet(context))
                        ? 600
                        : null,
                    child: CardWhite(
                      borroso: 6,
                      child: Column(
                        children: [
                          Text(
                            "Location details",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Divider(color: Colors.grey, height: 2),
                          SizedBox(height: 15),
                          // Pais
                          RowData(descripcion: "Country:", variable: pais),
                          SizedBox(height: 15),

                          // Estado
                          RowData(descripcion: "State:", variable: estado),
                          SizedBox(height: 15),

                          // Municipio
                          RowData(descripcion: "City:", variable: municipio),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  // ¿Qué sigue?
                  SizedBox(
                    width:
                        (Responsive.isDesktop(context) ||
                            Responsive.isTablet(context))
                        ? 600
                        : null,
                    child: CardWhite(
                      borroso: 6,
                      child: Column(
                        children: [
                          // Titulo
                          Text(
                            "What's next?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Divider(color: Colors.grey, height: 2),
                          SizedBox(height: 15),
                          Text(
                            "You can now access information and services specific to your region. Explore the following options:",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 16),
                          // Gifs
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Gif de hoja
                              GifsIconos(
                                ruta: "assets/viento.gif",
                                texto: "Air quality",
                              ),

                              // Gif de gota
                              GifsIconos(
                                ruta: "assets/eye.gif",
                                texto: "Monitoring",
                              ),

                              // Gif de estadisticas
                              GifsIconos(
                                ruta: "assets/estadisticas.gif",
                                texto: "Analysis",
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  colorFuerte,
                                ),
                              ),
                              onPressed:
                                  _irAlDashboard, // Llama al método de logout al presionar
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 1,
                                ),
                                child: const Text(
                                  "Confirm",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        // Boton de avanzar
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

class GifsIconos extends StatelessWidget {
  const GifsIconos({required this.ruta, required this.texto, super.key});

  final String ruta;
  final double dimensiones = 50;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Image.asset(ruta, width: dimensiones, height: dimensiones),
        ),
        SizedBox(height: 7),
        Text(
          texto,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.normal,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class RowData extends StatelessWidget {
  const RowData({super.key, required this.descripcion, required this.variable});

  final String descripcion;
  final String variable;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          descripcion,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          variable,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
