import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jornada_punto_con/providers/auth_provider.dart';
import 'package:jornada_punto_con/providers/employee_provider.dart';
import 'package:jornada_punto_con/providers/jornada_provider.dart';
import 'package:jornada_punto_con/screens/login_screen.dart';
import 'package:jornada_punto_con/screens/change_password_screen.dart';
import 'package:jornada_punto_con/screens/home_screen.dart';
import 'package:jornada_punto_con/screens/splash_screen.dart';
import 'package:jornada_punto_con/screens/validacion_jornadas_screen.dart';
import 'package:jornada_punto_con/screens/historico_mensual_screen.dart';
import 'package:jornada_punto_con/utils/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  // Inicializar o Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar dados de localização para espanhol
  await initializeDateFormatting('es_ES', null);
  
  // Iniciar a aplicação
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Usar MultiProvider para fornecer todos os providers necessários
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => JornadaProvider()),
      ],
      child: MaterialApp(
        title: 'Jornada App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/change_password': (context) => const ChangePasswordScreen(),
          '/home': (context) => const HomeScreen(),
          '/validacion_jornadas': (context) => const ValidacionJornadasScreen(),
          '/historico_mensual': (context) => const HistoricoMensualScreen(),
        },
      ),
    );
  }
}