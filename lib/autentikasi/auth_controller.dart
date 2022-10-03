import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:program_inventaris/autentikasi/0.halaman_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  static void login({required String mapUser, required int userPrivilege}) async {
    if (kDebugMode) {
      print("login cuy");
    }
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("userDetail", mapUser);
    streamLoginState.login(userPrivilege: userPrivilege);
  }

  static void logout() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("userDetail", "");
    streamLoginState.logout();
  }

  static Future<String?> loadUserDetail() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? refreshToken = sp.getString("userDetail");
    return refreshToken;
  }
}

class StreamLoginState {
  final loginStateStream = StreamController<List<int>>.broadcast();

  Stream<List<int>> get getStream => loginStateStream.stream;
  List<int> loginState = [0, 0];

  void login({required int userPrivilege}) {
    loginState = [1, userPrivilege];
    if (kDebugMode) {
      print("loginState : $loginState");
    }
    loginStateStream.sink.add(loginState);
  }

  void logout() {
    loginState = [0, 0];
    halamanUtamaController.changeIndex(index: 0);
    loginStateStream.sink.add(loginState);
  }

  void dispose() {
    loginStateStream.close();
  }
}

var streamLoginState = StreamLoginState();
