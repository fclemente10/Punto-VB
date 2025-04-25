import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:jornada_punto_con/providers/auth_provider.dart';
import 'package:jornada_punto_con/providers/employee_provider.dart';
import 'package:jornada_punto_con/providers/jornada_provider.dart';
import 'package:jornada_punto_con/screens/validacion_jornadas_screen.dart';
import 'package:jornada_punto_con/screens/historico_mensual_screen.dart';
import 'package:jornada_punto_con/utils/app_theme.dart';
import 'package:jornada_punto_con/utils/string_extensions.dart';
import 'package:intl/date_symbol_data_local.dart';

// Pantalla principal de la aplicación
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();
  
  @override
  void initState() {
    super.initState();

      // Inicializar datos de localización para español
  initializeDateFormatting('es_ES', null);
    
    // Actualizar la fecha y hora cada segundo
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
    
    // Cargar la jornada actual al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJornadaActual();
    });
  }
  
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(context);
    final jornadaProvider = Provider.of<JornadaProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Formato para la fecha y hora
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'es_ES');
    final timeFormat = DateFormat('HH:mm:ss');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Punto VB'),
        actions: [
          // Botón de logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Encabezado del drawer
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Punto VB',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    employeeProvider.employee?.nombreCompleto ?? 'Usuario',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    authProvider.user?.username ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Elementos del menú
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Validación de Jornadas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ValidacionJornadasScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Histórico Mensual'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoricoMensualScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () async {
                await authProvider.logout();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Mensaje de bienvenida
              Text(
                'Hola, ${employeeProvider.employee?.nombre ?? 'Usuario'}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              // Fecha actual
              Text(
                dateFormat.format(_currentTime).capitalize(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Hora actual
              Text(
                timeFormat.format(_currentTime),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 60),
              // Estado de la jornada
              Text(
                jornadaProvider.tieneEntradaHoy
                    ? (jornadaProvider.tieneSalidaHoy
                        ? 'Jornada completada'
                        : 'Jornada iniciada')
                    : 'Jornada no iniciada',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: jornadaProvider.tieneEntradaHoy
                      ? (jornadaProvider.tieneSalidaHoy
                          ? Colors.green
                          : Colors.orange)
                      : Colors.grey,
                ),
              ),
              if (jornadaProvider.tieneEntradaHoy && !jornadaProvider.tieneSalidaHoy) ...[
                const SizedBox(height: 10),
                // Mostrar hora de entrada
                Text(
                  'Entrada: ${jornadaProvider.jornadaActual?.horaEntrada ?? ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
              if (jornadaProvider.tieneEntradaHoy && jornadaProvider.tieneSalidaHoy) ...[
                const SizedBox(height: 10),
                // Mostrar hora de entrada y salida
                Text(
                  'Entrada: ${jornadaProvider.jornadaActual?.horaEntrada ?? ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Salida: ${jornadaProvider.jornadaActual?.horaSalida ?? ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                if (jornadaProvider.jornadaActual?.totalHoras != null)
                  Text(
                    'Total: ${jornadaProvider.jornadaActual!.totalHoras!.toStringAsFixed(2)} horas',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
              ],
              const Spacer(),
              // Botón para registrar entrada/salida
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: jornadaProvider.isLoading || jornadaProvider.tieneSalidaHoy
                      ? null // Deshabilitado si está cargando o ya se completó la jornada
                      : _registrarJornada,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: jornadaProvider.tieneEntradaHoy ? Colors.red : AppTheme.primaryColor,
                  ),
                  child: jornadaProvider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          jornadaProvider.tieneEntradaHoy ? 'Registrar Salida' : 'Registrar Entrada',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  // Método para cargar la jornada actual
  Future<void> _loadJornadaActual() async {
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    final jornadaProvider = Provider.of<JornadaProvider>(context, listen: false);
    
    if (employeeProvider.employee != null) {
      await jornadaProvider.getJornadaActual(employeeProvider.employee!.idEmpleado);
    }
  }
  
  // Método para registrar entrada o salida
  Future<void> _registrarJornada() async {
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    final jornadaProvider = Provider.of<JornadaProvider>(context, listen: false);
    
    if (employeeProvider.employee == null) return;
    
    bool success;
    String message;
    
    // Verificar si ya hay una entrada registrada hoy
    if (jornadaProvider.tieneEntradaHoy) {
      // Si hay entrada pero no salida, registrar salida
      if (!jornadaProvider.tieneSalidaHoy) {
        success = await jornadaProvider.registrarSalida();
        message = success ? 'Salida registrada correctamente' : 'Error al registrar salida';
      } else {
        // Ya tiene entrada y salida
        message = 'Ya ha registrado su entrada y salida para hoy';
        success = false;
      }
    } else {
      // No hay entrada, registrar entrada
      success = await jornadaProvider.registrarEntrada(employeeProvider.employee!.idEmpleado);
      message = success ? 'Entrada registrada correctamente' : 'Error al registrar entrada';
    }
    
    // Mostrar mensaje
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : AppTheme.errorColor,
        ),
      );
    }
    
    // Recargar jornada actual
    await _loadJornadaActual();
  }
}