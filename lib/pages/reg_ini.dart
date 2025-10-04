import 'package:airshield/pages/sign_in_screen.dart';
import 'package:airshield/pages/sign_up_screen.dart';
import 'package:airshield/util/responsive.dart';
import 'package:flutter/material.dart';

class RegIni extends StatefulWidget {
  const RegIni({super.key});

  @override
  State<RegIni> createState() => _RegIniState();
}

class _RegIniState extends State<RegIni> {
  bool showSignIn = true;

  void handleChangeToRegistro() {
    setState(() {
      showSignIn = true;
    });
  }

  void handleChangeToInicio() {
    setState(() {
      showSignIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Imagen de fondo
          SizedBox(
            width: double.infinity,
            height: double
                .infinity, // Esto asegura que la imagen ocupe todo el fondo
            child: Image.asset(
              'assets/fondo.jpg', // Ruta de tu imagen
              fit: BoxFit.cover,
            ),
          ),
          // Filtro oscuro
          Positioned.fill(
            child: Container(
              color: Colors.black
                  .withValues(alpha: 0.2), // Filtro negro semi-transparente
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          // Titulo
                          children: [
                            // Botones
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(20)),
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                              width: (Responsive.isTablet(context) ||
                                      Responsive.isDesktop(context))
                                  ? 400
                                  : null,
                              child: Column(
                                children: [
                                  Text(
                                    "AirShield",
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                  Divider(
                                    thickness: 5,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      // Botón "Iniciar sesión"
                                      GestureDetector(
                                        onTap: handleChangeToRegistro,
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              bottom: 6, left: 15, right: 15),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: showSignIn
                                                    ? Colors.blue
                                                    : Colors.white,
                                                width: 3.0,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            "Sign In",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: showSignIn
                                                  ? Colors.black
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      
                                      // Botón "Registrarse"
                                      GestureDetector(
                                        onTap: handleChangeToInicio,
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              bottom: 6, left: 15, right: 15),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: showSignIn
                                                    ? Colors.white
                                                    : Colors.blue,
                                                width: 3.0,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            "Sign Up",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: showSignIn
                                                  ? Colors.grey
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                
                                  // Formularios
                                  AnimatedSwitcher(
                                    duration: Duration(milliseconds: 400),
                                    child: showSignIn
                                        ? SignInScreen()
                                        : SignUpScreen(
                                            changeToSignIn:
                                                handleChangeToRegistro,
                                          ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
