import 'dart:convert';
import 'package:http/http.dart' as http;

class MercadoPagoService {
  static const String accessToken =
      'APP_USR-1627096536966718-112620-83741c81c529607d4c0f1d02cb741368-3019382105';

  static Future<String?> crearPreferenciaPago({
    required String titulo,
    required double precio,
    required int cantidad,
  }) async {
    final url = Uri.parse('https://api.mercadopago.com/checkout/preferences');

    final double totalFinal = precio * cantidad;

    final body = {
      "items": [
        {
          "title": titulo,
          "quantity": 1, // Siempre 1, enviamos el total en unit_price
          "currency_id": "PEN",
          "unit_price": totalFinal,
        }
      ],
      "payer": {
        "email": "test_user_123456@testuser.com", // Opcional pero recomendado
      },
      "back_urls": {
        "success": "https://tusitio.com/success",
        "failure": "https://tusitio.com/failure",
        "pending": "https://tusitio.com/pending",
      },
      "external_reference": "Reserva-${DateTime.now().millisecondsSinceEpoch}",
      "auto_return": "approved",
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      // Usar sandbox_init_point si estás con credenciales de prueba
      return data['init_point'] ?? data['sandbox_init_point'];
    } else {
      print('❌ Error al crear preferencia: ${response.statusCode}');
      print(response.body);
      return null;
    }
  }
}
