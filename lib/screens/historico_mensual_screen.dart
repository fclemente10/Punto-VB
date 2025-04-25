import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:jornada_punto_con/models/jornada_model.dart';
import 'package:jornada_punto_con/providers/employee_provider.dart';
import 'package:jornada_punto_con/providers/jornada_provider.dart';
import 'package:jornada_punto_con/utils/app_theme.dart';
import 'package:jornada_punto_con/utils/string_extensions.dart';

// Pantalla para mostrar el histórico mensual de jornadas
class HistoricoMensualScreen extends StatefulWidget {
  const HistoricoMensualScreen({super.key});

  @override
  State<HistoricoMensualScreen> createState() => _HistoricoMensualScreenState();
}

class _HistoricoMensualScreenState extends State<HistoricoMensualScreen> {
  bool _isLoading = false;
  List<Jornada> _todasLasJornadas = [];
  Map<String, List<Jornada>> _jornadasPorMes = {};
  Map<String, double> _totalHorasPorMes = {};
  List<String> _mesesDisponibles = [];

  // Para la edición de jornadas
  int? _jornadaEditandoId;
  TextEditingController _horaEntradaController = TextEditingController();
  TextEditingController _horaSalidaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _horaEntradaController = TextEditingController();
    _horaSalidaController = TextEditingController();
    // Cargar las jornadas al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllJornadas();
    });
  }

  @override
  void dispose() {
    _horaEntradaController.dispose();
    _horaSalidaController.dispose();
    super.dispose();
  }

  // Método para cargar todas las jornadas y organizarlas por mes
  Future<void> _loadAllJornadas() async {
    setState(() {
      _isLoading = true;
    });

    final employeeProvider =
        Provider.of<EmployeeProvider>(context, listen: false);
    final jornadaProvider =
        Provider.of<JornadaProvider>(context, listen: false);

    if (employeeProvider.employee != null) {
      try {
        await jornadaProvider
            .getUltimas30Jornadas(employeeProvider.employee!.idEmpleado);
        _todasLasJornadas = jornadaProvider.jornadas;

        // Organizar jornadas por mes
        _organizarJornadasPorMes();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar jornadas: $e')));
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Organizar jornadas por mes
  void _organizarJornadasPorMes() {
    _jornadasPorMes = {};
    _totalHorasPorMes = {};

    for (var jornada in _todasLasJornadas) {
      final fecha = DateTime.parse(jornada.fecha);
      final mesKey = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}';
      final mesNombre = DateFormat('MMMM yyyy', 'es_ES').format(fecha);

      if (!_jornadasPorMes.containsKey(mesKey)) {
        _jornadasPorMes[mesKey] = [];
        _totalHorasPorMes[mesKey] = 0;
      }

      _jornadasPorMes[mesKey]!.add(jornada);

      if (jornada.totalHoras != null) {
        _totalHorasPorMes[mesKey] =
            _totalHorasPorMes[mesKey]! + jornada.totalHoras!;
      }
    }

    // Ordenar las keys por fecha (de más reciente a más antigua)
    _mesesDisponibles = _jornadasPorMes.keys.toList()
      ..sort((a, b) => b.compareTo(a));
  }

  // Método para iniciar la edición de una jornada
  void _iniciarEdicionJornada(Jornada jornada) {
    setState(() {
      _jornadaEditandoId = jornada.idRegistro;
      _horaEntradaController.text = jornada.horaEntrada != null
          ? jornada.horaEntrada!.substring(0, 5) // Obtener solo HH:MM
          : '';
      _horaSalidaController.text = jornada.horaSalida != null
          ? jornada.horaSalida!.substring(0, 5) // Obtener solo HH:MM
          : '';
    });
  }

  // Método para cancelar la edición
  void _cancelarEdicion() {
    setState(() {
      _jornadaEditandoId = null;
      _horaEntradaController.clear();
      _horaSalidaController.clear();
    });
  }

  // Método para solicitar la revisión (validar con horarios editados)
  Future<void> _solicitarRevision(Jornada jornada) async {
    if (_horaEntradaController.text.isEmpty ||
        _horaSalidaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debe ingresar ambos horarios')));
      return;
    }

    // Validar formato de horas (HH:MM)
    final horaEntradaRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):([0-5][0-9])$');
    final horaSalidaRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):([0-5][0-9])$');

    if (!horaEntradaRegex.hasMatch(_horaEntradaController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Formato de hora de entrada inválido. Use HH:MM')));
      return;
    }

    if (!horaSalidaRegex.hasMatch(_horaSalidaController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Formato de hora de salida inválido. Use HH:MM')));
      return;
    }

    try {
      // Actualizar horarios y validar jornada
      final jornadaProvider =
          Provider.of<JornadaProvider>(context, listen: false);
      if (jornada.idRegistro != null) {
        final success = await jornadaProvider.actualizarYValidarJornada(
            jornada.idRegistro!,
            _horaEntradaController.text,
            _horaSalidaController.text);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Horarios actualizados y jornada validada correctamente'),
            backgroundColor: Colors.green,
          ));

          // Recargar datos
          _loadAllJornadas();

          // Cerrar el modo edición
          _cancelarEdicion();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error al procesar la solicitud'),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Formatters para fecha y hora
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    final monthFormat = DateFormat('MMMM yyyy', 'es_ES');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico Mensual'),
        actions: [
          // Botón para recargar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadAllJornadas,
          ),
        ],
      ),
      body: Column(
        children: [
          // Instrucciones y descripción
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.primaryColor),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Seleccione un mes para ver sus jornadas. Para las jornadas pendientes de validación, puede solicitar una revisión de horarios.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // Lista de meses y jornadas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _mesesDisponibles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            const Text(
                              'No hay registros disponibles',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sus jornadas aparecerán aquí',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _mesesDisponibles.length,
                        itemBuilder: (context, index) {
                          final mesKey = _mesesDisponibles[index];
                          final mesJornadas = _jornadasPorMes[mesKey]!;
                          final totalHoras = _totalHorasPorMes[mesKey]!;

                          // Extraer año y mes del key (formato yyyy-MM)
                          final parts = mesKey.split('-');
                          final year = int.parse(parts[0]);
                          final month = int.parse(parts[1]);

                          // Crear un DateTime para formatear el nombre del mes
                          final mesDateTime = DateTime(year, month);
                          final mesNombre =
                              monthFormat.format(mesDateTime).capitalize();

                          // Contar jornadas pendientes en este mes
                          final jornadasPendientes = mesJornadas
                              .where((j) =>
                                  j.validadoUser == 'no' ||
                                  j.validadoUser == null ||
                                  j.validadoUser == '')
                              .length;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 2,
                            child: ExpansionTile(
                              leading: Icon(
                                Icons.calendar_month,
                                color: month == DateTime.now().month &&
                                        year == DateTime.now().year
                                    ? AppTheme.primaryColor
                                    : Colors.grey,
                                size: 28,
                              ),
                              title: Text(
                                mesNombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total: ${totalHoras.toStringAsFixed(2)} horas • ${mesJornadas.length} jornadas',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  if (jornadasPendientes > 0)
                                    Row(
                                      children: [
                                        const Icon(Icons.warning,
                                            color: Colors.orange, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$jornadasPendientes jornadas pendientes de validar',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange.shade800,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: mesJornadas.length,
                                  itemBuilder: (context, jornadaIndex) {
                                    final jornada = mesJornadas[jornadaIndex];
                                    final fecha = DateTime.parse(jornada.fecha);
                                    final esFinde =
                                        fecha.weekday == DateTime.saturday ||
                                            fecha.weekday == DateTime.sunday;
                                    final requiereValidacion =
                                        (jornada.validadoUser == 'no' ||
                                            jornada.validadoUser == null ||
                                            jornada.validadoUser == '');
                                    final estaEditando = _jornadaEditandoId ==
                                        jornada.idRegistro;

                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                // Fecha de la jornada
                                                Text(
                                                  dateFormat.format(fecha),
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: esFinde
                                                        ? Colors.red
                                                        : Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                // Día de la semana
                                                Text(
                                                  DateFormat('EEEE', 'es_ES')
                                                      .format(fecha)
                                                      .capitalize(),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontStyle: FontStyle.italic,
                                                    color: esFinde
                                                        ? Colors.red
                                                        : Colors.grey,
                                                  ),
                                                ),
                                                const Spacer(),
                                                // Estado de validación
                                                if (!estaEditando)
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          jornada.validadoUser ==
                                                                  'sí'
                                                              ? Colors.green
                                                              : Colors.orange,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Text(
                                                      jornada.validadoUser ==
                                                              'sí'
                                                          ? 'Validada'
                                                          : 'Pendiente',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),

                                            // Información de la jornada (normal o formulario de edición)
                                            if (estaEditando) ...[
                                              // Formulario de edición de horas
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Colors.amber.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                      color: Colors
                                                          .amber.shade200),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                            Icons.edit_calendar,
                                                            color: Colors.amber
                                                                .shade800),
                                                        const SizedBox(
                                                            width: 8),
                                                        const Text(
                                                          'Editar horario:',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Por favor, ingrese los horarios correctos para esta jornada',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors
                                                            .grey.shade700,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: TextFormField(
                                                            controller:
                                                                _horaEntradaController,
                                                            decoration:
                                                                const InputDecoration(
                                                              labelText:
                                                                  'Hora entrada',
                                                              hintText: 'HH:MM',
                                                              border:
                                                                  OutlineInputBorder(),
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          8),
                                                              prefixIcon:
                                                                  Icon(Icons
                                                                      .login),
                                                              filled: true,
                                                              fillColor:
                                                                  Colors.white,
                                                            ),
                                                            keyboardType:
                                                                TextInputType
                                                                    .datetime,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 12),
                                                        Expanded(
                                                          child: TextFormField(
                                                            controller:
                                                                _horaSalidaController,
                                                            decoration:
                                                                const InputDecoration(
                                                              labelText:
                                                                  'Hora salida',
                                                              hintText: 'HH:MM',
                                                              border:
                                                                  OutlineInputBorder(),
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          8),
                                                              prefixIcon:
                                                                  Icon(Icons
                                                                      .logout),
                                                              filled: true,
                                                              fillColor:
                                                                  Colors.white,
                                                            ),
                                                            keyboardType:
                                                                TextInputType
                                                                    .datetime,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        // Botón Cancelar
                                                        OutlinedButton.icon(
                                                          onPressed:
                                                              _cancelarEdicion,
                                                          icon: const Icon(
                                                              Icons.close),
                                                          label: const Text(
                                                              'Cancelar'),
                                                          style: OutlinedButton
                                                              .styleFrom(
                                                            foregroundColor:
                                                                Colors.red,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 12),
                                                        // Botón Solicitar
                                                        ElevatedButton.icon(
                                                          onPressed: () =>
                                                              _solicitarRevision(
                                                                  jornada),
                                                          icon: const Icon(Icons
                                                              .check_circle),
                                                          label: const Text(
                                                              'Solicitar'),
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                AppTheme
                                                                    .primaryColor,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        12),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ] else ...[
                                              // Vista normal de los datos
                                              Row(
                                                children: [
                                                  const Icon(Icons.login,
                                                      size: 16,
                                                      color: Colors.grey),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Entrada: ${jornada.horaEntrada != null ? timeFormat.format(DateTime.parse('2022-01-01 ${jornada.horaEntrada}')) : 'No registrada'}',
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.logout,
                                                      size: 16,
                                                      color: Colors.grey),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Salida: ${jornada.horaSalida != null ? timeFormat.format(DateTime.parse('2022-01-01 ${jornada.horaSalida}')) : 'No registrada'}',
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                              if (jornada.totalHoras !=
                                                  null) ...[
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.timer,
                                                        size: 16,
                                                        color: Colors.grey),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Total: ${jornada.totalHoras!.toStringAsFixed(2)} horas',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],

                                              // Botón para solicitar revisión solo si está pendiente
                                              if (requiereValidacion) ...[
                                                const SizedBox(height: 12),
                                                ElevatedButton.icon(
                                                  onPressed: () =>
                                                      _iniciarEdicionJornada(
                                                          jornada),
                                                  icon: const Icon(Icons.edit),
                                                  label: const Text(
                                                      'Solicitar Revisión'),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.amber.shade700,
                                                    foregroundColor:
                                                        Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
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
