import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jornada_punto_con/providers/auth_provider.dart';
import 'package:jornada_punto_con/providers/employee_provider.dart';
import 'package:jornada_punto_con/utils/app_theme.dart';

// Pantalla de login para autenticar usuarios
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberCredentials = false;
  
  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }
  
  // Método para cargar credenciales guardadas
  Future<void> _loadSavedCredentials() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final savedCredentials = await authProvider.getSavedCredentials();
    
    if (savedCredentials != null) {
      setState(() {
        _usernameController.text = savedCredentials['username'] ?? '';
        _passwordController.text = savedCredentials['password'] ?? '';
        _rememberCredentials = true;
      });
    }
  }
  
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  // Método para manejar el inicio de sesión
  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
      
      final username = _usernameController.text.trim();
      final password = _passwordController.text;
      
      // Guardar credenciales si está marcada la opción
      if (_rememberCredentials) {
        await authProvider.saveCredentials(username, password);
      } else {
        await authProvider.clearSavedCredentials();
      }
      
      final success = await authProvider.login(username, password);
      
      if (success) {
        // Obtener datos del empleado
        await employeeProvider.getEmployeeByUsername(username);
        
        if (authProvider.isDefaultPassword) {
          // Si la contraseña es la predeterminada, ir a la pantalla de cambio de contraseña
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/change_password');
          }
        } else {
          // Si no, ir a la pantalla principal
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      } else {
        // Mostrar mensaje de error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Error al iniciar sesión'),
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
                    // Logo o nombre de la aplicación
                    const Text(
                      'Punto VB',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Subtítulo
                    const Text(
                      'Control de Jornada Laboral',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 50),
                    // Campo de usuario
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Usuario',
                        hintText: 'nombre.apellido',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese su usuario';
                        }
                        if (!value.contains('.')) {
                          return 'Formato inválido (nombre.apellido)';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !authProvider.isLoading,
                    ),
                    const SizedBox(height: 20),
                    // Campo de contraseña
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese su contraseña';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.done,
                      enabled: !authProvider.isLoading,
                      onFieldSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 15),
                    // Checkbox para recordar credenciales
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberCredentials,
                          onChanged: authProvider.isLoading 
                              ? null 
                              : (value) {
                                  setState(() {
                                    _rememberCredentials = value ?? false;
                                  });
                                },
                          activeColor: AppTheme.primaryColor,
                        ),
                        const Text(
                          'Guardar información de login',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Botón de inicio de sesión
                    ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _login,
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Iniciar Sesión'),
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