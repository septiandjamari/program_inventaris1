import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:program_inventaris/autentikasi/1.halaman_login.dart';
import 'package:program_inventaris/autentikasi/2.halaman_utama.dart';
import 'package:program_inventaris/autentikasi/auth_controller.dart';

class HalamanController extends StatefulWidget {
  const HalamanController({Key? key}) : super(key: key);

  @override
  State<HalamanController> createState() => _HalamanControllerState();
}

class _HalamanControllerState extends State<HalamanController> {
  @override
  void initState() {
    super.initState();
    loaduserDetail();
  }

  /*
  melakukan pendektesian keberadaan data jika
  telah dilakukan proses login sebelumnya
  */

  void loaduserDetail() async {
    String? userDetail;
    int? subLoginState;

    userDetail = await AuthController.loadUserDetail();
    setState(() {
      var mapUserDetail = jsonDecode(userDetail!);
      if (userDetail == "") {
        if (kDebugMode) {
          print("halaman login");
        }
        streamLoginState.logout();
      } else if (mapUserDetail["expire_session"] < DateTime.now().millisecondsSinceEpoch) {
        streamLoginState.logout();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text(
                "Session telah habis...Silahkan login kembali",
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.yellow.shade600),
        );
      } else {
        if (kDebugMode) {
          print(userDetail);
        }
        if (mapUserDetail["privileges"] == "admin" || mapUserDetail["privileges"] == "super_admin") {
          subLoginState = 1;
        } else if (mapUserDetail["privileges"] == "viewer") {
          subLoginState = 2;
        }
        if (kDebugMode) {
          print("login sebagai ${mapUserDetail["privileges"]}");
        }
        streamLoginState.login(userPrivilege: subLoginState!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<int>>(
        stream: streamLoginState.getStream,
        initialData: streamLoginState.loginState,
        builder: (context, snapshot) {
          int loginState = snapshot.data![0];
          return loginState == 0 ? const HalamanLogin() : const HalamanUtama();
        });
    //
  }
}

class HalamanUtamaController {
  final halamanContoller = StreamController<int>.broadcast();
  Stream<int> get getStream => halamanContoller.stream;
  int indexPage = 0;

  void changeIndex({required int index}) {
    if (kDebugMode) {
      print("ganti halaman index : $index");
    }
    indexPage = index;
    halamanContoller.sink.add(indexPage);
  }

  void dispose() {
    halamanContoller.close();
  }
}

var halamanUtamaController = HalamanUtamaController();
