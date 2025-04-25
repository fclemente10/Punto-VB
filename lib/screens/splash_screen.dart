import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jornada_punto_con/providers/auth_provider.dart';
import 'package:jornada_punto_con/providers/employee_provider.dart';

// Pantalla de splash que se muestra al iniciar la aplicación
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Verificar autenticación después de que el widget se construya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  // Método para verificar si el usuario está autenticado
  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = await authProvider.checkAuthentication();

    if (isAuthenticated) {
      // Si el usuario está autenticado, obtener los datos del empleado
      final username = authProvider.user?.username ??
          await authProvider.getStoredUsername();
      
      if (username != null) {
        final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
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
        // Si no hay username, ir a la pantalla de login
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } else {
      // Si no está autenticado, ir a la pantalla de login
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o nombre de la aplicación
            Text(
              'Punto VB',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            SizedBox(height: 30),
            // Indicador de carga
            CircularProgressIndicator(),
            SizedBox(height: 20),
            // Mensaje de carga
            Text(
              'Cargando...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}