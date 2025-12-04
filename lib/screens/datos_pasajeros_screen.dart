import 'package:flutter/material.dart';
import '../models/ruta.dart';
import 'pago_screen.dart';

class DatosPasajerosScreen extends StatefulWidget {
  final Ruta ruta;
  final List<int> asientosSeleccionados;

  const DatosPasajerosScreen({
    super.key,
    required this.ruta,
    required this.asientosSeleccionados,
  });

  @override
  State<DatosPasajerosScreen> createState() => _DatosPasajerosScreenState();
}

class _DatosPasajerosScreenState extends State<DatosPasajerosScreen> {
  final List<Map<String, String>> _datosPasajeros = [];

  @override
  void initState() {
    super.initState();
    // Inicializamos los formularios según el número de asientos
    _datosPasajeros.addAll(List.generate(
      widget.asientosSeleccionados.length,
      (_) => {'nombre': '', 'apellido': '', 'dni': ''},
    ));
  }

  void _continuarPago() {
    // Validamos campos
    for (var pasajero in _datosPasajeros) {
      if (pasajero['nombre']!.isEmpty ||
          pasajero['apellido']!.isEmpty ||
          pasajero['dni']!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor completa todos los datos de los pasajeros'),
            backgroundColor: Color(0xFF1A237E),
          ),
        );
        return;
      }
    }

    // Pasamos los datos a la siguiente pantalla
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PagoScreen(
          ruta: widget.ruta,
          asientosSeleccionados: widget.asientosSeleccionados,
          pasajeros: _datosPasajeros,
        ),
      ),
    );
  }

  Widget _buildPasajeroForm(int index) {
    final asiento = widget.asientosSeleccionados[index];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pasajero ${index + 1} - Asiento $asiento',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(labelText: 'Nombre'),
              onChanged: (v) => _datosPasajeros[index]['nombre'] = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Apellido'),
              onChanged: (v) => _datosPasajeros[index]['apellido'] = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'DNI'),
              keyboardType: TextInputType.number,
              onChanged: (v) => _datosPasajeros[index]['dni'] = v,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Datos de Pasajeros')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.asientosSeleccionados.length,
              itemBuilder: (context, index) => _buildPasajeroForm(index),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _continuarPago,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CONTINUAR AL PAGO',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
