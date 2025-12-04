import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PagoMercadoPagoScreen extends StatelessWidget {
  final String urlPago;
  final VoidCallback onPagoCompleto;

  const PagoMercadoPagoScreen({
    super.key,
    required this.urlPago,
    required this.onPagoCompleto,
  });

  Future<void> _abrirPago() async {
    final url = Uri.parse(urlPago);

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // 👉 En escritorio, abre navegador externo
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // 👉 En móvil (Android/iOS), abre WebView
      await launchUrl(url, mode: LaunchMode.inAppWebView);
    }
  }

  @override
  Widget build(BuildContext context) {
    _abrirPago(); // Se abre automáticamente cuando entras

    return Scaffold(
      appBar: AppBar(title: const Text('Procesando Pago')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Abriendo Mercado Pago...',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onPagoCompleto,
              child: const Text('Ya pagué, continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
