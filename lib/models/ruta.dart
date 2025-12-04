import 'asiento.dart';

class Ruta {
  final String id;
  final String origen;
  final String destino;
  final DateTime fechaSalida;
  final String horaSalida;
  final String horaLlegada;
  final double precio;
  final int asientosDisponibles;
  final List<Asiento> asientos;
  final String tipoBus;

  Ruta({
    required this.id,
    required this.origen,
    required this.destino,
    required this.fechaSalida,
    required this.horaSalida,
    required this.horaLlegada,
    required this.precio,
    required this.asientosDisponibles,
    required this.asientos,
    this.tipoBus = 'Semi Cama',
  });

  String get duracion {
    final inicio = _parseHora(horaSalida);
    final fin = _parseHora(horaLlegada);
    final duracionMinutos = fin.difference(inicio).inMinutes;
    final horas = duracionMinutos ~/ 60;
    final minutos = duracionMinutos % 60;
    return '${horas}h ${minutos}min';
  }

  DateTime _parseHora(String hora) {
    final partes = hora.split(':');
    return DateTime(2000, 1, 1, int.parse(partes[0]), int.parse(partes[1]));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'origen': origen,
      'destino': destino,
      'fechaSalida': fechaSalida.toIso8601String(),
      'horaSalida': horaSalida,
      'horaLlegada': horaLlegada,
      'precio': precio,
      'asientosDisponibles': asientosDisponibles,
      'asientos': asientos.map((a) => a.toJson()).toList(),
      'tipoBus': tipoBus,
    };
  }

  factory Ruta.fromJson(Map<String, dynamic> json) {
    return Ruta(
      id: json['id'],
      origen: json['origen'],
      destino: json['destino'],
      fechaSalida: DateTime.parse(json['fechaSalida']),
      horaSalida: json['horaSalida'],
      horaLlegada: json['horaLlegada'],
      precio: json['precio'].toDouble(),
      asientosDisponibles: json['asientosDisponibles'],
      asientos: (json['asientos'] as List)
          .map((a) => Asiento.fromJson(a))
          .toList(),
      tipoBus: json['tipoBus'] ?? 'Semi Cama',
    );
  }
}
