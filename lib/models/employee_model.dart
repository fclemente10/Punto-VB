class Employee {
  final int idEmpleado;
  final String nombre;
  final String apellido;
  final String? fechaNacimiento;
  final String macAddress;
  final int contrato;
  final String? foto;
  final int? departamento;
  final int? cargo;
  
  // Constructor
  Employee({
    required this.idEmpleado,
    required this.nombre,
    required this.apellido,
    this.fechaNacimiento,
    required this.macAddress,
    required this.contrato,
    this.foto,
    this.departamento,
    this.cargo,
  });
  
  // Nombre completo del empleado
  String get nombreCompleto => '$nombre $apellido';
  
  // Crear un objeto Employee desde un mapa JSON
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      idEmpleado: json['id_empleado'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      fechaNacimiento: json['fecha_nacimiento'],
      macAddress: json['mac_address'],
      contrato: json['contrato'],
      foto: json['foto'],
      departamento: json['departamento'],
      cargo: json['cargo'],
    );
  }
  
  // Convertir el objeto Employee a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id_empleado': idEmpleado,
      'nombre': nombre,
      'apellido': apellido,
      'fecha_nacimiento': fechaNacimiento,
      'mac_address': macAddress,
      'contrato': contrato,
      'foto': foto,
      'departamento': departamento,
      'cargo': cargo,
    };
  }
}