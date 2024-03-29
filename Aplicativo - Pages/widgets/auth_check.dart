import 'package:estacao_meteorologica/home_page.dart';
import 'package:estacao_meteorologica/login_page.dart';
import 'package:estacao_meteorologica/register_page.dart';
import 'package:estacao_meteorologica/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({Key? key}) : super(key: key);


  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  Widget build(BuildContext context){
    AuthService auth = Provider.of<AuthService>(context);


    if(auth.isLoading)
      return loading();
    else if(auth.usuario == null)
      return LoginPage();
    else
      return HomePage();
  }

  loading(){
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

}
