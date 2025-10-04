import 'package:airshield/constants.dart';
import 'package:airshield/data/location_data.dart';
import 'package:airshield/pages/dashboard.dart';
import 'package:airshield/util/responsive.dart';
import 'package:airshield/widgets/card_white.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LocationConfirmed extends StatefulWidget {
  const LocationConfirmed({super.key});

  @override
  State<LocationConfirmed> createState() => _LocationConfirmedState();
}

class _LocationConfirmedState extends State<LocationConfirmed> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String pais = "Buscando...";
  String estado = "Buscando...";
  String municipio = "Buscando...";

  void _datosUbicacion() async {
    final user = _auth.currentUser;
    
      final uid = user?.uid;
      final ubicacion = await LocationData.getUserUbication(uid!);

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
                            "Ubicación Seleccionada Exitosamente",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            "Tu ubicación ha sido registrada correctamente en nuestro sistema",
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
                            "Detalles de la ubicación",
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
                          RowData(descripcion: "Pais:", variable: pais),
                          SizedBox(height: 15),

                          // Estado
                          RowData(descripcion: "Estado:", variable: estado),
                          SizedBox(height: 15),

                          // Municipio
                          RowData(
                            descripcion: "Municipio:",
                            variable: municipio,
                          ),
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
                            "¿Qué sigue?",
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
                            "Ahora puedes acceder a información y servicios especificos para tu región. Explora las siguientes opciones:",
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
                                texto: "Calidad del aire",
                              ),

                              // Gif de gota
                              GifsIconos(
                                ruta: "assets/eye.gif",
                                texto: "Monitoreo",
                              ),

                              // Gif de estadisticas
                              GifsIconos(
                                ruta: "assets/estadisticas.gif",
                                texto: "Analisis Regional",
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
                                  "Confirmar",
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
