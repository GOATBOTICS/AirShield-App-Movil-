import 'package:airshield/constants.dart';
import 'package:airshield/data/user_data.dart';
import 'package:airshield/models/user_model.dart';
import 'package:airshield/widgets/input_field.dart';
import 'package:airshield/widgets/mostrar_mensaje.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  final Function changeToSignIn;

  const SignUpScreen({super.key, required this.changeToSignIn});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController correo = TextEditingController();
  final TextEditingController contrasena = TextEditingController();
  final TextEditingController confirmarContrasena = TextEditingController();
  final UserData userData = UserData(); // Usuario
  bool procesando = false;

  // Metodo para registrar a un usuario
  void _signUp() async {
    setState(() {
      procesando = true;
    });
    if (formKey.currentState!.validate()) {
      final userModel = UserModel(
        email: correo.text.trim(),
        password: contrasena.text.trim(),
      );

      try {
        await userData.registerUser(userModel);

        // Vaciar los inputs
        _vaciarInputs();
        setState(() {
          procesando = false;
        });
        if (mounted) {
          mostrarMensajeCorrecto(
            context,
            "¡Registrado!",
            "Cuenta registrada con exito",
            widget.changeToSignIn,
            widget.changeToSignIn,
          );
        }
      } catch (e) {
        setState(() {
          procesando = false;
        });
        if (e is FirebaseAuthException) {
          // Detectamos tipos de errores específicos de Firebase Authentication
          if (e.code == 'email-already-in-use') {
            if (mounted) {
              mostrarMensajeError(context, "Error", "El correo ya está en uso");
            }
          } else if (e.code == 'invalid-email') {
            if (mounted) {
              mostrarMensajeError(
                context,
                "Error",
                "El formato del correo no es válido",
              );
            }
          } else if (e.code == 'weak-password') {
            if (mounted) {
              mostrarMensajeError(
                context,
                "Error",
                "La contraseña es demasiado débil",
              );
            }
          } else {
            // Otros códigos de error de FirebaseAuth
            if (mounted) {
              mostrarMensajeError(
                context,
                "Error",
                "Error al registrarse: ${e.message ?? e.code}",
              );
            }
          }
        } else {
          // Si el error no proviene de FirebaseAuth, mostramos el motivo
          if (mounted) {
            mostrarMensajeError(
              context,
              "Error inesperado",
              "Ocurrió un error desconocido: ${e.toString()}",
            );
          }
        }
      } finally {
        setState(() {
          procesando = false;
        });
      }
    } else {
      setState(() {
        procesando = false;
      });
    }
  }

  void _vaciarInputs() {
    correo.clear();
    contrasena.clear();
    confirmarContrasena.clear();
  }

  // Metodo para verificar el correo
  String? _handleCorreo(String value) {
    // El correo esta vacio
    if (value.isEmpty) {
      return "Ingrese el correo electrónico";
    }

    // Expresión regular para validar el formato de un correo electrónico
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    if (!emailRegex.hasMatch(value)) {
      return "Ingrese un correo electrónico válido";
    }

    return null; // El correo es válido
  }

  // Metodo para verificar la primer contraseña
  String? _handlePassword(String value) {
    // La contraseña esta vacio
    if (value.isEmpty) {
      return "Ingrese una contraseña valida";
    }

    return null; // La contraseña es válido
  }

  // Metodo para verificar la confirmacion de la contraseña
  String? _handleConfirmPassword(String value) {
    // La segunda contraseña no coinciden
    if (value != contrasena.text.trim()) {
      return "Las contraseñas no coinciden";
    }

    // La segunda contraseña esta vacia
    if (value.isEmpty) {
      return "Ingrese una contraseña valida";
    }

    return null; // La contraseña es válido
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Correo electronico
          InputField(
            controller: correo,
            validator: (value) => _handleCorreo(value!),
            label: "Email",
            keyboardType: TextInputType.emailAddress,
            obscureText: false,
          ),
          SizedBox(height: 20),

          // Contraseña
          InputField(
            controller: contrasena,
            label: "Password",
            obscureText: true,
            validator: (value) => _handlePassword(value!),
          ),
          SizedBox(height: 20),

          // Confirmar contraseña
          InputField(
            controller: confirmarContrasena,
            label: "Confirm password",
            obscureText: true,
            validator: (value) => _handleConfirmPassword(value!),
          ),
          SizedBox(height: 20),

          // Boton
          ElevatedButton(
            onPressed: _signUp,
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.blue[100]),
            ),
            child: procesando
                ? SizedBox(
                    width: 70,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: colorFuerte,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  )
                : Text(
                    "Create account",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorFuerte,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
