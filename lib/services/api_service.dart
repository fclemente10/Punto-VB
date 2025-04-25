import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jornada_punto_con/models/employee_model.dart';
import 'package:jornada_punto_con/models/jornada_model.dart';
import 'package:jornada_punto_con/models/user_model.dart';
import 'package:jornada_punto_con/utils/storage_extensions.dart';

class ApiService {
  // URL base del API
  final String baseUrl = 'http://78.136.71.138:3000/api'; // Para emulador Android
  // Para dispositivos físicos o iOS, necesitarás cambiar esta URL
  // final String baseUrl = 'http://tu-ip-local:3000/api';
  
  final storage = const FlutterSecureStorage();
  
  // Método para autenticar al usuario
  Future<User?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        
        // Decodificar el token para obtener los datos del usuario
        final parts = token.split('.');
        if (parts.length != 3) {
          throw Exception('Token inválido');
        }
        
        String payload = parts[1];
        // Ajustar la longitud de la cadena para que sea múltiplo de 4
        payload = base64Url.normalize(payload);
        
        final payloadMap = json.decode(utf8.decode(base64Url.decode(payload)));
        
        final user = User(
          id: payloadMap['id'],
          username: username,
          role: payloadMap['role'],
          token: token,
          autoCheck: 'no',
        );
        
        // Guardar token en almacenamiento seguro usando la extensión
        await storage.writeSecure(key: 'token', value: token);
        await storage.writeSecure(key: 'username', value: username);
        
        return user;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Error de autenticación');
      }
    } catch (e) {
      debugPrint('Error en login: $e');
      rethrow;
    }
  }
  
    // Método para obtener el token de autenticación
  Future<String?> getAuthToken() async {
    return await storage.readSecure(key: 'token');
  }
  
  // Método para obtener el nombre de usuario
  Future<String?> getUsername() async {
    return await storage.readSecure(key: 'username');
  }
  
  // Método para cerrar sesión
  Future<void> logout() async {
    await storage.deleteSecure(key: 'token');
    await storage.deleteSecure(key: 'username');
    // No eliminamos las credenciales guardadas, solo los tokens de sesión
  }
  
  // Método para guardar y recuperar credenciales
  Future<void> saveCredentials(String username, String password) async {
    final credentials = json.encode({
      'username': username,
      'password': password,
    });
    await storage.writeSecure(key: 'saved_credentials', value: credentials);
  }
  
  Future<Map<String, String>?> getSavedCredentials() async {
    final credentialsStr = await storage.readSecure(key: 'saved_credentials');
    if (credentialsStr != null) {
      final Map<String, dynamic> data = json.decode(credentialsStr);
      return {
        'username': data['username'] as String,
        'password': data['password'] as String,
      };
    }
    return null;
  }
  
  Future<void> clearSavedCredentials() async {
    await storage.deleteSecure(key: 'saved_credentials');
  }
  // Método para actualizar la contraseña
  Future<bool> changePassword(String username, String newPassword) async {
    try {
      final token = await storage.read(key: 'token');
      
      if (token == null) {
        throw Exception('No se ha encontrado el token');
      }
      
      final response = await http.put(
        Uri.parse('$baseUrl/usuarios/password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'username': username,
          'password': newPassword,
        }),
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Error al cambiar la contraseña');
      }
    } catch (e) {
      debugPrint('Error en changePassword: $e');
      rethrow;
    }
  }
  
  // Método para obtener todos los empleados
  Future<List<Employee>> getEmployees() async {
    try {
      final token = await storage.read(key: 'token');
      
      if (token == null) {
        throw Exception('No se ha encontrado el token');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/empleados'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Employee.fromJson(item)).toList();
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Error al obtener empleados');
      }
    } catch (e) {
      debugPrint('Error en getEmployees: $e');
      rethrow;
    }
  }
  
  // Método para obtener los datos del empleado
  Future<Employee> getEmployeeByMacAddress(String macAddress) async {
    try {
      final token = await storage.read(key: 'token');
      
      if (token == null) {
        throw Exception('No se ha encontrado el token');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/empleados/$macAddress'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Employee.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Error al obtener datos del empleado');
      }
    } catch (e) {
      debugPrint('Error en getEmployeeByMacAddress: $e');
      rethrow;
    }
  }

  // Método para obtener empleado por username
  Future<Employee> getEmployeeByUsername(String username) async {
    try {
      final token = await storage.read(key: 'token');
      
      if (token == null) {
        throw Exception('No se ha encontrado el token');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/empleados/username/$username'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Employee.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Error al obtener datos del empleado');
      }
    } catch (e) {
      debugPrint('Error en getEmployeeByUsername: $e');
      rethrow;
    }
  }

  // Método para obtener las jornadas del empleado
  Future<List<Jornada>> getJornadasByEmpleadoId(int idEmpleado) async {
    try {
      final token = await storage.read(key: 'token');
      
      if (token == null) {
        throw Exception('No se ha encontrado el token');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/jornadas/$idEmpleado'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Jornada.fromJson(item)).toList();
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Error al obtener jornadas');
      }
    } catch (e) {
      debugPrint('Error en getJornadasByEmpleadoId: $e');
      rethrow;
    }
  }
  
  // Método para obtener la jornada del día actual
  Future<Jornada?> getJornadaActual(int idEmpleado) async {
    try {
      final jornadas = await getJornadasByEmpleadoId(idEmpleado);
      final hoy = DateTime.now();
      final fechaHoy = '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
      
      for (var jornada in jornadas) {
        if (jornada.fecha == fechaHoy) {
          return jornada;
        }
      }
      
      return null; // No hay jornada para hoy
    } catch (e) {
      debugPrint('Error en getJornadaActual: $e');
      rethrow;
    }
  }
  
  // Método para registrar entrada
Future<Jornada> registrarEntrada(int idEmpleado) async {
  try {
    final token = await storage.read(key: 'token');
    
    if (token == null) {
      throw Exception('No se ha encontrado el token');
    }
    
    final now = DateTime.now();
    final fecha = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final horaEntrada = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final ultimaActualizacion = horaEntrada;
    
    // Simplificar requisição para apenas os campos essenciais
    final response = await http.post(
      Uri.parse('$baseUrl/jornadas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'id_empleado': idEmpleado,
        'fecha': fecha,
        'hora_entrada': horaEntrada,
        'ultima_actualizacion': ultimaActualizacion,
        'registro_manual': 'sí',
        'hora_salida': null,    // Enviar explicitamente como null
        'total_horas': null     // Enviar explicitamente como null
      }),
    );
    
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      final nuevaJornada = Jornada(
        idRegistro: data['id_registro'],
        idEmpleado: idEmpleado,
        fecha: fecha,
        horaEntrada: horaEntrada,
        ultimaActualizacion: ultimaActualizacion,
        registroManual: 'sí'
      );
      return nuevaJornada;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Error al registrar entrada');
    }
  } catch (e) {
    debugPrint('Error en registrarEntrada: $e');
    rethrow;
  }
}
  // Método para registrar salida
  Future<Jornada> registrarSalida(Jornada jornada) async {
  try {
    final token = await storage.read(key: 'token');
    final autoCheck = await storage.read(key: 'autoCheck') ?? 'no';
    
    if (token == null) {
      throw Exception('No se ha encontrado el token');
    }
    
    final now = DateTime.now();
    final horaSalida = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final ultimaActualizacion = horaSalida;
    
    // Calcular total de horas
    final entrada = DateTime.parse('2022-01-01 ${jornada.horaEntrada!}');
    final salida = DateTime.parse('2022-01-01 $horaSalida');
    final diferencia = salida.difference(entrada);
    final totalHoras = diferencia.inMinutes / 60.0;
    
    // Criar o corpo do request, incluindo validado_user se autoCheck for 'sí'
    final Map<String, dynamic> requestBody = {
      'hora_entrada': jornada.horaEntrada,
      'hora_salida': horaSalida,
      'ultima_actualizacion': ultimaActualizacion,
      'total_horas': totalHoras,
    };
    
    // Adicionar validado_user se autoCheck estiver ativado
    if (autoCheck == 'sí') {
      requestBody['validado_user'] = 'sí';
    }
    
    final response = await http.put(
      Uri.parse('$baseUrl/jornadas/${jornada.idRegistro}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(requestBody),
    );
    
    if (response.statusCode == 200) {
      return jornada.copyWith(
        horaSalida: horaSalida,
        ultimaActualizacion: ultimaActualizacion,
        totalHoras: totalHoras,
        validadoUser: autoCheck == 'sí' ? 'sí' : jornada.validadoUser,
      );
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Error al registrar salida');
    }
  } catch (e) {
    debugPrint('Error en registrarSalida: $e');
    rethrow;
  }
}
  
  // NUEVO: Método para actualizar horarios de jornada
  Future<bool> actualizarHorariosJornada(int idRegistro, String horaEntrada, String horaSalida) async {
    try {
      final token = await storage.read(key: 'token');
      
      if (token == null) {
        throw Exception('No se ha encontrado el token');
      }
      
      // Aseguramos el formato correcto de las horas
      final String horaEntradaFormateada = horaEntrada.contains(':') && horaEntrada.split(':').length == 2
          ? '$horaEntrada:00'
          : horaEntrada;
          
      final String horaSalidaFormateada = horaSalida.contains(':') && horaSalida.split(':').length == 2
          ? '$horaSalida:00'
          : horaSalida;
      
      final now = DateTime.now();
      final ultimaActualizacion = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
      
      // Calcular total de horas
      final entrada = DateTime.parse('2022-01-01 $horaEntradaFormateada');
      final salida = DateTime.parse('2022-01-01 $horaSalidaFormateada');
      final diferencia = salida.difference(entrada);
      final totalHoras = diferencia.inMinutes / 60.0;
      
      final response = await http.put(
        Uri.parse('$baseUrl/jornadas/$idRegistro'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'hora_entrada': horaEntradaFormateada,
          'hora_salida': horaSalidaFormateada,
          'ultima_actualizacion': ultimaActualizacion,
          'total_horas': totalHoras,
        }),
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Error al actualizar horarios');
      }
    } catch (e) {
      debugPrint('Error en actualizarHorariosJornada: $e');
      rethrow;
    }
  }
  
  // Método para validar jornada por parte del usuario
  Future<bool> validarJornadaUsuario(int idRegistro) async {
    try {
      final token = await storage.read(key: 'token');
      
      if (token == null) {
        throw Exception('No se ha encontrado el token');
      }
      
      final response = await http.put(
        Uri.parse('$baseUrl/jornadas/$idRegistro/validar-usuario'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Error al validar jornada');
      }
    } catch (e) {
      debugPrint('Error en validarJornadaUsuario: $e');
      rethrow;
    }
  }
  
  // Método para atualizar o status de auto_check do usuário
  Future<bool> actualizarAutoCheck(String username, String autoCheck) async {
  try {
    final token = await storage.read(key: 'token');
    
    if (token == null) {
      throw Exception('No se ha encontrado el token');
    }
    
    final response = await http.put(
      Uri.parse('$baseUrl/usuarios/auto-check'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'username': username,
        'auto_check': autoCheck,
      }),
    );
    
    if (response.statusCode == 200) {
      return true;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Error al actualizar auto_check');
    }
  } catch (e) {
    debugPrint('Error en actualizarAutoCheck: $e');
    rethrow;
  }
}
}