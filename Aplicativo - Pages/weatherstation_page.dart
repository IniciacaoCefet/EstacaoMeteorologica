import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:estacao_meteorologica/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:estacao_meteorologica/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'GraphPage.dart';
import 'info_page.dart';
import 'login_page.dart';


class WeatherStationPage extends StatefulWidget {
  final String lugar;
  final String cidade;
  final String dispositivo;


  const WeatherStationPage({Key? key, required this.lugar, required this.cidade, required this.dispositivo}) : super(key: key);

  @override
  _WeatherStationPage createState() => _WeatherStationPage(lugar, cidade, dispositivo);
}

class _WeatherStationPage extends State<WeatherStationPage> {
  final String lugar;
  final String cidade;
  final String dispositivo;
  TextEditingController cityController = TextEditingController();
  Map<String, dynamic>? dadosSensor;
  Map<String, dynamic>? forecastData;
  Map<String, double> dailyMinTemperature = {};
  Map<String, double> dailyMaxTemperature = {};



  _WeatherStationPage(this.lugar, this.cidade, this.dispositivo);

  Future<String?> getUserNameFromFirestore() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(currentUser.uid).get();
      return (userDoc.data() as Map<String, dynamic>)?['nome'];
    }
    return null;
  }
  Future<Map<String, dynamic>> buscarDadosDispositivo() async {
    FirebaseFirestore _db = FirebaseFirestore.instance; // Modifique esta linha
    DocumentSnapshot doc = await _db.collection('dispositivos').doc(dispositivo).get(); // Use 'dispositivo' em vez de 'dispositivoId'

    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    } else {
      throw Exception('Dispositivo não encontrado');
    }
  }
  Future<Map<String, dynamic>> buscarDadosMaisRecentesSensor() async {
    FirebaseFirestore _db = FirebaseFirestore.instance;

    // Consultando a coleção `registro` dentro de `dispositivo` pelo documento mais recente
    QuerySnapshot resultado = await _db
        .collection('sensorData')
        .doc(widget.dispositivo)
        .collection('registros')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    // Se houver um resultado, retorna os dados do primeiro (e único) documento.
    // Caso contrário, retorna um mapa vazio.
    if (resultado.docs.isNotEmpty) {
      return resultado.docs.first.data() as Map<String, dynamic>;
    } else {
      return {};
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
    _carregarDadosSensor();
  }
  void _carregarDadosSensor() async {
    dadosSensor = await buscarDadosMaisRecentesSensor();
    setState(() {});
  }

  fetchWeatherData() async {
    await context.read<WeatherProvider>().fetchWeather(widget.cidade);
    setState(() {
      forecastData = context.read<WeatherProvider>().weatherData;
    });
    forecastData = context.read<WeatherProvider>().weatherData as Map<String, dynamic>;
  }
  IconData getWeatherIcon(String? description) {
    print("Description received: $description");

    // Caso a descrição seja nula
    if (description == null) {
      print("Description is null");
      return FontAwesomeIcons.sun; // Ícone de aviso
    }

    // Tratando a descrição: removendo espaços extras e convertendo para minúsculas
    description = description.trim().toLowerCase();

    print("Treated description: $description");

    // Checando a descrição tratada e determinando o ícone
    if (description.contains('rain')) {
      print("Returning cloudRain icon");
      return FontAwesomeIcons.cloudRain;
    } else if (description.contains('clear')) {
      print("Returning sun icon");
      return FontAwesomeIcons.sun;
    } else if (description.contains('cloudy') || description.contains('overcast')) {
      print("Returning cloud icon");
      return FontAwesomeIcons.cloud;
    } else if (description.contains('thunderstorm')) {
      print("Returning bolt icon");
      return FontAwesomeIcons.bolt;
    } else {
      // Se nenhuma das condições anteriores for verdadeira, retornamos um ícone padrão
      print("Returning default cloud icon");
      return FontAwesomeIcons.cloud;
    }
  }
  @override

  Widget build(BuildContext context) {

    if (forecastData == null) {
      return CircularProgressIndicator();
    }

    var daily = forecastData!['list'] as List;
    Map<String, double> dailyRain = {};


    for (var data in daily) {
      String dateStr = data['dt_txt'] as String;

      try {
        DateTime dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateStr);
        String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);

        var rain = (data['rain']?['3h'] ?? 0.0) as double;
        var tempMin = ((data['main']['temp_min'] ?? 0.0) as double) - 273.15;
        var tempMax = ((data['main']['temp_max'] ?? 0.0) as double) - 273.15;


        // Processing Rain Data
        if (dailyRain.containsKey(formattedDate)) {
          dailyRain[formattedDate] = (dailyRain[formattedDate]?? 0.0) + rain;
        } else {
          dailyRain[formattedDate] = rain;
        }

        // Processing Min Temperature Data
        if (!dailyMinTemperature.containsKey(formattedDate) || dailyMinTemperature[formattedDate]! > tempMin) {
          dailyMinTemperature[formattedDate] = tempMin;
        }

        // Processing Max Temperature Data
        if (!dailyMaxTemperature.containsKey(formattedDate) || dailyMaxTemperature[formattedDate]! < tempMax) {
          dailyMaxTemperature[formattedDate] = tempMax;
        }

      } catch (error) {
        print("Erro ao processar data: $dateStr, Erro: $error");
      }
    }
    print("Keys in dailyRain: ${dailyRain.keys.toList()}");
    dailyRain.forEach((key, value) {
      print("Date: $key, Rain: $value");
    });

    Map<String, dynamic> getDataForDate(String date) {
      return daily.firstWhere(
              (element) => element['dt_txt'].contains(date),
          orElse: () => <String, dynamic>{}
      );
    }


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF006D61),
        title: Text(widget.lugar, style: TextStyle(color: Colors.white)),
      ),

      body:Center(
          child: Column(

          children: [

            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[

                  Container(
                    margin: EdgeInsets.fromLTRB(20.0,0, 20.0, 0),
                    height: 40.0,  // Define a altura desejadaheight: 40.0,  // Define a altura desejada
                    alignment: Alignment.center,
                    child: Text('PREVISÃO - GOOGLE',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF006D61 ),)),
                  ),
                  Image.asset('assets/openweather_logo.png', width: 100, height: 25),
                ]


            ),
            Divider(
              color: Colors.black,  // Define a cor do Divider. Por padrão, é uma linha cinza.
              thickness: 1.0,      // Define a espessura do Divider. Por padrão, é 1.0.
              height: 20.0,        // Define a altura total do widget Divider, incluindo o espaço acima e abaixo da linha.
            ),
            CarouselSlider(
              options: CarouselOptions(
                viewportFraction: 0.33,
                height: 150.0,
                enlargeCenterPage: false,
                autoPlay: true,
              ),
              items: dailyRain.keys.map((formattedDate) {
                var dataForDate = getDataForDate(formattedDate);
                String? description;
                if (dataForDate['weather'] != null && dataForDate['weather'] is List && (dataForDate['weather'] as List).isNotEmpty) {
                  description = dataForDate['weather'][0]['description'];
                } else {
                  print("Weather data missing or in unexpected format: ${dataForDate['weather']}");
                }
                return Builder(

                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),

                      child: Column(
                        children: <Widget>[
                          Text(formattedDate), // Mostra a data formatada
                          SizedBox(height: 10),
                            Icon(
                              getWeatherIcon(description),
                              size: 25.0,
                              color: Color(0xFF006D61),
                            ),
                          SizedBox(height: 10),
                          Text('${(dailyRain[formattedDate] ?? 0.0).toStringAsFixed(2)}mm'),
                          SizedBox(height: 10),
                          Text('Min: ${dailyMinTemperature[formattedDate]?.toStringAsFixed(2) ?? "N/A"}°C'),
                          Text('Max: ${dailyMaxTemperature[formattedDate]?.toStringAsFixed(2) ?? "N/A"}°C'),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),


            Divider(
              color: Colors.black,  // Define a cor do Divider. Por padrão, é uma linha cinza.
              thickness: 1.0,      // Define a espessura do Divider. Por padrão, é 1.0.
              height: 20.0,        // Define a altura total do widget Divider, incluindo o espaço acima e abaixo da linha.
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(20.0,0, 20.0, 0),
                    height: 30.0,  // Define a altura desejadaheight: 40.0,  // Define a altura desejada
                    alignment: Alignment.center,
                    child: Text('CONDIÇÃO CLIMÁTICA LOCAL',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF006D61 ),)),
                  ),

                ]


            ),
            Divider(
              color: Colors.black,  // Define a cor do Divider. Por padrão, é uma linha cinza.
              thickness: 1.0,      // Define a espessura do Divider. Por padrão, é 1.0.
              height: 20.0,        // Define a altura total do widget Divider, incluindo o espaço acima e abaixo da linha.
            ),
            Row(

              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[

                // Primeira coluna
                Column(
                  children: <Widget>[
                    Text('Temperatura'),
                    SizedBox(height: 10),
                    Icon(FontAwesomeIcons.thermometer0, size: 25.0, color: Color(0xFF006D61 ),),
                    SizedBox(height: 10),
                    Text(dadosSensor?['temperatura']?.toString() ?? "N/A"),
                    SizedBox(height: 10),
                  ],
                ),
                // Segunda coluna
                Column(
                  children: <Widget>[
                    Text('Vento'),
                    SizedBox(height: 10),
                    Icon(FontAwesomeIcons.wind, size: 25.0, color: Color(0xFF006D61 ),),
                    SizedBox(height: 10),
                    Text(dadosSensor?['velocidadeVento']?.toString() ?? "N/A"),
                  ],
                ),
                // Terceira coluna
                Column(
                  children: <Widget>[
                    Text('Umidade do Ar'),
                    SizedBox(height: 10),
                    Icon(FontAwesomeIcons.droplet, size: 25.0, color: Color(0xFF006D61 ),),
                    SizedBox(height: 10),
                    Text(dadosSensor?['umidade']?.toString() ?? "N/A"),

                  ],
                ),

              ],
            ),
            Row(

              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[

                // Primeira coluna
                Column(
                  children: <Widget>[
                    Text('Umidade Solo'),
                    SizedBox(height: 10),
                    Icon(FontAwesomeIcons.sunPlantWilt, size: 25.0, color: Color(0xFF006D61 ),),
                    SizedBox(height: 10),
                    Text(dadosSensor?['umidadeSolo']?.toString() ?? "N/A"),
                    SizedBox(height: 10),
                  ],
                ),
                // Segunda coluna
                Column(
                  children: <Widget>[
                    Text('Chuva'),
                    SizedBox(height: 10),
                    Icon(FontAwesomeIcons.cloudRain, size: 25.0, color: Color(0xFF006D61 ),),
                    SizedBox(height: 10),
                    Text(dadosSensor?['precipitacaoChuva']?.toString() ?? "N/A"),
                  ],
                ),
                // Terceira coluna
                Column(
                  children: <Widget>[
                    Text('Pressão'),
                    SizedBox(height: 10),
                    Icon(FontAwesomeIcons.crosshairs, size: 25.0, color: Color(0xFF006D61 ),),
                    SizedBox(height: 10),
                    Text(dadosSensor?['pressaoAtmosferica']?.toString() ?? "N/A"),

                  ],
                ),

              ],
            ),
            Divider(
              color: Colors.black,  // Define a cor do Divider. Por padrão, é uma linha cinza.
              thickness: 1.0,      // Define a espessura do Divider. Por padrão, é 1.0.
              height: 20.0,        // Define a altura total do widget Divider, incluindo o espaço acima e abaixo da linha.
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(20.0,0, 20.0, 0),
                    height: 30.0,  // Define a altura desejadaheight: 40.0,  // Define a altura desejada
                    alignment: Alignment.center,
                    child: Text('RELATÓRIO DOS REGISTROS',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF006D61 ),)),
                  ),

                ]


            ),
            Divider(
              color: Colors.black,  // Define a cor do Divider. Por padrão, é uma linha cinza.
              thickness: 1.0,      // Define a espessura do Divider. Por padrão, é 1.0.
              height: 20.0,        // Define a altura total do widget Divider, incluindo o espaço acima e abaixo da linha.
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GraphPage(),),);
                    // Coloque aqui a ação que você quer realizar ao clicar no card
                    print('Card foi clicado!');
                  },
                  child: Card(
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text('Gráficos', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color(0xFF006D61 ),)),
                          SizedBox(height: 10.0),
                          Icon(FontAwesomeIcons.chartLine, size: 50.0, color: Color(0xFF006D61 ),),
                        ],
                      ),
                    ),
                  ),
                ),

              ],
            ),
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
}