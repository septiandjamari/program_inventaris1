import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreamMasterLokasiProvider {
  final masterLokasiStream = StreamController<List<Map<String, dynamic>>>.broadcast();
  Stream<List<Map<String, dynamic>>> get getStream => masterLokasiStream.stream;

  Future<List<Map<String, dynamic>>> masterLokasiValue({
    required String addEditDeleteViewListMasterLokasi,
    Map<String, dynamic>? dataMasterLokasi,
    String? kodeLokasi,
  }) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? stringlistMasterLokasi = sp.getString("listMasterLokasi");
    List<Map<String, dynamic>> listSelected = [];
    List<Map<String, dynamic>> listMasterLokasi = List<Map<String, dynamic>>.from(jsonDecode(stringlistMasterLokasi!));
    if (listMasterLokasi.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 250), () {
        switch (addEditDeleteViewListMasterLokasi) {
          case "select":
            listSelected.add(listMasterLokasi.firstWhere((element) => element["kodeLokasi"] == kodeLokasi));
            break;
          case "add":
            listMasterLokasi.insert(0, dataMasterLokasi!);
            sp.setString("listMasterLokasi", jsonEncode(listMasterLokasi));
            break;
          case "edit":
            int index = listMasterLokasi.indexWhere((element) => element["kodeLokasi"] == kodeLokasi);
            listMasterLokasi[index] = dataMasterLokasi!;
            sp.setString("listMasterLokasi", jsonEncode(listMasterLokasi));
            break;
          case "delete":
            listMasterLokasi.removeWhere((element) => element["kodeLokasi"] == dataMasterLokasi);
            sp.setString("listMasterLokasi", jsonEncode(listMasterLokasi));
            break;
          case "list":
            break;
        }
      });
      await Future.delayed(Duration.zero, () {
        if (addEditDeleteViewListMasterLokasi != "select") {
          masterLokasiStream.sink.add(listMasterLokasi);
        } else {
          listMasterLokasi = listSelected;
        }
      });
    } else {
      await Future.delayed(Duration.zero, () {
        listMasterLokasi = masterLokasiList;
        sp.setString("listMasterLokasi", jsonEncode(listMasterLokasi));
        masterLokasiStream.sink.add(listMasterLokasi);
      });
    }
    if (kDebugMode) {
      print("length listMasterLokasi after : ${listMasterLokasi.length}");
    }
    return listMasterLokasi;
  }

  Future<Map<String, dynamic>> selectLokasi({required String kodeLokasi}) async {
    List<Map<String, dynamic>> listValue = await masterLokasiValue(addEditDeleteViewListMasterLokasi: "select", kodeLokasi: kodeLokasi);
    return listValue[0];
  }

  void addDataLokasi({required Map<String, dynamic> dataMasterLokasi}) {
    masterLokasiValue(addEditDeleteViewListMasterLokasi: "add", dataMasterLokasi: dataMasterLokasi);
  }

  void editDataLokasi({required Map<String, dynamic> dataMasterLokasi, required String kodeLokasi}) {
    masterLokasiValue(addEditDeleteViewListMasterLokasi: "edit", dataMasterLokasi: dataMasterLokasi, kodeLokasi: kodeLokasi);
  }

  void delete({required String kodeLokasi}) {
    masterLokasiValue(addEditDeleteViewListMasterLokasi: "delete", kodeLokasi: kodeLokasi);
  }

  void dispose() {
    masterLokasiStream.close();
  }
}

var streamMasterLokasiProvider = StreamMasterLokasiProvider();

List<Map<String, dynamic>> masterLokasiList = [
  {
    "kodeLokasi": "Lokasi-42308",
    "namaLokasi": "Ruang Satpam",
    "keterangan": "Bangunan Barat",
  },
  {
    "kodeLokasi": "Lokasi-47655",
    "namaLokasi": "Ruang BK",
    "keterangan": "Bangunan Selatan",
  },
  {
    "kodeLokasi": "Lokasi-32142",
    "namaLokasi": "Ruang UKS",
    "keterangan": "Bangunan Selatan",
  },
  {
    "kodeLokasi": "Lokasi-0113",
    "namaLokasi": "Ruang Guru",
    "keterangan": "Bangunan Selatan",
  },
  {
    "kodeLokasi": "Lokasi-0191",
    "namaLokasi": "Perpustakaan",
    "keterangan": "Bangunan Timur",
  },
  {
    "kodeLokasi": "Lokasi-0254",
    "namaLokasi": "Ruang BK",
    "keterangan": "Bangunan Timur",
  },
  {
    "kodeLokasi": "Lokasi-1009",
    "namaLokasi": "Ruang TU",
    "keterangan": "Bangunan Timur",
  },
  {
    "kodeLokasi": "Lokasi-1101",
    "namaLokasi": "Ruang Adiwiyata",
    "keterangan": "Bangunan Timur",
  },
  {
    "kodeLokasi": "Lokasi-4378",
    "namaLokasi": "Ruang Kelas VII A",
    "keterangan": "",
  },
  {
    "kodeLokasi": "Lokasi-0999",
    "namaLokasi": "Ruang Kelas VII B",
    "keterangan": "",
  },
  {
    "kodeLokasi": "Lokasi-1243",
    "namaLokasi": "Ruang Kelas VII C",
    "keterangan": "",
  },
  {
    "kodeLokasi": "Lokasi-4356",
    "namaLokasi": "Ruang Kelas VII D",
    "keterangan": "",
  },
  {
    "kodeLokasi": "Lokasi-7635",
    "namaLokasi": "Ruang Kelas VIII A",
    "keterangan": "",
  },
  {
    "kodeLokasi": "Lokasi-9062",
    "namaLokasi": "Ruang Kelas VIII B",
    "keterangan": "",
  },
  {
    "kodeLokasi": "Lokasi-1237",
    "namaLokasi": "Ruang Kelas VIII C",
    "keterangan": "",
  },
  {
    "kodeLokasi": "Lokasi-4583",
    "namaLokasi": "Ruang Kelas VIII D",
    "keterangan": "",
  },
  {
    "kodeLokasi": "Lokasi-5487",
    "namaLokasi": "Ruang Kelas IX A",
    "keterangan": "",
  },
  {
    "kodeLokasi": "Lokasi-6453",
    "namaLokasi": "Ruang Kelas IX B",
    "keterangan": "",
  },
  {
    "kodeLokasi": "Lokasi-2348",
    "namaLokasi": "Ruang Kelas IX C",
    "keterangan": "",
  },
  {
    "kodeLokasi": "Lokasi-3489",
    "namaLokasi": "Ruang Kelas IX D",
    "keterangan": "",
  },
];
