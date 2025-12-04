import 'package:flutter/material.dart';
import '../models/ruta.dart';
import '../models/asiento.dart';
import 'datos_pasajeros_screen.dart';

class AsientosScreen extends StatefulWidget {
  final Ruta ruta;

  const AsientosScreen({super.key, required this.ruta});

  @override
  State<AsientosScreen> createState() => _AsientosScreenState();
}

class _AsientosScreenState extends State<AsientosScreen> {
  List<int> _asientosSeleccionados = [];

  void _continuarPago() {
    if (_asientosSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona al menos un asiento'),
          backgroundColor: Color(0xFF1A237E),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DatosPasajerosScreen(
          ruta: widget.ruta,
          asientosSeleccionados: _asientosSeleccionados,
        ),
      ),
    );
  }

  Widget _buildAsiento(Asiento asiento) {
    final isSeleccionado = _asientosSeleccionados.contains(asiento.numero);
    final Color color;

    if (!asiento.disponible) {
      color = Colors.grey;
    } else if (isSeleccionado) {
      color = Theme.of(context).colorScheme.secondary;
    } else {
      color = Colors.green;
    }

    return GestureDetector(
      onTap: asiento.disponible
          ? () {
              setState(() {
                if (isSeleccionado) {
                  _asientosSeleccionados.remove(asiento.numero);
                } else {
                  _asientosSeleccionados.add(asiento.numero);
                }
              });
            }
          : null,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSeleccionado ? Colors.white : color,
            width: 2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.event_seat, color: Colors.white, size: 20),
              const SizedBox(height: 2),
              Text(
                '${asiento.numero}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeyenda(Color color, String texto) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(texto, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Asientos'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                Text(
                  '${widget.ruta.origen} → ${widget.ruta.destino}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.ruta.horaSalida} - S/ ${widget.ruta.precio.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLeyenda(Colors.green, 'Disponible'),
                _buildLeyenda(
                    Theme.of(context).colorScheme.secondary, 'Seleccionado'),
                _buildLeyenda(Colors.grey, 'Ocupado'),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.airline_seat_recline_extra, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'CONDUCTOR',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: widget.ruta.asientos.length,
                    itemBuilder: (context, index) {
                      return _buildAsiento(widget.ruta.asientos[index]);
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
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
                  child: Text(
                    _asientosSeleccionados.isNotEmpty
                        ? 'CONTINUAR (${_asientosSeleccionados.length} seleccionados)'
                        : 'SELECCIONA ASIENTOS',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
