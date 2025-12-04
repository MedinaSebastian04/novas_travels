import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _registrar() async {
    if (_nombreController.text.isEmpty ||
        _apellidoController.text.isEmpty ||
        _dniController.text.isEmpty ||
        _telefonoController.text.isEmpty ||
        _correoController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Color(0xFF1A237E),
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    
    // Guardamos los datos usando trim() para evitar espacios invisibles
    await prefs.setString('nombre', _nombreController.text.trim());
    await prefs.setString('apellido', _apellidoController.text.trim());
    await prefs.setString('dni', _dniController.text.trim());
    await prefs.setString('telefono', _telefonoController.text.trim());
    await prefs.setString('correo', _correoController.text.trim());
    await prefs.setString('password', _passwordController.text.trim()); // 🔐 IMPORTANTE

    // Opcional: marcar que está registrado
    await prefs.setBool('isLoggedIn', false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registro exitoso, ahora inicia sesión'),
        backgroundColor: Colors.green,
      ),
    );

    // Ir al Login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Registro'),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(_nombreController, 'Nombre'),
              _buildTextField(_apellidoController, 'Apellido'),
              _buildTextField(_dniController, 'DNI', type: TextInputType.number),
              _buildTextField(_telefonoController, 'Teléfono', type: TextInputType.phone),
              _buildTextField(_correoController, 'Correo electrónico'),
              _buildTextField(_passwordController, 'Contraseña', isPassword: true),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _registrar,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF1A237E),
                ),
                child: const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPassword = false, TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: TextField(
        controller: controller,
        keyboardType: type,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
