import 'package:flutter/material.dart';
import '../models/ruta.dart';
import '../models/reserva.dart';
import '../services/data_service.dart';
import 'confirmacion_screen.dart';
import '../mercado_pago/mercado_pago_service.dart';
import '../mercado_pago/pago_mercado_pago_screen.dart';
import 'dart:math';

class PagoScreen extends StatefulWidget {
  final Ruta ruta;
  final List<int> asientosSeleccionados;
  final List<Map<String, String>> pasajeros;

  const PagoScreen({
    super.key,
    required this.ruta,
    required this.asientosSeleccionados,
    required this.pasajeros,
  });

  @override
  State<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  final DataService _dataService = DataService();
  bool _procesando = false;

  String _generarCodigo() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> _finalizarReserva() async {
    final reservas = <Reserva>[];

    for (int i = 0; i < widget.asientosSeleccionados.length; i++) {
      final pasajero = widget.pasajeros[i];
      final codigoReserva = _generarCodigo();

      final reserva = Reserva(
        id: codigoReserva,
        ruta: widget.ruta,
        numeroAsiento: widget.asientosSeleccionados[i],
        fechaReserva: DateTime.now(),
        nombrePasajero: '${pasajero['nombre']} ${pasajero['apellido']}'.trim(),
        dniPasajero: pasajero['dni']!,
      );

      reservas.add(reserva);
      await _dataService.guardarReserva(reserva);
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmacionScreen(reservas: reservas),
      ),
    );
  }

  Future<void> _iniciarPago() async {
    setState(() => _procesando = true);

    try {
      final total = widget.ruta.precio * widget.asientosSeleccionados.length;

      final urlPago = await MercadoPagoService.crearPreferenciaPago(
        titulo: "${widget.ruta.origen} → ${widget.ruta.destino}",
        precio: total,
        cantidad: widget.asientosSeleccionados.length,
      );

      if (!mounted) return;

      setState(() => _procesando = false);

      if (urlPago != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PagoMercadoPagoScreen(
              urlPago: urlPago,
              onPagoCompleto: _finalizarReserva,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo generar el link de pago')),
        );
      }
    } catch (e) {
      setState(() => _procesando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar pago: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.ruta.precio * widget.asientosSeleccionados.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildResumenViaje(total),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _procesando ? null : _iniciarPago,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: const Color(0xFF009EE3),
              ),
              child: _procesando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'PAGAR CON MERCADO PAGO',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenViaje(double total) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del viaje',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const Divider(height: 24),
            _buildInfoRow('Ruta', '${widget.ruta.origen} → ${widget.ruta.destino}'),
            _buildInfoRow('Fecha', widget.ruta.fechaSalida.toString().split(' ')[0]),
            _buildInfoRow('Hora', widget.ruta.horaSalida),
            _buildInfoRow('Asientos', widget.asientosSeleccionados.join(', ')),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total a pagar:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'S/ ${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}
