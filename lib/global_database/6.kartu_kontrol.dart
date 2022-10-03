import 'dart:async';
import 'dart:convert';

// import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DBKartuKontrol {
  final dbKartuKontrolStream = StreamController<List<Map<String, dynamic>>>.broadcast();
  Stream<List<Map<String, dynamic>>> get getStream => dbKartuKontrolStream.stream;
  Future<List<Map<String, dynamic>>> dbKartuKontrol({required String aksi, Map<String, dynamic>? data, String? kodeBarang}) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? stringListKartuKontrol = sp.getString("listKartuKontrol");
    List<Map<String, dynamic>> listKartuKontrol = [];
    List<Map<String, dynamic>> listKartuKontrol1 = [];
    if (stringListKartuKontrol == null) {
      sp.setString("listKartuKontrol", jsonEncode(initListKartuKontrol));
      listKartuKontrol = initListKartuKontrol;
    } else {
      listKartuKontrol = List<Map<String, dynamic>>.from(jsonDecode(stringListKartuKontrol));
    }
    await Future.delayed(Duration.zero, () {
      switch (aksi) {
        case 'list':
          break;
        case 'tambah':
          listKartuKontrol.insert(0, data!);
          sp.setString("listKartuKontrol", jsonEncode(listKartuKontrol));
          break;
      }
    });
    await Future.delayed(Duration.zero, () {
      for (var element in listKartuKontrol) {
        if (element['kode_barang'] == kodeBarang) {
          listKartuKontrol1.add(element);
        }
      }
    });
    if (kDebugMode) {
      print('return $listKartuKontrol1');
    }
    listKartuKontrol1.sort(
      (b, a) {
        return a['tanggal'].compareTo(b['tanggal']);
      },
    );
    dbKartuKontrolStream.sink.add(listKartuKontrol1);
    return listKartuKontrol1;
  }
}

List<Map<String, dynamic>> initListKartuKontrol = [
  {
    'nomer_kontrol': '112211',
    'tanggal': 1662595200000,
    'kode_barang': '20220507-2',
    'kondisi': 'Baik',
    'keterangan': '',
  },
  {
    'nomer_kontrol': '112233',
    'tanggal': 1662595200000,
    'kode_barang': '20220507-2',
    'kondisi': 'Baik',
    'keterangan': '',
  },
  {
    'nomer_kontrol': '112244',
    'tanggal': 1662595200000,
    'kode_barang': '20220507-2',
    'kondisi': 'Baik',
    'keterangan': '',
  },
  {
    'nomer_kontrol': '113355',
    'tanggal': 1662595200000,
    'kode_barang': '20220507-2',
    'kondisi': 'Baik',
    'keterangan': '',
  }
];

var dbKartuKontrol = DBKartuKontrol();
