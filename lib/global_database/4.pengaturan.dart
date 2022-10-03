import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreamDataPengaturanProvider {
  final dataPengaturanStream = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get getStream => dataPengaturanStream.stream;

  Future<Map<String, dynamic>> dataPengaturanValue({required String viewOrEditDataPengaturan, Map<String, dynamic>? dataPengaturan}) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? stringMapDataPengaturan = sp.getString("dataPengaturan");

    Map<String, dynamic> mapDataPengaturan = Map<String, dynamic>.from(jsonDecode(stringMapDataPengaturan!));
    if (mapDataPengaturan.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 250), () {
        switch (viewOrEditDataPengaturan) {
          case "view":
            break;
          case "edit":
            sp.setString("dataPengaturan", jsonEncode(dataPengaturan));
            break;
        }
      });
      await Future.delayed(Duration.zero, () {
        if (viewOrEditDataPengaturan == "edit") {
          dataPengaturanStream.sink.add(dataPengaturan!);
        } else {
          dataPengaturanStream.sink.add(mapDataPengaturan);
        }
      });
    } else {
      await Future.delayed(Duration.zero, () {
        mapDataPengaturan = masterDataPengaturan;
        sp.setString("dataPengaturan", jsonEncode(mapDataPengaturan));
        dataPengaturanStream.sink.add(mapDataPengaturan);
      });
    }
    return mapDataPengaturan;
  }
}

Map<String, dynamic> masterDataPengaturan = {
  "namaSekolah": "",
  "headerBaris1": "",
  "headerBaris2": "",
  "alamat": "",
  "noTelepon": "",
  "website": "",
  "email": "",
  "namaKepsek": "",
  "nipKepsek": "",
  "warnaTemaAplikasi": 0,
  "photo_banner_path": "",
};

var streamDataPengaturanProvider = StreamDataPengaturanProvider();

List<MaterialColor> appThemeColorList = [
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.cyan,
  Colors.yellow,
  Colors.orange,
  Colors.indigo,
  Colors.purple,
];

List<Color> fontColor = [
  Colors.white,
  Colors.white,
  Colors.white,
  Colors.black,
  Colors.black,
  Colors.black,
  Colors.white,
  Colors.white,
];
