class User {
  final int id;
  final String username;
  final String role;
  final String token; // JWT token
  final String? autoCheck; // Novo campo
  
  // Constructor
  User({
    required this.id,
    required this.username,
    required this.role,
    required this.token,
    this.autoCheck = 'no', // Valor padrão
  });
  
  // Crear un objeto User desde un mapa JSON
  factory User.fromJson(Map<String, dynamic> json, String token) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      role: json['role'] ?? 'user',
      token: token,
      autoCheck: json['auto_check'] ?? 'no',
    );
  }
  
  // Convertir el objeto User a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
      'token': token,
      'auto_check': autoCheck,
    };
  }
}