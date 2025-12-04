import 'ruta.dart';

class Reserva {
  final String id;
  final Ruta ruta;
  final int numeroAsiento;
  final DateTime fechaReserva;
  final String estado;
  final String nombrePasajero;
  final String dniPasajero;

  Reserva({
    required this.id,
    required this.ruta,
    required this.numeroAsiento,
    required this.fechaReserva,
    this.estado = 'Confirmada',
    required this.nombrePasajero,
    required this.dniPasajero,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ruta': ruta.toJson(),
      'numeroAsiento': numeroAsiento,
      'fechaReserva': fechaReserva.toIso8601String(),
      'estado': estado,
      'nombrePasajero': nombrePasajero,
      'dniPasajero': dniPasajero,
    };
  }

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'],
      ruta: Ruta.fromJson(json['ruta']),
      numeroAsiento: json['numeroAsiento'],
      fechaReserva: DateTime.parse(json['fechaReserva']),
      estado: json['estado'],
      nombrePasajero: json['nombrePasajero'],
      dniPasajero: json['dniPasajero'],
    );
  }
}
