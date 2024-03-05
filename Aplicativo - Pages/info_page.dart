import 'package:estacao_meteorologica/home_page.dart';
import 'package:estacao_meteorologica/register_page.dart';
import 'package:estacao_meteorologica/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';


class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);


  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<String?> getUserNameFromFirestore() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(currentUser.uid).get();
      return (userDoc.data() as Map<String, dynamic>)?['nome'];
    }
    return null;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF006D61),
        title: Text('Sobre',
        style: TextStyle(color: Colors.white),),

      ),

      body: Padding(
      padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
          Text(
            "Desenvolvedores:",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF006D61)),
          ),
          SizedBox(height: 20),
            CreatorTile(
              name: "Lívia Gonçalves",
            ),

            Text(
              "Orientadores:",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF006D61)),
            ),
            SizedBox(height: 20),
            CreatorTile(
              name: "Alisson Marques da Silva ",
            ),
            CreatorTile(
              name: "Michel Pires da Silva",
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
        },
        child: Icon(Icons.arrow_back),
        backgroundColor: Color(0xFF006D61),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[

            DrawerHeader(

              child: Column(
                mainAxisAlignment: MainAxisAlignment.end, // Isso faz com que o conteúdo da coluna seja alinhado na parte inferior.
                children: [
                  FutureBuilder<String?>(
                    future: getUserNameFromFirestore(),
                    builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          return Text('Erro ao carregar nome.');
                        } else if (snapshot.hasData) {
                          return Text(
                            'Olá, ${snapshot.data}',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }
                      }
                      return CircularProgressIndicator(); // Mostra um spinner até que o nome seja carregado.
                    },
                  ),
                  SizedBox(height: 10),  // Pode ajustar o valor para aumentar ou diminuir o espaço.
                ],
              ),

              decoration: BoxDecoration(
                color: Color(0xFF006D61),
              ),
            ),
            ListTile(
              leading:Icon(FontAwesomeIcons.user, size: 25.0),
              title: Text('Perfil'),
              onTap: () {
                // Atualizar o contexto do app com o item selecionado no Drawer
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => RegisterPage()));
              },
            ),
            ListTile(
              leading:Icon(FontAwesomeIcons.bell, size: 25.0),
              title: Text('Alertas'),
              onTap: () {
                // Atualizar o contexto do app com o item selecionado no Drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading:Icon(FontAwesomeIcons.circleInfo, size: 25.0),
              title: Text('Sobre'),
              onTap: () {
                // Atualizar o contexto do app com o item selecionado no Drawer
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => InfoPage(),),);
              },
            ),
            ListTile (
              leading:Icon(FontAwesomeIcons.arrowRightFromBracket, size: 25.0),
              title: Text('LogOut'),
              onTap: () {
                context.read<AuthService>().logout();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
              },

            ),

          ],
        ),
      ),

    );
  }
}

class CreatorTile extends StatelessWidget {
  final String name;

  CreatorTile({
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: <Widget>[

          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

            ],
          ),
        ],
      ),
    );
  }
}