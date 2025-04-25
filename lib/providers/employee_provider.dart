import 'package:flutter/foundation.dart';
import 'package:jornada_punto_con/models/employee_model.dart'; // Cambiado de user_model a employee_model
import 'package:jornada_punto_con/services/api_service.dart';

class EmployeeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  Employee? _employee; // Agregado un empleado actual
  List<Employee> _employees = []; // Cambiado de List<User> a List<Employee>
  bool _isLoading = false;
  String? _error;
  
  // Getters
  Employee? get employee => _employee; // Agregado getter para employee
  List<Employee> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Método para obtener empleado por username
  Future<bool> getEmployeeByUsername(String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final employee = await _apiService.getEmployeeByUsername(username);
      _employee = employee;
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
  
  // Método para cargar empleados
  Future<void> loadEmployees() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _employees = await _apiService.getEmployees();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Limpiar datos
  void clear() {
    _employee = null;
    _employees = [];
    notifyListeners();
  }
}