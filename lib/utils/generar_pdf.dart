import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import '../models/reserva.dart';

class GenerarPdfService {
  static Future<void> generarBoletoPdf(List<Reserva> reservas) async {
    try {
      final pdf = pw.Document();

      final fontRegular = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
      final fontBold = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

      final ByteData logoData = await rootBundle.load('assets/images/novas_logo.png');
      final Uint8List logoBytes = logoData.buffer.asUint8List();

      final ruta = reservas.first.ruta;
      final total = ruta.precio * reservas.length;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // LOGO
                pw.Center(
                  child: pw.Image(pw.MemoryImage(logoBytes), width: 120),
                ),
                pw.SizedBox(height: 10),

                // DETALLES DEL VIAJE
                pw.Text('Detalles del viaje', style: pw.TextStyle(font: fontBold, fontSize: 18)),
                pw.SizedBox(height: 8),

                _buildDetailRow('Ruta', '${ruta.origen} → ${ruta.destino}', fontRegular),
                _buildDetailRow('Fecha', ruta.fechaSalida.toString().split(' ')[0], fontRegular),
                _buildDetailRow('Hora', ruta.horaSalida, fontRegular),
                _buildDetailRow('Tipo de Bus', ruta.tipoBus, fontRegular),
                _buildDetailRow('Total Pagado', 'S/ ${total.toStringAsFixed(2)}', fontRegular, isBold: true),

                pw.SizedBox(height: 15),
                pw.Divider(),

                // PASAJEROS
                pw.Text('Pasajeros', style: pw.TextStyle(font: fontBold, fontSize: 18)),
                pw.SizedBox(height: 10),

                pw.Column(
                  children: reservas.map((reserva) {
                    return pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      margin: const pw.EdgeInsets.only(bottom: 12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Pasajero', reserva.nombrePasajero, fontRegular),
                          _buildDetailRow('DNI', reserva.dniPasajero, fontRegular),
                          _buildDetailRow('Asiento', reserva.numeroAsiento.toString(), fontRegular),
                          _buildDetailRow('Código de reserva', reserva.id, fontRegular),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                pw.SizedBox(height: 20),

                pw.Center(
                  child: pw.Text('Gracias por viajar con Novas Travel 🚌',
                      style: pw.TextStyle(font: fontBold, fontSize: 14)),
                )
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/boleto_viaje.pdf');
      await file.writeAsBytes(await pdf.save());

      print('PDF generado: ${file.path}');
    } catch (e) {
      print('Error al generar PDF: $e');
    }
  }

  static pw.Widget _buildDetailRow(
      String label, String value, pw.Font font,
      {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: 14)),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: font,
              fontSize: 14,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
