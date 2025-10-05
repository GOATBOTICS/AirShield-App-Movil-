import 'package:airshield/constants.dart';
import 'package:airshield/pages/dashboard.dart';
import 'package:airshield/pages/location.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // icono
                  Container(
                    width: 130,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(120),
                    ),
                    child: Image.asset("assets/logo.png", fit: BoxFit.cover),
                  ),

                  SizedBox(height: 20),

                  // welcome
                  Text(
                    "Welcome to",
                    style: TextStyle(color: colorFuerte, fontSize: 25),
                  ),
                  Text(
                    "AirShield",
                    style: TextStyle(
                      color: colorFuerte,
                      fontWeight: FontWeight.bold,
                      fontSize: 45,
                    ),
                  ),
                  SizedBox(height: 40),

                  // descripcion
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorFuerte,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: colorFondo,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Center(
                            child: Image.asset(
                              "assets/graficabarras.png",
                              width: 30,
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        Text(
                          "Professional Air Quality \nMonitoring",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colorFondo,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 16),

                        Text(
                          "Get real-time air quality data and insights to protect your health and environment",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorTexto, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),

                  // boton
                  TextButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final pais = prefs.getString('estado');

                      if (!context.mounted) {
                        return; // <-- Evita usar context si el widget se desmontó
                      }

                      if (pais != null && pais.isNotEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const Dashboard(),
                          ),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const Location(),
                          ),
                        );
                      }
                    },
                    style: ButtonStyle(
                      padding: WidgetStatePropertyAll(
                        EdgeInsetsGeometry.symmetric(
                          horizontal: 80,
                          vertical: 10,
                        ),
                      ),
                      backgroundColor: WidgetStatePropertyAll(colorFuerte),
                    ),
                    child: Text(
                      "START",
                      style: TextStyle(
                        color: colorFondo,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  Text("by Goatbotics", style: TextStyle(color: colorFuerte)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
