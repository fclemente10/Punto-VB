import 'package:flutter/foundation.dart';
import 'package:jornada_punto_con/models/user_model.dart';
import 'package:jornada_punto_con/services/api_service.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isDefaultPassword = false;
  String? _autoCheck;
  
  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isDefaultPassword => _isDefaultPassword;
  String? get autoCheck => _autoCheck;
  
  // Método para obtener el username almacenado
  Future<String?> getStoredUsername() async {
    return await _apiService.storage.read(key: 'username');
  }
  
  // Método para guardar credenciales
  Future<void> saveCredentials(String username, String password) async {
    final credentials = {
      'username': username,
      'password': password,
    };
    
    await _apiService.storage.write(
      key: 'saved_credentials',
      value: jsonEncode(credentials),
    );
  }
  
  // Método para obtener credenciales guardadas
  Future<Map<String, String>?> getSavedCredentials() async {
    final savedCredentialsStr = await _apiService.storage.read(key: 'saved_credentials');
    
    if (savedCredentialsStr != null) {
      final Map<String, dynamic> decodedData = jsonDecode(savedCredentialsStr);
      return {
        'username': decodedData['username'],
        'password': decodedData['password'],
      };
    }
    
    return null;
  }
  
  // Método para eliminar credenciales guardadas
  Future<void> clearSavedCredentials() async {
    await _apiService.storage.delete(key: 'saved_credentials');
  }
  
  // Método para iniciar sesión
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
        
    try {
      final user = await _apiService.login(username, password);
      _user = user;
      
      // Corrigindo o acesso à propriedade autoCheck
      _autoCheck = user?.autoCheck ?? 'no'; // Usa 'no' como valor padrão se autoCheck for nulo
            
      // Verificar si la contraseña es la predeterminada
      _isDefaultPassword = password == '123456';
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
  
  // Método para cambiar la contraseña
  Future<bool> changePassword(String newPassword) async {
    if (_user == null) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _apiService.changePassword(_user!.username, newPassword);
      _isLoading = false;
      if (result) {
        _isDefaultPassword = false;
        
        // Actualizar la contraseña guardada si existen credenciales
        final savedCredentials = await getSavedCredentials();
        if (savedCredentials != null && savedCredentials['username'] == _user!.username) {
          await saveCredentials(_user!.username, newPassword);
        }
      }
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Método para cerrar sesión
  Future<void> logout() async {
    await _apiService.logout();
    _user = null;
    _isDefaultPassword = false;
    notifyListeners();
  }
  
  // Método para verificar si el usuario está autenticado
  Future<bool> checkAuthentication() async {
    try {
      final token = await _apiService.storage.read(key: 'token');
      final username = await _apiService.storage.read(key: 'username');
      
      if (token != null && username != null) {
        // Aquí podrías validar el token con el servidor si es necesario
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateAutoCheck(String autoCheck) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Certifique-se de que _user não é nulo e tem username
      if (_user == null || _user!.username.isEmpty) {
        throw Exception('Usuario no autenticado');
      }
      
      final success = await _apiService.actualizarAutoCheck(_user!.username, autoCheck);
      
      if (success) {
        _autoCheck = autoCheck;
      }
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}