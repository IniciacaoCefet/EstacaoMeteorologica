import 'package:flutter/material.dart';
import 'package:estacao_meteorologica/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:estacao_meteorologica/services/auth_service.dart';
class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _name, _adress, _phone;


  Future<void> _saveToFirestore() async {
    final usuario = FirebaseAuth.instance.currentUser;
    if(usuario != null){
      await FirebaseFirestore.instance.collection('usuarios').doc(usuario.uid).set({
        'nome': _name,
        'endereco': _adress,
        'telefone': _phone,
      });
      mudarPagina();

    }
  }

  mudarPagina(){
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF006D61),
        title: Text('Cadastro',
          style: TextStyle(color: Colors.white),),
      ),
      body: Center(
        child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key:_formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20.0),
                  TextFormField(
                    decoration: InputDecoration(
                        label: Text('Nome'),
                        contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0), // raio do canto arredondado
                          gapPadding: 10.0,),
                        hintText: 'Digite seu nome completo'

                    ),
                    onSaved: (value) {
                      _name = value;
                      print("Nome inserido: $_name"); // Imprime o nome digitado pelo usuário
                    },

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu nome';
                        }
                        return null;
                      }
                  ),

                  SizedBox(height: 20.0),
                  TextFormField(
                    decoration: InputDecoration(
                        label: Text('Endereço'),
                        contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0), // raio do canto arredondado
                          gapPadding: 10.0,),

                        hintText: 'Digite seu endereço'

                    ),
                      onSaved: (value) {
                        _adress = value;
                        print("Nome inserido: $_adress"); // Imprime o nome digitado pelo usuário
                      },

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu nome';
                        }
                        return null;
                      }
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    decoration: InputDecoration(
                        label: Text('Telefone'),
                        contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0), // raio do canto arredondado
                          gapPadding: 10.0,),

                        hintText: 'Digite seu telefone'

                    ),
                      onSaved: (value) {
                        _phone = value;
                        print("Nome inserido: $_phone"); // Imprime o nome digitado pelo usuário
                      },

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu nome';
                        }
                        return null;
                      }
                  ),
                  SizedBox(height: 20.0),

                  SizedBox(height: 12,),
                  ElevatedButton(
                    onPressed: () async{
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        await _saveToFirestore();
                        // Navegue para a próxima página ou mostre uma mensagem de sucesso, conforme necessário
                      }
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));

                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF006D61),
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                    ),
                    child: Text('CADASTRAR'),
                  ),
                  SizedBox(height: 12,),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF006D61),
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                    ),
                    child: Text('VOLTAR'),
                  ),
                ],
              ),
            )
        ),
      ),


    );
  }
}
imprimir(String nome){
  print(nome);
}
