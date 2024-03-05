
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:estacao_meteorologica/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthException implements Exception{
  String message;
  AuthException(this.message);
}

class AuthService extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;

  User? usuario;
  bool isLoading = true;

  AuthService() {
    _authCheck();
  }

  _authCheck() {
    UserProvider userProvider = UserProvider();
    _auth.authStateChanges().listen((User? user) {
      usuario = (user == null) ? null : user;
      isLoading = false;
      notifyListeners();
      userProvider.updateUser(user);
    });
  }

  _getUser() {
    usuario = _auth.currentUser;
    notifyListeners();
  }


  registrar(String email, String senha) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: senha);
      _getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthException('A senha é muito fraca!');
      } else if (e.code == 'email-already-in-use') {
        throw AuthException('Esse email já está cadastrado.');
      }
    }
  }

  login(String email, String senha) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
      _getUser();

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthException('Email não encontrado. Cadastre-se.');
      } else if (e.code == 'wrong-password') {
        throw AuthException('Senha incorreta. Tente novamente!');
      }
    }
  }

  logout() async {
    await _auth.signOut();
    _getUser();
  }


}

class UserProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  set currentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }
  void updateUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }
}

class WeatherProvider with ChangeNotifier {
  final String apiKey = '2c278f4af3bc0f46af4832996b54a6d8';
  Map<String, dynamic>? weatherData;

  Future<void> fetchWeather(String city) async {
    final response = await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey'));

    if (response.statusCode == 200) {
      weatherData = json.decode(response.body);
      notifyListeners();
    } else {
      throw Exception('Falha ao carregar dados do tempo');
    }
  }
}
