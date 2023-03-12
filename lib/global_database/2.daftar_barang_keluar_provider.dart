import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreamDaftarBarangKeluarProvider {
  final daftarBarangKeluarStream = StreamController<List<Map<String, dynamic>>>.broadcast();
  Stream<List<Map<String, dynamic>>> get getStream => daftarBarangKeluarStream.stream;

  Future<List<Map<String, dynamic>>> daftarBarangKeluarValue({
    required String addEditDeleteView,
    Map<String, dynamic>? data,
    String? kodeForm,
    String? kodeBarang,
  }) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? stringlistBarangKeluar = sp.getString("listBarangKeluar");
    List<Map<String, dynamic>> listBarangKeluar = List<Map<String, dynamic>>.from(jsonDecode(stringlistBarangKeluar!));
    // if (listBarangKeluar.isNotEmpty) {
    List<Map<String, dynamic>> listSelected = [];
    await Future.delayed(const Duration(milliseconds: 250), () {
      switch (addEditDeleteView) {
        case "select":
          listSelected.add(listBarangKeluar.firstWhere((element) => element["id_form"] == kodeForm));
          break;
        case "listBarangKeluarByKodeBarang":
          try {
            listSelected.add(listBarangKeluar.firstWhere((element) => element["id_barang"] == kodeBarang));
            listSelected.sort((a, b) => b["dt_barang_keluar_diedit"].compareTo(a["dt_barang_keluar_diedit"]));
          } catch (e) {
            listSelected = [];
          }
          break;
        case "add":
          listBarangKeluar.insert(0, data!);
          sp.setString("listBarangKeluar", jsonEncode(listBarangKeluar));
          break;
        case "edit":
          int index = listBarangKeluar.indexWhere((element) => element["id_form"] == kodeForm);
          listBarangKeluar[index] = data!;
          sp.setString("listBarangKeluar", jsonEncode(listBarangKeluar));
          break;
        case "delete":
          listBarangKeluar.removeWhere((element) => element["id_form"] == kodeForm);
          sp.setString("listBarangKeluar", jsonEncode(listBarangKeluar));
          break;
        case "list":
          break;
      }
    });
    await Future.delayed(Duration.zero, () {
      if (addEditDeleteView != "select" || addEditDeleteView != "listBarangKeluarByKodeBarang") {
        daftarBarangKeluarStream.sink.add(listBarangKeluar);
      } else {
        listBarangKeluar = listSelected;
      }
    });
    // } else {
    //   await Future.delayed(Duration.zero, () {
    //     listBarangKeluar = masterlistBarangKeluar;
    //     sp.setString("listBarangKeluar", jsonEncode(listBarangKeluar));
    //     daftarBarangKeluarStream.sink.add(listBarangKeluar);
    //   });
    // }
    if (kDebugMode) {
      print("length listBarangKeluar after : ${listBarangKeluar.length}");
    }
    return listBarangKeluar;
  }

  Future<Map<String, dynamic>> selectDataBarangKeluar({required String idForm}) async {
    List<Map<String, dynamic>> listValue = await daftarBarangKeluarValue(addEditDeleteView: "select", kodeForm: idForm);
    return listValue[0];
  }

  void addDataBarangKeluar({required Map<String, dynamic> dataBarang}) {
    daftarBarangKeluarValue(addEditDeleteView: "add", data: dataBarang);
  }

  void editDataBarangKeluar({required Map<String, dynamic> dataBarang, required String kodeForm}) {
    daftarBarangKeluarValue(addEditDeleteView: "edit", data: dataBarang, kodeForm: kodeForm);
  }

  void delete({required String kodeForm}) {
    daftarBarangKeluarValue(addEditDeleteView: "delete", kodeForm: kodeForm);
  }

  void dispose() {
    daftarBarangKeluarStream.close();
  }
}

var streamDaftarBarangKeluarProvider = StreamDaftarBarangKeluarProvider();

List<Map<String, dynamic>> masterlistBarangKeluar = [
  {
    "dt_barang_keluar": 1662508800000,
    "dt_barang_keluar_diedit": 1662595200000,
    "id_form": "21722938",
    "id_barang": "20220513-1",
    "id_lokasi_terakhir": "Lokasi-0191",
    "keterangan": "",
    "dikembalikan": true,
    "tanggal_pengembalian": 1662595200000,
  },
  {
    "dt_barang_keluar": 1662508800000,
    "dt_barang_keluar_diedit": 1662595200000,
    "id_form": "21722938",
    "id_barang": "20220507-2",
    "id_lokasi_terakhir": "Lokasi-0191",
    "keterangan": "",
    "dikembalikan": true,
    "tanggal_pengembalian": 1662595200000,
  },
  {
    "dt_barang_keluar": 1662508800000,
    "dt_barang_keluar_diedit": 1662595200000,
    "id_form": "21722939",
    "id_barang": "20220513-2",
    "id_lokasi_terakhir": "Lokasi-0191",
    "keterangan": "",
    "dikembalikan": false,
    "tanggal_pengembalian": 1662595200000,
  },
  {
    "dt_barang_keluar": 1662508800000,
    "dt_barang_keluar_diedit": 1662595200000,
    "id_form": "21722940",
    "id_barang": "20220513-3",
    "id_lokasi_terakhir": "Lokasi-0191",
    "keterangan": "",
    "dikembalikan": false,
    "tanggal_pengembalian": 1662595200000,
  },
];
