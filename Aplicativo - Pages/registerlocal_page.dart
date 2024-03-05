import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:estacao_meteorologica/services/auth_service.dart';

import 'home_page.dart';

class RegisterLocalPage extends StatefulWidget {
  const RegisterLocalPage({Key? key}) : super(key: key);

  @override
  State<RegisterLocalPage> createState() => _RegisterLocalPage();
}

class _RegisterLocalPage extends State<RegisterLocalPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late DocumentReference userDocRef; // Declarando sem inicialização aqui
  late final user;  // Usando late

  final fazendaController = TextEditingController();
  final idDispositivoController = TextEditingController();
  final descricaoController = TextEditingController();
  final cidadeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final userId = context.read<AuthService>().usuario?.uid; // Pegando o ID do usuário logado

    if (userId != null) {
      userDocRef = _firestore.collection('usuarios').doc(userId); // Usando o ID do usuário logado
    }
  }
  void dispose() {
    fazendaController.dispose();
    idDispositivoController.dispose();
    descricaoController.dispose();
    cidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF006D61),
        title: Text('Cadastre o dispositivo',
          style: TextStyle(color: Colors.white),),
      ),

      body: Center(
        child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: fazendaController,
                    decoration: InputDecoration(
                        label: Text('Fazenda'),
                        contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0), // raio do canto arredondado
                          gapPadding: 10.0,),
                        hintText: 'Digite o nome da Fazenda'

                    ),

                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: idDispositivoController,
                    decoration: InputDecoration(

                        label: Text('ID Dispositivo'),
                        contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0), // raio do canto arredondado
                          gapPadding: 10.0,),
                        hintText: 'Digite o ID do dispositivo'

                    ),

                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: cidadeController,
                    decoration: InputDecoration(
                        label: Text('Cidade'),
                        contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0), // raio do canto arredondado
                          gapPadding: 10.0,),

                        hintText: 'Digite uma descrição'

                    ),

                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: descricaoController,
                    decoration: InputDecoration(
                        label: Text('Descrição'),
                        contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0), // raio do canto arredondado
                          gapPadding: 10.0,),

                        hintText: 'Digite uma descrição'

                    ),

                  ),
                  SizedBox(height: 12,),
                  ElevatedButton(
                    onPressed: () async {
                      await userDocRef.collection('dispositivos').add({
                        'fazenda': fazendaController.text,
                        'idDispositivo': idDispositivoController.text,
                        'descricao': descricaoController.text,
                        'cidade': cidadeController.text,
                      });

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