import 'package:airshield/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserData {
  // Instancia de firebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Instancia de Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registrar un usuario
  Future<void> registerUser(UserModel user) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: user.email!,
            password: user.password!,
          );

      // Guardar los datos adicionales en Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': user.email,
        'contrasena': user.password ?? "",
      });
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Iniciar sesion a un usuario
  Future<void> loginUser(UserModel user) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: user.email!,
        password: user.password!,
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }
}
