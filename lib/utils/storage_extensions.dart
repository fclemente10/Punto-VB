import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Extensão para FlutterSecureStorage com opções de segurança aprimoradas
extension SecureStorageExtensions on FlutterSecureStorage {
  // Configuração básica para Android com nível mais alto de segurança
  static const AndroidOptions secureAndroidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );
  
  // Opções de segurança adicionais para iOS
  static const IOSOptions secureIOSOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  /// Escreve um valor de forma segura com opções otimizadas
  Future<void> writeSecure({
    required String key,
    required String? value,
  }) async {
    await write(
      key: key,
      value: value,
      aOptions: secureAndroidOptions,
      iOptions: secureIOSOptions,
    );
  }

  /// Lê um valor de forma segura
  Future<String?> readSecure({required String key}) async {
    return await read(
      key: key,
      aOptions: secureAndroidOptions,
      iOptions: secureIOSOptions,
    );
  }

  /// Apaga um valor de forma segura
  Future<void> deleteSecure({required String key}) async {
    await delete(
      key: key,
      aOptions: secureAndroidOptions,
      iOptions: secureIOSOptions,
    );
  }
}