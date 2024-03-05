import 'package:estacao_meteorologica/info_page.dart';
import 'package:estacao_meteorologica/login_page.dart';
import 'package:estacao_meteorologica/register_page.dart';
import 'package:estacao_meteorologica/registerlocal_page.dart';
import 'package:estacao_meteorologica/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:estacao_meteorologica/weatherstation_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<int> cards = [];
  Future<String?> getUserNameFromFirestore() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(currentUser.uid).get();
      return (userDoc.data() as Map<String, dynamic>)?['nome'];
    }
    return null;
  }
  Future<List<Map<String, dynamic>>> getDevicesFromFirestore() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    List<Map<String, dynamic>> devices = [];

    if (currentUser != null) {
      QuerySnapshot deviceSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(currentUser.uid)
          .collection('dispositivos')
          .get();

      for (var doc in deviceSnapshot.docs) {
        devices.add(doc.data() as Map<String, dynamic>);
      }
    }

    return devices;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF006D61),
        title: Center(
          child: SizedBox(
            width:100,
          ),
        ),

      ),

      body:  FutureBuilder<List<Map<String, dynamic>>>(
        future: getDevicesFromFirestore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar dispositivos.'));
            } else if (snapshot.hasData) {
              List<Map<String, dynamic>> devices = snapshot.data!;
              if (devices.isEmpty) {
                return Center(child: Text('Você não tem nenhum dispositivo registrado.'));
              }
              return ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      print('Card ${devices[index]['idDispositivo']} clicked');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WeatherStationPage(lugar: devices[index]['fazenda'],cidade: devices[index]['cidade'], dispositivo: devices[index]['idDispositivo'] ),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.all(10),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fazenda: ${devices[index]['fazenda']}',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF006D61)),
                            ),
                            Text('ID Dispositivo: ${devices[index]['idDispositivo']}'),
                            Text('Descrição: ${devices[index]['descricao']}'),
                            Text('Cidade: ${devices[index]['cidade']}'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          }
          return Center(child: CircularProgressIndicator()); // Exibe um spinner até os dispositivos serem carregados.
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => RegisterLocalPage()));
           // cards.add(cards.length);
          });
        },
        child: Icon(Icons.add),
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