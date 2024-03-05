
import 'package:estacao_meteorologica/login_page.dart';
import 'package:estacao_meteorologica/register_page.dart';
import 'package:estacao_meteorologica/registerlocal_page.dart';
import 'package:estacao_meteorologica/home_page.dart';
import 'package:estacao_meteorologica/info_page.dart';
import 'package:estacao_meteorologica/services/auth_service.dart';
import 'package:estacao_meteorologica/weatherstation_page.dart';
import 'package:estacao_meteorologica/widgets/auth_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => WeatherProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'agribuss',
        theme: ThemeData(

          primarySwatch: Colors.green,
        ),
        home: AuthCheck(),
    );
  }
}
