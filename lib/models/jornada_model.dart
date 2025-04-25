class Jornada {
  final int? idRegistro;
  final int idEmpleado;
  final String fecha;
  final String? horaEntrada;
  final String? horaSalida;
  final String? ultimaActualizacion;
  final double? totalHoras;
  final String? validadoUser;
  final String? validadoAdmin;
  final String? nombre;
  final String? apellido;
  final String? foto;
  final String? registroManual;
  
  // Constructor
  Jornada({
    this.idRegistro,
    required this.idEmpleado,
    required this.fecha,
    this.horaEntrada,
    this.horaSalida,
    this.ultimaActualizacion,
    this.totalHoras,
    this.validadoUser = 'no',
    this.validadoAdmin = 'no',
    this.nombre,
    this.apellido,
    this.foto,
    this.registroManual = 'si',
  });
  
  // Crear un objeto Jornada desde un mapa JSON
  factory Jornada.fromJson(Map<String, dynamic> json) {
    return Jornada(
      idRegistro: json['id_registro'],
      idEmpleado: json['id_empleado'],
      fecha: json['fecha'],
      horaEntrada: json['hora_entrada'],
      horaSalida: json['hora_salida'],
      ultimaActualizacion: json['ultima_actualizacion'],
      totalHoras: json['total_horas'] != null ? double.parse(json['total_horas'].toString()) : null,
      validadoUser: json['validado_user'],
      validadoAdmin: json['validado_admin'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      foto: json['foto'],
      registroManual: json['registro_manual'],
    );
  }
  
  // Convertir el objeto Jornada a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id_registro': idRegistro,
      'id_empleado': idEmpleado,
      'fecha': fecha,
      'hora_entrada': horaEntrada,
      'hora_salida': horaSalida,
      'ultima_actualizacion': ultimaActualizacion,
      'total_horas': totalHoras,
      'validado_user': validadoUser,
      'validado_admin': validadoAdmin,
      'registro_manual': registroManual,
    };
  }
  
  // Copia de objeto con modificaciones
  Jornada copyWith({
    int? idRegistro,
    int? idEmpleado,
    String? fecha,
    String? horaEntrada,
    String? horaSalida,
    String? ultimaActualizacion,
    double? totalHoras,
    String? validadoUser,
    String? validadoAdmin,
    String? nombre,
    String? apellido,
    String? foto,
    String? registroManual,
  }) {
    return Jornada(
      idRegistro: idRegistro ?? this.idRegistro,
      idEmpleado: idEmpleado ?? this.idEmpleado,
      fecha: fecha ?? this.fecha,
      horaEntrada: horaEntrada ?? this.horaEntrada,
      horaSalida: horaSalida ?? this.horaSalida,
      ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
      totalHoras: totalHoras ?? this.totalHoras,
      validadoUser: validadoUser ?? this.validadoUser,
      validadoAdmin: validadoAdmin ?? this.validadoAdmin,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      foto: foto ?? this.foto,
      registroManual: registroManual ?? this.registroManual
    );
  }
}