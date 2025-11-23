// lib/src/models/progreso_dia.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgresoDia {
  final String? progresoFecha; 
  final bool finalizado;  
  final int duracionTotal;
  final DateTime? tiempoInicio;
  final String? observacion;  
  

  ProgresoDia({
    this.progresoFecha,
    this.finalizado = false,
    this.duracionTotal = 0,
    this.tiempoInicio,
    this.observacion,
  });

  Map<String, dynamic> toJson() {
    return {
      if (progresoFecha != null) 'progresoFecha': progresoFecha,
      'finalizado': finalizado,
      'duracionTotal': duracionTotal,
      'tiempoInicio': tiempoInicio != null
          ? Timestamp.fromDate(tiempoInicio!)
          : null,
      'observacion': observacion,

    };
  }

  factory ProgresoDia.fromJson(Map<String, dynamic> json) {
    return ProgresoDia(
      progresoFecha: json['progresoFecha'] as String?,
      finalizado: json['finalizado'] as bool? ?? false,
      duracionTotal: json['duracionTotal'] as int? ?? 0,
      tiempoInicio: json['tiempoInicio'] != null
          ? (json['tiempoInicio'] as Timestamp).toDate()
          : null,
      observacion: json['observacion'] as String?

    );
  }

  ProgresoDia copyWith({
    String? progresoFecha,
    bool? finalizado,
    int? duracionTotal,
    DateTime? tiempoInicio,
    String? observacion,
    DateTime? creadoEn,
  }) {
    return ProgresoDia(
      progresoFecha: progresoFecha ?? this.progresoFecha,
      finalizado: finalizado ?? this.finalizado,
      duracionTotal: duracionTotal ?? this.duracionTotal,
      tiempoInicio: tiempoInicio,  
      observacion: observacion ?? this.observacion
    );
  }

  
  bool get timerActivo => tiempoInicio != null;

  
  int get duracionSesionActual {
    if (tiempoInicio == null) return 0;
    return DateTime.now().difference(tiempoInicio!).inMinutes;
  }
  
  int get duracionTotalActual {
    return duracionTotal + duracionSesionActual;
  }

  // muestra "00:15" formato (HH:MM)
  String get tiempoFormateado {
    final total = duracionTotalActual;
    final horas = total ~/ 60;
    final minutos = total % 60;
    return '${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}';
  }
}