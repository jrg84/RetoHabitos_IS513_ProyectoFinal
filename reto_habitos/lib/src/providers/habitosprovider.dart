// lib/src/providers/habito_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/HabitosModel.dart';

class HabitoProvider {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // String get userId => FirebaseAuth.instance.currentUser!.uid;

  /// Stream de hábitos del usuario
  Stream<List<Habito>> getHabitosUsuario() {
    return _db
        .collection('habitos')
        // .where('userId', isEqualTo: userId)
        .orderBy('fechaInicio', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Habito.fromJson(doc.data());
      }).toList();
    });
  }

  /// Crear hábito de prueba (para testing)
  Future<String> crearHabitoPrueba() async {
    final docRef = _db.collection('habitos').doc();
    
    final habito = Habito(
      id: docRef.id,
      nombre: 'Meditación',
      descripcion: 'Meditar 10 minutos cada mañana',
      duracion: 10,
      userId: 'test',
      diasRealizados: 5,
      streakActual: 3,
      streakMaxima: 5,
    );
    
    await docRef.set(habito.toJson());
    return docRef.id;
  }

  Future<String> crearHabito(Habito habito) async {
    final docRef = _db.collection('habitos').doc();
    
    final habitoConId = Habito(
      id: docRef.id,
      nombre: habito.nombre,
      descripcion: habito.descripcion,
      duracion: habito.duracion,
      fechaInicio: habito.fechaInicio,
      fechaFin: habito.fechaFin,
      userId: habito.userId,
    );
    
    await docRef.set(habitoConId.toJson());
    return docRef.id;
  }
}