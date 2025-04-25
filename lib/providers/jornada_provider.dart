import 'package:flutter/foundation.dart';
import 'package:jornada_punto_con/models/jornada_model.dart';
import 'package:jornada_punto_con/services/api_service.dart';
import 'package:intl/intl.dart';

class JornadaProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Jornada> _jornadas = [];
  List<Jornada> _jornadasNoValidadas = [];
  Jornada? _jornadaActual;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Jornada> get jornadas => _jornadas;
  List<Jornada> get jornadasNoValidadas => _jornadasNoValidadas;
  Jornada? get jornadaActual => _jornadaActual;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get tieneEntradaHoy => _jornadaActual != null && _jornadaActual!.horaEntrada != null;
  bool get tieneSalidaHoy => _jornadaActual != null && _jornadaActual!.horaSalida != null;
  
  // Método para obtener las últimas 30 jornadas del empleado
  Future<bool> getUltimas30Jornadas(int idEmpleado) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final jornadas = await _apiService.getJornadasByEmpleadoId(idEmpleado);
      
      // Ordenar por fecha descendente y tomar las últimas 30
      jornadas.sort((a, b) => b.fecha.compareTo(a.fecha));
      _jornadas = jornadas.take(30).toList();
      
      // Filtrar jornadas no validadas
      _jornadasNoValidadas = _jornadas.where((jornada) => 
        jornada.validadoUser == null || 
        jornada.validadoUser == "" || 
        jornada.validadoUser == "no"
      ).toList();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Método para obtener las jornadas no validadas del empleado
  Future<bool> getJornadasNoValidadas(int idEmpleado) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final jornadas = await _apiService.getJornadasByEmpleadoId(idEmpleado);
      
      // Filtrar solo las jornadas no validadas por el usuario
      _jornadasNoValidadas = jornadas.where((jornada) => 
        (jornada.validadoUser == null || 
         jornada.validadoUser == "" || 
         jornada.validadoUser == "no") &&
        jornada.horaSalida != null // Solo mostrar jornadas con salida registrada
      ).toList();
      
      // Ordenar por fecha descendente
      _jornadasNoValidadas.sort((a, b) => b.fecha.compareTo(a.fecha));
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Método para obtener las jornadas del mes actual
  Future<List<Jornada>> getJornadasMesActual(int idEmpleado) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final jornadas = await _apiService.getJornadasByEmpleadoId(idEmpleado);
      
      // Filtrar jornadas del mes actual
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
      final jornadasMesActual = jornadas.where((jornada) {
        final fechaJornada = DateTime.parse(jornada.fecha);
        return fechaJornada.isAfter(firstDayOfMonth.subtract(const Duration(days: 1))) && 
               fechaJornada.isBefore(lastDayOfMonth.add(const Duration(days: 1)));
      }).toList();
      // Ordenar por fecha
      jornadasMesActual.sort((a, b) => a.fecha.compareTo(b.fecha));
      
      _isLoading = false;
      notifyListeners();
      return jornadasMesActual;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }
  
  // Método para obtener la jornada actual
  Future<bool> getJornadaActual(int idEmpleado) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final jornada = await _apiService.getJornadaActual(idEmpleado);
      _jornadaActual = jornada;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Método para registrar entrada
  Future<bool> registrarEntrada(int idEmpleado) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final jornada = await _apiService.registrarEntrada(idEmpleado);
      _jornadaActual = jornada;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  

// Método para registrar salida
  Future<bool> registrarSalida() async {
    if (_jornadaActual == null) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final jornada = await _apiService.registrarSalida(_jornadaActual!);
      _jornadaActual = jornada;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  // Método para validar jornada
  Future<bool> validarJornada(int idRegistro) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _apiService.validarJornadaUsuario(idRegistro);
      
      if (result) {
        // Actualizar la jornada en la lista
        final index = _jornadas.indexWhere((j) => j.idRegistro == idRegistro);
        if (index != -1) {
          _jornadas[index] = _jornadas[index].copyWith(validadoUser: 'sí');
        }
        
        // Eliminar de la lista de no validadas
        _jornadasNoValidadas.removeWhere((j) => j.idRegistro == idRegistro);
      }
      
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // NUEVO: Método para actualizar horarios y validar jornada
  Future<bool> actualizarYValidarJornada(int idRegistro, String horaEntrada, String horaSalida) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Primero actualizar los horarios
      final resultadoActualizacion = await _apiService.actualizarHorariosJornada(
        idRegistro, 
        horaEntrada, 
        horaSalida
      );
      
      if (resultadoActualizacion) {
        // Si la actualización fue exitosa, validar la jornada
        final resultadoValidacion = await _apiService.validarJornadaUsuario(idRegistro);
        
        if (resultadoValidacion) {
          // Actualizar la jornada en las listas locales
          final index = _jornadas.indexWhere((j) => j.idRegistro == idRegistro);
          if (index != -1) {
            // Calculamos el total de horas
            final entrada = DateFormat('HH:mm').parse(horaEntrada);
            final salida = DateFormat('HH:mm').parse(horaSalida);
            final diferencia = DateTime(
              2022, 1, 1,
              salida.hour, salida.minute
            ).difference(
              DateTime(2022, 1, 1, entrada.hour, entrada.minute)
            );
            final totalHoras = diferencia.inMinutes / 60.0;
            
            _jornadas[index] = _jornadas[index].copyWith(
              horaEntrada: horaEntrada,
              horaSalida: horaSalida,
              totalHoras: totalHoras,
              validadoUser: 'sí'
            );
          }
          
          // Eliminar de la lista de no validadas
          _jornadasNoValidadas.removeWhere((j) => j.idRegistro == idRegistro);
        }
        
        _isLoading = false;
        notifyListeners();
        return resultadoValidacion;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Limpiar datos
  void clear() {
    _jornadas = [];
    _jornadasNoValidadas = [];
    _jornadaActual = null;
    notifyListeners();
  }
}