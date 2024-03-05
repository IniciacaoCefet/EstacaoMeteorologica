import 'package:estacao_meteorologica/register_page.dart';
import 'package:estacao_meteorologica/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'info_page.dart';
import 'login_page.dart';

class GraphPage extends StatefulWidget {
  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  DateTime? startDate;
  DateTime? endDate;
  List<Map<String, dynamic>> sensorData = [];

  Future<String?> getUserNameFromFirestore() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(currentUser.uid).get();
      return (userDoc.data() as Map<String, dynamic>)?['nome'];
    }
    return null;
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFF006D61),
            colorScheme: ColorScheme.light(primary: Color(0xFF006D61)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF006D61),
        title: Text("Gráficos dos Sensores"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    startDate = await _selectDate(context);
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF006D61),
                  ),
                  child: Text("Data Inicial"),
                ),
                SizedBox(width: 16),
                Text(startDate?.toIso8601String() ?? "Selecione uma data"),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    endDate = await _selectDate(context);
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF006D61),
                  ),
                  child: Text("Data Final"),
                ),
                SizedBox(width: 16),
                Text(endDate?.toIso8601String() ?? "Selecione uma data"),
              ],
            ),
            ElevatedButton(
              onPressed: _fetchSensorData,
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF006D61),
              ),
              child: Text("Buscar Dados"),
            ),
            Expanded(child: _buildGraphs()),
          ],
        ),
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

  Widget _buildGraphs() {
    if (sensorData.isEmpty) return Text("Nenhum dado disponível.");
    return ListView(
      children: [
        _buildLineChart('Temperatura', 'temperatura', Colors.red),
        _buildLineChart('Umidade', 'umidade', Colors.blue),
        _buildLineChart('Velocidade do Vento', 'velocidadeVento', Colors.green),
        _buildLineChart('Umidade do Solo', 'umidadeSolo', Colors.purple),
        _buildLineChart('Precipitação de Chuva', 'precipitacaoChuva', Colors.cyan),
      ],
    );
  }

  Widget _buildLineChart(String title, String field, Color color) {
    List<double> values = [];
    for (var data in sensorData) {
      if (data[field] is num) {
        values.add((data[field] as num).toDouble());
      } else {
        print("ERROR: Value for field $field is not a number: ${data[field]}");
        return Text("Erro nos dados para o campo $field");
      }
    }
    double minY = values.reduce((a, b) => a < b ? a : b);
    double maxY = values.reduce((a, b) => a > b ? a : b);

    return Container(
      height: 250,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0), // Aumentar o espaço entre o título e o gráfico
                child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              Expanded(
                child: LineChart(LineChartData(
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: SideTitles(showTitles: true),
                    bottomTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitles: (value) {
                        if (value % (sensorData.length / 5) == 0 && value < sensorData.length) { // Mostrar etiquetas para um quinto dos pontos de dados para evitar sobreposição
                          return value.toString();
                        }
                        return '';
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: sensorData.length.toDouble(),
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: sensorData.map((data) => FlSpot(sensorData.indexOf(data).toDouble(), (data[field] as num).toDouble())).toList(),
                      colors: [color],
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                      isCurved: true,
                      barWidth: 4,
                      isStrokeCapRound: true,
                    ),
                  ],
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _fetchSensorData() async {
    if (startDate != null && endDate != null) {
      FirebaseFirestore _db = FirebaseFirestore.instance;
      QuerySnapshot resultado = await _db
          .collection('sensorData')
          .doc("ESP32_Device1") // Substitua "seu_dispositivo" pelo seu dispositivo se necessário
          .collection('registros')
          .where('timestamp', isGreaterThanOrEqualTo: startDate, isLessThan: endDate)
          .get();
      print("Documentos retornados: ${resultado.docs.length}");
      setState(() {
        sensorData = resultado.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Erro"),
          content: Text("Selecione ambas as datas antes de buscar os dados."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Fechar"),
            ),
          ],
        ),
      );
    }
  }
}