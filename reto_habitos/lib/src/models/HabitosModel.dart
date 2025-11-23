// lib/src/models/habito.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Habito {
  final String? id;
  final String nombre;
  final String? descripcion;
  final int duracion;
  final DateTime fechaInicio; 
  final DateTime fechaFin;   
  final String estado;
  final String userId;
  final int diasRealizados;
  final int streakActual;
  final int streakMaxima;
  

  Habito({
    this.id,
    required this.nombre,
    this.descripcion,
    required this.duracion,
    DateTime? fechaInicio,
    DateTime? fechaFin,   
    this.estado = 'activo',
    required this.userId,
    this.diasRealizados = 0,
    this.streakActual = 0,
    this.streakMaxima = 0,
    
  })  : fechaInicio = fechaInicio ?? DateTime.now(),
        fechaFin = fechaFin ?? (fechaInicio ?? DateTime.now()).add(Duration(days: 30));

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'duracion': duracion,
      'fechaInicio': Timestamp.fromDate(fechaInicio),  // ← Siempre existe
      'fechaFin': Timestamp.fromDate(fechaFin),      // ← Siempre existe
      'estado': estado,
      'userId': userId,
      'diasRealizados': diasRealizados,
      'streakActual': streakActual,
      'streakMaxima': streakMaxima,
      
    };
  }

  factory Habito.fromJson(Map<String, dynamic> json) {
    return Habito(
      id: json['id'] as String?,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      duracion: json['duracion'] as int,
      fechaInicio: (json['fechaInicio'] as Timestamp).toDate(),  // ← Sin ?
      fechaFin: (json['fechaFin'] as Timestamp).toDate(),      // ← Sin ?
      estado: json['estado'] as String? ?? 'activo',
      userId: json['userId'] as String,
      diasRealizados: json['diasRealizados'] as int? ?? 0,
      streakActual: json['streakActual'] as int? ?? 0,
      streakMaxima: json['streakMaxima'] as int? ?? 0,
    );
  }

  Habito copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    int? duracion,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? estado,
    String? userId,
    int? diasRealizados,
    int? streakActual,
    int? mejorStreak,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) {
    return Habito(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      duracion: duracion ?? this.duracion,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      estado: estado ?? this.estado,
      userId: userId ?? this.userId,
      diasRealizados: diasRealizados ?? this.diasRealizados,
      streakActual: streakActual ?? this.streakActual,
      streakMaxima: mejorStreak ?? this.streakMaxima,
      
    );
  }

  
  bool get vencido => DateTime.now().isAfter(fechaFin);

  int get diasRestantes {
    final diff = fechaFin.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  int get diasTranscurridos {
    return DateTime.now().difference(fechaInicio).inDays;
  }

  double get porcentajeCompletado {
    return (diasRealizados / 30) * 100;
  }

  
  double get porcentajeTiempoTranscurrido {
    final totalDias = fechaFin.difference(fechaInicio).inDays;
    final diasPasados = DateTime.now().difference(fechaInicio).inDays;
    return (diasPasados / totalDias) * 100;
  }
}