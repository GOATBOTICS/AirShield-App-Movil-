import 'package:airshield/pages/reg_ini.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void logout(BuildContext context) async {
  // Cerrar sesión en Firebase
  await FirebaseAuth.instance.signOut();

  if (!context.mounted) return;

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) => const RegIni(),
    ),
    (Route<dynamic> route) => false,
  );
}
