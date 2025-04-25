import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jornada_punto_con/models/jornada_model.dart';
import 'package:jornada_punto_con/providers/employee_provider.dart';
import 'package:jornada_punto_con/providers/jornada_provider.dart';
import 'package:jornada_punto_con/utils/app_theme.dart';

// Pantalla para la validación de las jornadas por parte del empleado
class ValidacionJornadasScreen extends StatefulWidget {
  const ValidacionJornadasScreen({super.key});

  @override
  State<ValidacionJornadasScreen> createState() => _ValidacionJornadasScreenState();
}

class _ValidacionJornadasScreenState extends State<ValidacionJornadasScreen> {
  bool _isLoading = false;
  bool _autoValidacion = false;
  final _storage = const FlutterSecureStorage();
  
  @override
  void initState() {
    super.initState();
    // Cargar las jornadas no validadas al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJornadasNoValidadas();
      _loadAutoValidacionStatus();
    });
  }
  
  // Cargar el estado de auto-validación
  Future<void> _loadAutoValidacionStatus() async {
    final autoCheck = await _storage.read(key: 'autoCheck');
    setState(() {
      _autoValidacion = autoCheck == 'sí';
    });
  }
  
  // Método para cargar solo las jornadas no validadas
  Future<void> _loadJornadasNoValidadas() async {
    setState(() {
      _isLoading = true;
    });
    
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    final jornadaProvider = Provider.of<JornadaProvider>(context, listen: false);
    
    if (employeeProvider.employee != null) {
      // Usamos el nuevo método para obtener solo jornadas no validadas
      await jornadaProvider.getJornadasNoValidadas(employeeProvider.employee!.idEmpleado);
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  // Método para validar una jornada
  Future<void> _validarJornada(Jornada jornada) async {
    final jornadaProvider = Provider.of<JornadaProvider>(context, listen: false);
    
    if (jornada.idRegistro != null) {
      final success = await jornadaProvider.validarJornada(jornada.idRegistro!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Jornada validada correctamente' : 'Error al validar la jornada',
            ),
            backgroundColor: success ? Colors.green : AppTheme.errorColor,
          ),
        );
      }
    }
  }
  
  // Método para cambiar el estado de auto-validación
  Future<void> _cambiarAutoValidacion(bool value) async {
    await _storage.write(key: 'autoCheck', value: value ? 'sí' : 'no');
    
    setState(() {
      _autoValidacion = value;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value 
            ? 'Las jornadas serán validadas automáticamente' 
            : 'Validación automática desactivada'
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jornadaProvider = Provider.of<JornadaProvider>(context);
    // Usamos la nueva lista de jornadas no validadas
    final jornadasNoValidadas = jornadaProvider.jornadasNoValidadas;
    
    // Formatters para fecha y hora
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validación de Jornadas'),
        actions: [
          // Botón para recargar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadJornadasNoValidadas,
          ),
        ],
      ),
      body: Column(
        children: [
          // Toggle para auto-validación
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Validación automática',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Activar para validar automáticamente todas las jornadas futuras',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _autoValidacion,
                  activeColor: AppTheme.primaryColor,
                  onChanged: _cambiarAutoValidacion,
                ),
              ],
            ),
          ),
          
          // Lista de jornadas o mensaje de no hay jornadas
          Expanded(
            child: _isLoading || jornadaProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : jornadasNoValidadas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No hay jornadas pendientes de validar',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Todas tus jornadas han sido validadas',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: jornadasNoValidadas.length,
                        itemBuilder: (context, index) {
                          final jornada = jornadasNoValidadas[index];
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // Fecha de la jornada
                                      Text(
                                        dateFormat.format(DateTime.parse(jornada.fecha)),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      // Indicador de pendiente
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.pending, color: Colors.white, size: 16),
                                            SizedBox(width: 4),
                                            Text(
                                              'Pendiente',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Información de la jornada
                                  Row(
                                    children: [
                                      const Icon(Icons.login, size: 16, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Entrada: ${jornada.horaEntrada != null ? timeFormat.format(DateTime.parse('2022-01-01 ${jornada.horaEntrada}')) : 'No registrada'}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.logout, size: 16, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Salida: ${jornada.horaSalida != null ? timeFormat.format(DateTime.parse('2022-01-01 ${jornada.horaSalida}')) : 'No registrada'}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  if (jornada.totalHoras != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.timer, size: 16, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Total: ${jornada.totalHoras!.toStringAsFixed(2)} horas',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  // Botón para validar jornada
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.check_circle),
                                      label: const Text('Validar Jornada'),
                                      onPressed: () => _validarJornada(jornada),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryColor,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    ); 
  }
}