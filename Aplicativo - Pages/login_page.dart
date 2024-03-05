import 'package:estacao_meteorologica/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _verSenha = false;

  bool isLogin = true;
  late String titulo;
  late String actionButton;
  late String toggleButton;
  @override

  void initState(){
    super.initState();
    setFormAction(true);
  }

  setFormAction(bool acao){
    setState(() {
      isLogin = acao;
      if(isLogin){
        titulo = 'Bem Vindo';
        actionButton = 'Login';
        toggleButton = 'Não possui conta? Cadastre-se agora.';
      }else{
        titulo = 'Crie sua conta';
        actionButton = 'Cadastrar';
        toggleButton = 'Voltar ao Login';
      }
    });
  }

  login() async{
    try{
      await context.read<AuthService>().login(_emailController.text, _senhaController.text);
    }on AuthException catch (e){
      BuildContext;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.black,));
    }
  }


  registrar() async{
    try{
      await context.read<AuthService>().registrar(_emailController.text, _senhaController.text);
    }on AuthException catch (e){
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.black));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 100),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.5,
                    )
                ),
                Padding(
                  padding: EdgeInsets.all(24),
                  child: TextFormField(
                    style: TextStyle(color: Colors.grey),
                    controller: _emailController,
                    decoration: InputDecoration(
                      label: Text('e-mail'),
                      labelStyle: TextStyle(color: Colors.grey,),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        // raio do canto arredondado
                        gapPadding: 10.0,),
                      hintText: 'nome@email.com',
                      hintStyle: TextStyle(color: Colors.grey),

                      prefixIcon: Icon(Icons.email, color: Colors.grey),

                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Informe o e-mail corretamente!';
                      }
                      return null;
                    },
                  ),

                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 24.0),
                  child: TextFormField(
                    obscureText: !_verSenha,
                    controller: _senhaController,
                    style: TextStyle(color: Colors.grey),
                    decoration: InputDecoration(
                        label: Text('senha'),
                        labelStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          // raio do canto arredondado
                          gapPadding: 10.0,),
                        hintText: 'Digite sua senha',
                        hintStyle: TextStyle(color: Colors.grey),

                        prefixIcon: Icon(Icons.lock, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _verSenha
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.white
                          ),
                          onPressed: () {
                            setState(() {
                              _verSenha = !_verSenha;
                            });
                          },
                        )
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Informe sua senha';
                      } else if (value.length < 8) {
                        return 'Digite uma senha de 8 caracteres';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(24.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if(_formKey.currentState!.validate()){
                        if(isLogin){
                          login();
                        }else{
                          registrar();
                        }
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check),
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            actionButton,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                TextButton(onPressed: () => setFormAction(!isLogin), child: Text(toggleButton))
              ],
            ),
          ),

        ),
      ),
    );
  }
  }




