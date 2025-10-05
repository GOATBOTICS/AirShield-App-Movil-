import 'package:airshield/apis/mexico_info.dart';
import 'package:airshield/apis/openweather_api.dart';
import 'package:airshield/constants.dart';
import 'package:airshield/data/user_data.dart';
import 'package:airshield/models/location_model.dart';
import 'package:airshield/models/user_model.dart';
import 'package:airshield/pages/location_confirmed.dart';
import 'package:airshield/util/responsive.dart';
import 'package:airshield/widgets/buscar_input.dart';
import 'package:airshield/widgets/card_white.dart';
import 'package:airshield/widgets/input_field.dart';
import 'package:airshield/widgets/mostrar_mensaje.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  UbicacionApi clima = UbicacionApi();
  // Errores de los estados y ciudades
  bool errorEstadoState = false;
  bool errorCiudadState = false;

  // Procesando
  bool procesandoConfirmar = false;
  bool procesandoCerrarSesion = false;

  // paises
  List<String> suggestions = [];
  List<String> allCountries = [];

  // Estados
  List<String> suggestionsEstados = [];
  List<String> allEstados = [];

  // Ciudades
  List<String> suggestionsCiudades = [];
  List<String> allCiudades = [];

  final UserData userData = UserData(); // Usuario

  TextEditingController pais = TextEditingController();
  TextEditingController estados = TextEditingController();
  TextEditingController ciudades = TextEditingController();

  // Obtenemos el usuario actual (si está autenticado)
  User? currentUser = FirebaseAuth.instance.currentUser;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEstados();
    });
  }

  // Cargar la lista de países
  Future<void> _loadEstados() async {
    List<String> aux = [];

    try {
      final result = await MexicoInfo.estados("Mexico");

      // Recorre el resultado y agrega solo los nombres de los estados a aux
      aux = result.map((estado) => estado['nombre'] as String).toList();

      setState(() {
        allEstados = aux;
        suggestionsEstados = allEstados; // Inicializar con todos los estados
      });
    } catch (e) {
      debugPrint("Error loading countries: $e");
    }
  }

  Future<List<String>> buscarEstados() async {
    ciudades.clear();
    final mapCiudades = await MexicoInfo.estados(pais.text);

    // Verifica si el mapa no está vacío
    if (mapCiudades.isNotEmpty) {
      // Devuelve la lista de nombres de los estados
      return mapCiudades.map((estado) => estado['nombre'] ?? '').toList();
    } else {
      // Si no hay estados, devuelve una lista vacía
      return [];
    }
  }

  Future<List<String>> buscarCiudades() async {
    final mapCiudades = await MexicoInfo.ciudades();

    // Convierte estados.text y las claves del mapa a minúsculas para hacer la comparación
    final estadoBuscado = estados.text.trim().toLowerCase();

    // Busca la clave en minúsculas
    final ciudades = mapCiudades.entries
        .firstWhere(
          (entry) => entry.key.toLowerCase() == estadoBuscado,
          orElse: () => MapEntry('', []),
        )
        .value;

    return ciudades.map((ciudad) => ciudad.toUpperCase()).toList();
  }

  String? _handleEstado(String value) {
    if (value.isEmpty) {
      return "Select your location";
    }

    return null;
  }

  String? _handleCiudad(String value) {
    if (value.isEmpty) {
      return "Select your location";
    }

    return null;
  }

  void _confirmar() async {
    setState(() {
      procesandoConfirmar = true;
    });
    if (_formKey.currentState!.validate()) {
      bool errorEstado = false;
      bool errorCiudad = false;

      // Verificamos que exista el estado
      final mapEstados = await MexicoInfo.estados(pais.text);
      final mapCiudades = await MexicoInfo.ciudades();

      // Verifica si el mapa no está vacío y busca el estado en la lista
      if (mapEstados.isNotEmpty) {
        final estadosList = mapEstados
            .map((estado) => estado['nombre'] ?? '')
            .toList();

        // Si el valor ingresado está en la lista de estados, retorna true
        if (!estadosList.contains(estados.text)) {
          setState(() {
            errorEstadoState = true;
          });
          errorEstado = true;
        }
      }

      if (mapCiudades.isNotEmpty) {
        // Convertir el estado ingresado a minúsculas para comparación
        String estadoIngresado = estados.text.toLowerCase();
        estadoIngresado = estadoIngresado
            .split(' ') // Separa la cadena en palabras por espacio
            .map((palabra) {
              // Si la palabra es "de", la dejamos en minúsculas
              if (palabra.toLowerCase() == 'de') {
                return palabra.toLowerCase();
              }
              // Si no es "de", ponemos la primera letra en mayúscula y el resto en minúscula
              return palabra.isNotEmpty
                  ? palabra[0].toUpperCase() +
                        palabra.substring(1).toLowerCase()
                  : palabra;
            })
            .join(' '); // Une las palabras de nuevo con un espacio

        // Buscar la lista de ciudades correspondientes al estado seleccionado (en minúsculas)
        List<String> ciudadesDelEstado =
            mapCiudades[estadoIngresado]
                ?.map((ciudad) => ciudad.toLowerCase())
                .toList() ??
            [];

        // Convertir la ciudad ingresada a minúsculas para comparación
        String ciudadIngresada = ciudades.text.toLowerCase();

        // Si la ciudad no está en la lista de ciudades, marca el error
        if (!ciudadesDelEstado.contains(ciudadIngresada)) {
          setState(() {
            errorCiudadState = true;
          });
          errorCiudad = true;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pais', pais.text);
        await prefs.setString('estado', estados.text);
        await prefs.setString('ciudad', ciudades.text);
      }

      if (errorCiudad && errorEstado) {
        if (mounted) {
          mostrarMensajeError(
            context,
            "Error",
            "El estado y la ciudad no son validos",
          );
          setState(() {
            procesandoConfirmar = false;
          });
        }
      } else if (errorEstado) {
        if (mounted) {
          mostrarMensajeError(context, "Error", "El estado no es valido");

          setState(() {
            procesandoConfirmar = false;
          });
        }
      } else if (errorCiudad) {
        if (mounted) {
          mostrarMensajeError(
            context,
            "Error",
            "La ciudad no es valida $errorCiudad",
          );

          setState(() {
            procesandoConfirmar = false;
          });
        }
      } else {
        _guardar();
      }
    } else {
      setState(() {
        procesandoConfirmar = false;
      });
    }
  }

  void _guardar() async {
    setState(() {
      procesandoConfirmar = true;
    });

    final locationModel = LocationModel(
      pais: pais.text,
      estado: estados.text,
      ciudad: ciudades.text,
    );

    UserModel userModel = UserModel(uid: currentUser?.uid.toString());

    try {
      debugPrint(locationModel.ciudad);
      debugPrint(locationModel.estado);
      debugPrint(locationModel.pais);
      debugPrint(userModel.uid);

      final prefs = await SharedPreferences.getInstance();
      // Obtener los datos locales o valores por defecto
      String paisn = prefs.getString('pais') ?? 'MEXICO';
      String estadon = prefs.getString('estado') ?? 'COAHUILA';
      String ciudadn = prefs.getString('ciudad') ?? 'SALTILLO';

      debugPrint("datos localesssss");
      debugPrint(paisn);
      debugPrint(estadon);
      debugPrint(ciudadn);

      // Limpia campos
      vaciar();

      setState(() {
        procesandoConfirmar = false;
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LocationConfirmed()),
        );
      }
    } catch (e) {
      setState(() {
        procesandoConfirmar = false;
      });
      if (mounted) {
        mostrarMensajeError(
          context,
          "Error",
          "Ocurrió un error al guardar los datos, reinténtalo ${e.toString()}",
        );
      }
    }
  }

  void vaciar() {
    estados.clear();
    ciudades.clear();
  }

  Widget espaciado() {
    return Column(
      children: [
        SizedBox(height: 30),
        Divider(color: Colors.grey, height: 3),
        SizedBox(height: 30),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Appbar
              Container(
                padding:
                    !(Responsive.isDesktop(context) ||
                        Responsive.isTablet(context))
                    ? EdgeInsets.symmetric(horizontal: 10, vertical: 11)
                    : EdgeInsets.only(left: 10, right: 10, bottom: 15, top: 15),
                decoration: BoxDecoration(color: colorFuerte),
                child: Center(
                  child: Text(
                    "AIRSHIELD",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFEFF8FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                width:
                    (Responsive.isTablet(context) ||
                        Responsive.isDesktop(context))
                    ? 600
                    : null,
                child: Column(
                  children: [
                    SizedBox(height: 20),

                    // Formulario
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      child: CardWhite(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Titulo
                            Text(
                              'Select your location', // Mostrar el correo del usuario
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            espaciado(),

                            // Primer input para escoger el pais
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  InputField(
                                    controller: pais,
                                    label: "Select a country",
                                    disabled: true,
                                    defaultText: "MEXICO",
                                  ),
                                  espaciado(),

                                  // Segundo input para escoger el estado
                                  BuscarInput(
                                    icon: Icons.apartment,
                                    validator: (value) => _handleEstado(value!),
                                    suggestions: suggestionsEstados,
                                    toSearch: allEstados,
                                    controller: estados,
                                    hint: "Select a state",
                                    peticion: buscarEstados,
                                  ),
                                  espaciado(),

                                  // Tercer input para la ciudad
                                  BuscarInput(
                                    icon: Icons.location_on,
                                    validator: (value) => _handleCiudad(value!),
                                    suggestions: suggestionsCiudades,
                                    toSearch: allCiudades,
                                    controller: ciudades,
                                    hint: "Select a city",
                                    peticion: buscarCiudades,
                                  ),
                                  espaciado(),
                                ],
                              ),
                            ),

                            // Confirmar
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    colorFuerte,
                                  ),
                                ),
                                onPressed: !procesandoConfirmar
                                    ? _confirmar
                                    : null, // Llama al método de logout al presionar
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  child: procesandoConfirmar
                                      ? SizedBox(
                                          width: 60,
                                          child: Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                        )
                                      : const Text(
                                          "Confirm",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
