import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ruta.dart';
import '../models/asiento.dart';
import '../models/reserva.dart';
import '../models/usuario.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  static const String _keyReservas = 'reservas';
  static const String _keyUsuario = 'usuario';

  final List<String> ciudades = [
    'Lima',
    'Arequipa',
    'Cusco',
    'Trujillo',
    'Chiclayo',
    'Piura',
    'Ica',
    'Tacna',
    'Huancayo',
    'Ayacucho',
  ];

  List<Asiento> _generarAsientos(int total, {List<int>? ocupados}) {
    ocupados ??= [];
    return List.generate(
      total,
      (index) => Asiento(
        numero: index + 1,
        disponible: !ocupados!.contains(index + 1),
        pasajero: ocupados.contains(index + 1) ? 'Ocupado' : null,
      ),
    );
  }

  List<Ruta> buscarRutas(String origen, String destino, DateTime fecha) {
    if (origen.isEmpty || destino.isEmpty) return [];
    if (origen == destino) return [];

    final random = Random(fecha.day + origen.hashCode + destino.hashCode);
    final numRutas = 3 + random.nextInt(3);

    return List.generate(numRutas, (index) {
      final horaBase = 6 + (index * 4);
      final minutosSalida = random.nextInt(60);
      final duracionHoras = 4 + random.nextInt(8);
      final duracionMinutos = random.nextInt(60);

      final horaSalida =
          '${horaBase.toString().padLeft(2, '0')}:${minutosSalida.toString().padLeft(2, '0')}';
      final horaLlegadaTotal = horaBase + duracionHoras;
      final minutosLlegada = (minutosSalida + duracionMinutos) % 60;
      final horasExtra = (minutosSalida + duracionMinutos) ~/ 60;
      final horaLlegada =
          '${(horaLlegadaTotal + horasExtra).toString().padLeft(2, '0')}:${minutosLlegada.toString().padLeft(2, '0')}';

      final precioBase = 30.0 + (duracionHoras * 5.0);
      final precio = precioBase + random.nextDouble() * 20;

      final asientosOcupados =
          List.generate(random.nextInt(15), (_) => random.nextInt(40) + 1);
      final asientos = _generarAsientos(40, ocupados: asientosOcupados);
      final disponibles = asientos.where((a) => a.disponible).length;

      final tipos = ['Semi Cama', 'Cama', 'VIP'];

      return Ruta(
        id: 'RT${fecha.millisecondsSinceEpoch}${index}',
        origen: origen,
        destino: destino,
        fechaSalida: fecha,
        horaSalida: horaSalida,
        horaLlegada: horaLlegada,
        precio: double.parse(precio.toStringAsFixed(2)),
        asientosDisponibles: disponibles,
        asientos: asientos,
        tipoBus: tipos[index % tipos.length],
      );
    });
  }

  Future<List<Reserva>> obtenerReservas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reservasJson = prefs.getStringList(_keyReservas) ?? [];
      return reservasJson
          .map((json) => Reserva.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> guardarReserva(Reserva reserva) async {
    final prefs = await SharedPreferences.getInstance();
    final reservas = await obtenerReservas();
    reservas.add(reserva);
    final reservasJson =
        reservas.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_keyReservas, reservasJson);
  }

  Future<Usuario?> obtenerUsuario() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioJson = prefs.getString(_keyUsuario);
      if (usuarioJson == null) {
        final usuarioDefault = Usuario(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nombre: 'Usuario',
          apellido: 'Ejemplo',
          email: 'usuario@ejemplo.com',
          telefono: '999 999 999',
          dni: '12345678',
        );
        await guardarUsuario(usuarioDefault);
        return usuarioDefault;
      }
      return Usuario.fromJson(jsonDecode(usuarioJson));
    } catch (e) {
      return null;
    }
  }

  Future<void> guardarUsuario(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsuario, jsonEncode(usuario.toJson()));
  }

  String generarCodigoReserva() {
    final random = Random();
    final codigo = List.generate(
      8,
      (index) => random.nextInt(36).toRadixString(36).toUpperCase(),
    ).join();
    return 'NV-$codigo';
  }
}
