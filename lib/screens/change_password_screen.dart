import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jornada_punto_con/providers/auth_provider.dart';
import 'package:jornada_punto_con/utils/app_theme.dart';

// Pantalla para cambiar la contraseña predeterminada
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  
  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  // Método para cambiar la contraseña
  Future<void> _changePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final newPassword = _newPasswordController.text;
      
      final success = await authProvider.changePassword(newPassword);
      
      if (success) {
        // Mostrar mensaje de éxito
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contraseña actualizada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Ir a la pantalla principal
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        // Mostrar mensaje de error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Error al cambiar la contraseña'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el estado de autenticación
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
        // Deshabilitamos el botón de retroceso
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icono de seguridad
                    const Icon(
                      Icons.security,
                      size: 80,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 30),
                    // Mensaje informativo
                    const Text(
                      'Por favor, ingrese una nueva contraseña',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'La contraseña predeterminada ha expirado y debe ser cambiada para continuar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Campo de nueva contraseña
                    TextFormField(
                      controller: _newPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Nueva Contraseña',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureNewPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese una nueva contraseña';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        if (value == '123456') {
                          return 'No puede usar la contraseña predeterminada';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      enabled: !authProvider.isLoading,
                    ),
                    const SizedBox(height: 20),
                    // Campo de confirmación de contraseña
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirmar Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureConfirmPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, confirme su contraseña';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.done,
                      enabled: !authProvider.isLoading,
                      onFieldSubmitted: (_) => _changePassword(),
                    ),
                    const SizedBox(height: 30),
                    // Botón para guardar la nueva contraseña
                    ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _changePassword,
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Guardar'),
                    ),
                    const SizedBox(height: 20),
                    // Mensaje de error
                    if (authProvider.error != null)
                      Text(
                        authProvider.error!,
                        style: const TextStyle(
                          color: AppTheme.errorColor,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}