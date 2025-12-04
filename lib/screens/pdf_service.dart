import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

Future<void> generarTicketPDF({
  required String nombre,
  required String origen,
  required String destino,
  required String fecha,
  required String hora,
  required String asiento,
  required double precio,
}) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('📃 Ticket de Viaje - Novas Travels',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Nombre: $nombre'),
            pw.Text('Origen: $origen'),
            pw.Text('Destino: $destino'),
            pw.Text('Fecha: $fecha'),
            pw.Text('Hora: $hora'),
            pw.Text('Asiento: $asiento'),
            pw.Text('Precio: S/. $precio'),
            pw.SizedBox(height: 30),
            pw.Text('Gracias por viajar con Novas Travels ❤️',
                style: pw.TextStyle(fontSize: 16)),
          ],
        );
      },
    ),
  );

  final bytes = await pdf.save();
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/boleto_${DateTime.now().millisecondsSinceEpoch}.pdf');

  await file.writeAsBytes(bytes);

  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: 'boleto_novas_travels.pdf',
  );
}
