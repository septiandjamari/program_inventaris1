import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StreamDaftarItemBarangProvider {
  final daftarItemBarangStream = StreamController<List<Map<String, dynamic>>>.broadcast();
  Stream<List<Map<String, dynamic>>> get getStream => daftarItemBarangStream.stream;
  Future<List<Map<String, dynamic>>> daftarItemBarangValue(
      {required String addEditDeleteViewListDaftarBarang, Map<String, dynamic>? dataBarang, String? kodeItem}) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? stringlistItemBarang = sp.getString("listItemBarang");

    List<Map<String, dynamic>> listItemBarang = List<Map<String, dynamic>>.from(jsonDecode(stringlistItemBarang!));
    // if (listItemBarang.isNotEmpty) {
    List<Map<String, dynamic>> listSelected = [];
    await Future.delayed(const Duration(milliseconds: 250), () {
      switch (addEditDeleteViewListDaftarBarang) {
        case "select":
          for (var element in listItemBarang) {
            if (element['kodeitem'] == kodeItem) {
              listSelected.add(listItemBarang.firstWhere((element) => element["kodeitem"] == kodeItem));
              break;
            }
          }
          if (listSelected.isEmpty) {
            listSelected = [{}];
          }
          break;
        case "add":
          listItemBarang.insert(0, dataBarang!);
          sp.setString("listItemBarang", jsonEncode(listItemBarang));
          break;
        case "edit":
          int index = listItemBarang.indexWhere((element) => element["kodeitem"] == kodeItem);
          listItemBarang[index] = dataBarang!;
          sp.setString("listItemBarang", jsonEncode(listItemBarang));
          break;
        case "delete":
          listItemBarang.removeWhere((element) => element["kodeItem"] == kodeItem);
          sp.setString("listItemBarang", jsonEncode(listItemBarang));
          break;
        case "list":
          break;
      }
    });
    await Future.delayed(Duration.zero, () {
      if (addEditDeleteViewListDaftarBarang != "select") {
        daftarItemBarangStream.sink.add(listItemBarang);
      } else {
        listItemBarang = listSelected;
      }
    });
    // }
    // else {
    //   await Future.delayed(Duration.zero, () {
    //     listItemBarang = masterListItemBarang;
    //     sp.setString("listItemBarang", jsonEncode(listItemBarang));
    //     daftarItemBarangStream.sink.add(listItemBarang);
    //   });
    // }

    return listItemBarang;
  }

  Future<Map<String, dynamic>> selectDataBarang({required String kodeItem}) async {
    List<Map<String, dynamic>> listValue = await daftarItemBarangValue(addEditDeleteViewListDaftarBarang: "select", kodeItem: kodeItem);
    return listValue[0];
  }

  void addDataBarang({required Map<String, dynamic> dataBarang}) {
    daftarItemBarangValue(addEditDeleteViewListDaftarBarang: "add", dataBarang: dataBarang);
  }

  void editDataBarang({required Map<String, dynamic> dataBarang, required String kodeItem}) {
    daftarItemBarangValue(addEditDeleteViewListDaftarBarang: "edit", dataBarang: dataBarang, kodeItem: kodeItem);
  }

  void delete({required String kodeItem}) {
    daftarItemBarangValue(addEditDeleteViewListDaftarBarang: "delete", kodeItem: kodeItem);
  }

  void dispose() {
    daftarItemBarangStream.close();
  }
}

var streamDaftarItemBarangProvider = StreamDaftarItemBarangProvider();

List<Map<String, dynamic>> masterListItemBarang = [
  {
    "dt_barang_masuk": 1662508800000,
    "dt_barang_masuk_diedit": 1662595200000,
    "kodeitem": "20220505-1",
    "kondisi": "Baik",
    "kodeLokasi": "Lokasi-0113",
    "jenisOrnamaBarang": "Access Point",
    "merkOrtipe": "TS-220",
    "kategori": "Elektronik",
    "ukuran": "20 x 10 x 1.5",
    "bahan": "Plastik",
    "satuan": "Buah",
    "tahunPembelian": "2018",
    "pabrik": "Unify",
    "rangka": "",
    "mesin": "",
    "noPolisi": "",
    "bpkb": "",
    "asalUsul": "",
    "harga": "",
    "sumberDana": "Dana KEMDIKBUD",
    "keterangan": "",
  },
  {
    "dt_barang_masuk": 1662508800000,
    "dt_barang_masuk_diedit": 1662595200000,
    "kodeitem": "20220505-2",
    "kondisi": "Baik",
    "kodeLokasi": "Lokasi-0113",
    "jenisOrnamaBarang": "Access Point",
    "merkOrtipe": "TS-220",
    "kategori": "Elektronik",
    "ukuran": "20 x 10 x 1.5",
    "bahan": "Plastik",
    "satuan": "Buah",
    "tahunPembelian": "2018",
    "pabrik": "Unify",
    "rangka": "",
    "mesin": "",
    "noPolisi": "",
    "bpkb": "",
    "asalUsul": "",
    "harga": "",
    "sumberDana": "Dana KEMDIKBUD",
    "keterangan": "",
  },
  {
    "dt_barang_masuk": 1662508800000,
    "dt_barang_masuk_diedit": 1662595200000,
    "kodeitem": "20220507-1",
    "kondisi": "Baik",
    "kodeLokasi": "Lokasi-0113",
    "jenisOrnamaBarang": "Access Point",
    "merkOrtipe": "SM-640 Max",
    "kategori": "Elektronik",
    "ukuran": "20 x 10 x 1.5",
    "bahan": "Plastik",
    "satuan": "Buah",
    "tahunPembelian": "2015",
    "pabrik": "Unify",
    "rangka": "",
    "mesin": "",
    "noPolisi": "",
    "bpkb": "",
    "asalUsul": "",
    "harga": "",
    "sumberDana": "Dana KEMDIKBUD",
    "keterangan": "",
  },
  {
    "dt_barang_masuk": 1662508800000,
    "dt_barang_masuk_diedit": 1662595200000,
    "kodeitem": "20220507-2",
    "kondisi": "Baik",
    "kodeLokasi": "Lokasi-0113",
    "jenisOrnamaBarang": "Access Point",
    "merkOrtipe": "SM-640 Max",
    "kategori": "Elektronik",
    "ukuran": "20 x 10 x 1.5",
    "bahan": "Plastik",
    "satuan": "Buah",
    "tahunPembelian": "2015",
    "pabrik": "Unify",
    "rangka": "",
    "mesin": "",
    "noPolisi": "",
    "bpkb": "",
    "asalUsul": "",
    "harga": "",
    "sumberDana": "Dana KEMDIKBUD",
    "keterangan": "",
  },
  {
    "dt_barang_masuk": 1662508800000,
    "dt_barang_masuk_diedit": 1662595200000,
    "kodeitem": "20220507-3",
    "kondisi": "Baik",
    "kodeLokasi": "Lokasi-0113",
    "jenisOrnamaBarang": "Access Point",
    "merkOrtipe": "SM-640 Max",
    "kategori": "Elektronik",
    "ukuran": "20 x 10 x 1.5",
    "bahan": "Plastik",
    "satuan": "Buah",
    "tahunPembelian": "2015",
    "pabrik": "Unify",
    "rangka": "",
    "mesin": "",
    "noPolisi": "",
    "bpkb": "",
    "asalUsul": "",
    "harga": "",
    "sumberDana": "Dana KEMDIKBUD",
    "keterangan": "",
  },
  {
    "dt_barang_masuk": 1662508800000,
    "dt_barang_masuk_diedit": 1662595200000,
    "kodeitem": "20220508-1",
    "kondisi": "Baik",
    "kodeLokasi": "Lokasi-0113",
    "jenisOrnamaBarang": "Access Point",
    "merkOrtipe": "TP-Link",
    "kategori": "Elektronik",
    "ukuran": "20 x 10 x 1.5",
    "bahan": "Plastik",
    "satuan": "Buah",
    "tahunPembelian": "2017",
    "pabrik": "Unify",
    "rangka": "",
    "mesin": "",
    "noPolisi": "",
    "bpkb": "",
    "asalUsul": "",
    "harga": "",
    "sumberDana": "Dana KEMDIKBUD",
    "keterangan": "",
  },
  {
    "dt_barang_masuk": 1662508800000,
    "dt_barang_masuk_diedit": 1662595200000,
    "kodeitem": "20220508-2",
    "kondisi": "Baik",
    "jenisOrnamaBarang": "Access Point",
    "merkOrtipe": "TP-Link",
    "kategori": "Elektronik",
    "ukuran": "20 x 10 x 1.5",
    "bahan": "Plastik",
    "satuan": "Buah",
    "tahunPembelian": "2017",
    "pabrik": "Unify",
    "rangka": "",
    "mesin": "",
    "noPolisi": "",
    "bpkb": "",
    "asalUsul": "",
    "harga": "",
    "sumberDana": "Dana KEMDIKBUD",
    "keterangan": "",
  },
  {
    "dt_barang_masuk": 1662508800000,
    "dt_barang_masuk_diedit": 1662595200000,
    "kodeitem": "20220511-1",
    "kondisi": "Baik",
    "kodeLokasi": "Lokasi-0113",
    "jenisOrnamaBarang": "Laptop",
    "merkOrtipe": "xd432",
    "kategori": "Elektronik",
    "ukuran": "20 x 10 x 1.5",
    "bahan": "Plastik",
    "satuan": "Unit",
    "tahunPembelian": "2018",
    "pabrik": "ASUS",
    "rangka": "",
    "mesin": "",
    "noPolisi": "",
    "bpkb": "",
    "asalUsul": "",
    "harga": "",
    "sumberDana": "Dana KEMDIKBUD",
    "keterangan": "Intel Core i3 6700M, RAM 10gb, SSD 240GB, Harddisk 1000GB, Windows 10",
  },
  {
    "dt_barang_masuk": 1662508800000,
    "dt_barang_masuk_diedit": 1662595200000,
    "kodeitem": "20220511-2",
    "kondisi": "Baik",
    "kodeLokasi": "Lokasi-0113",
    "jenisOrnamaBarang": "Laptop",
    "merkOrtipe": "xd432",
    "kategori": "Elektronik",
    "ukuran": "20 x 10 x 1.5",
    "bahan": "Plastik",
    "satuan": "Unit",
    "tahunPembelian": "2018",
    "pabrik": "ASUS",
    "rangka": "",
    "mesin": "",
    "noPolisi": "",
    "bpkb": "",
    "asalUsul": "",
    "harga": "",
    "sumberDana": "Dana KEMDIKBUD",
    "keterangan": "Intel Core i3 6700M, RAM 10gb, SSD 240GB, Harddisk 1000GB, Windows 10",
  },
  {
    "dt_barang_masuk": 1662508800000,
    "dt_barang_masuk_diedit": 1662595200000,
    "kodeitem": "20220511-3",
    "kondisi": "Baik",
    "kodeLokasi": "Lokasi-0113",
    "jenisOrnamaBarang": "Laptop",
    "merkOrtipe": "xd432",
    "kategori": "Elektronik",
    "ukuran": "20 x 10 x 1.5",
    "bahan": "Plastik",
    "satuan": "Unit",
    "tahunPembelian": "2018",
    "pabrik": "ASUS",
    "rangka": "",
    "mesin": "",
    "noPolisi": "",
    "bpkb": "",
    "asalUsul": "",
    "harga": "",
    "sumberDana": "Dana KEMDIKBUD",
    "keterangan": "Intel Core i3 6700M, RAM 10gb, SSD 240GB, Harddisk 1000GB, Windows 10",
  },
  {
    "dt_barang_masuk": 1662508800000,
    "dt_barang_masuk_diedit": 1662595200000,
    "kodeitem": "20220511-4",
    "kondisi": "Baik",
    "kodeLokasi": "Lokasi-0113",
    "jenisOrnamaBarang": "Laptop",
    "merkOrtipe": "xd432",
    "kategori": "Elektronik",
    "ukuran": "20 x 10 x 1.5",
    "bahan": "Plastik",
    "satuan": "Unit",
    "tahunPembelian": "2018",
    "pabrik": "ASUS",
    "rangka": "",
    "mesin": "",
    "noPolisi": "",
    "bpkb": "",
    "asalUsul": "",
    "harga": "",
    "sumberDana": "Dana KEMDIKBUD",
    "keterangan": "Intel Core i3 6700M, RAM 10gb, SSD 240GB, Harddisk 1000GB, Windows 10",
  },
  {
    "dt_barang_masuk": 1662508800000,
    "dt_barang_masuk_diedit": 1662595200000,
    "kodeitem": "20220511-5",
    "kondisi": "Baik",
    "kodeLokasi": "Lokasi-0113",
    "jenisOrnamaBarang": "Laptop",
    "merkOrtipe": "xd432",
    "kategori": "Elektronik",
    "ukuran": "20 x 10 x 1.5",
    "bahan": "Plastik",
    "satuan": "Unit",
    "tahunPembelian": "2018",
    "pabrik": "ASUS",
    "rangka": "",
    "mesin": "",
    "noPolisi": "",
    "bpkb": "",
    "asalUsul": "",
    "harga": "",
    "sumberDana": "Dana KEMDIKBUD",
    "keterangan": "Intel Core i3 6700M, RAM 10gb, SSD 240GB, Harddisk 1000GB, Windows 10",
  },
  {
    "dt_barang_masuk": 1662508800000,
    "dt_barang_masuk_diedit": 1662595200000,
    "kodeitem": "20220513-1",
    "kondisi": "Baik",
    "kodeLokasi": "Lokasi-0113",
    "jenisOrnamaBarang": "Komputer AIO",
    "merkOrtipe": "A5401WRPK-BA581TS",
    "kategori": "Elektronik",
    "ukuran": "20 x 10 x 1.5",
    "bahan": "Plastik",
    "satuan": "Unit",
    "tahunPembelian": "2018",
    "pabrik": "Acer",
    "rangka": "",
    "mesin": "",
    "noPolisi": "",
    "bpkb": "",
    "asalUsul": "",
    "harga": "",
    "sumberDana": "Dana KEMDIKBUD",
    "keterangan": "AMD Ryzen3 2250g, RAM 8gb, Harddisk 1000GB, Windows 10",
  },
  {
    "dt_barang_masuk": 1662508800000,
    "dt_barang_masuk_diedit": 1662595200000,
    "kodeitem": "20220513-2",
    "kondisi": "Baik",
    "kodeLokasi": "Lokasi-0113",
    "jenisOrnamaBarang": "Komputer AIO",
    "merkOrtipe": "A5401WRPK-BA581TS",
    "kategori": "Elektronik",
    "ukuran": "20 x 10 x 1.5",
    "bahan": "Plastik",
    "satuan": "Unit",
    "tahunPembelian": "2018",
    "pabrik": "Acer",
    "rangka": "",
    "mesin": "",
    "noPolisi": "",
    "bpkb": "",
    "asalUsul": "",
    "harga": "",
    "sumberDana": "Dana KEMDIKBUD",
    "keterangan": "AMD Ryzen3 2250g, RAM 8gb, Harddisk 1000GB, Windows 10",
  },
  {
    "dt_barang_masuk": 1662508800000,
    "dt_barang_masuk_diedit": 1662595200000,
    "kodeitem": "20220513-3",
    "kondisi": "Baik",
    "kodeLokasi": "Lokasi-0113",
    "jenisOrnamaBarang": "Komputer AIO",
    "merkOrtipe": "A5401WRPK-BA581TS",
    "kategori": "Elektronik",
    "ukuran": "20 x 10 x 1.5",
    "bahan": "Plastik",
    "satuan": "Unit",
    "tahunPembelian": "2018",
    "pabrik": "Acer",
    "rangka": "",
    "mesin": "",
    "noPolisi": "",
    "bpkb": "",
    "asalUsul": "",
    "harga": "",
    "sumberDana": "Dana KEMDIKBUD",
    "keterangan": "AMD Ryzen3 2250g, RAM 8gb, Harddisk 1000GB, Windows 10",
  },
  {
    "dt_barang_masuk": 1662508800000,
    "dt_barang_masuk_diedit": 1662595200000,
    "kodeitem": "20220515-1",
    "kondisi": "Baik",
    "kodeLokasi": "Lokasi-0113",
    "jenisOrnamaBarang": "PC Desktop",
    "merkOrtipe": "PC Slimeline S01-PF1181D DT",
    "kategori": "Elektronik",
    "ukuran": "20 x 10 x 1.5",
    "bahan": "Plastik",
    "satuan": "Buah",
    "tahunPembelian": "2018",
    "pabrik": "HP",
    "rangka": "",
    "mesin": "",
    "noPolisi": "",
    "bpkb": "",
    "asalUsul": "",
    "harga": "",
    "sumberDana": "Dana KEMDIKBUD",
    "keterangan": "Intel Pentium Gold G6400/ 4GB RAM/ 1TB HDD/ 19,5 inch HD/ Win11",
  },
  {
    "dt_barang_masuk": 1662508800000,
    "dt_barang_masuk_diedit": 1662595200000,
    "kodeitem": "20220515-2",
    "kondisi": "Baik",
    "kodeLokasi": "Lokasi-0113",
    "jenisOrnamaBarang": "PC Desktop",
    "merkOrtipe": "PC Slimeline S01-PF1181D DT",
    "kategori": "Elektronik",
    "ukuran": "20 x 10 x 1.5",
    "bahan": "Plastik",
    "satuan": "Buah",
    "tahunPembelian": "2018",
    "pabrik": "HP",
    "rangka": "",
    "mesin": "",
    "noPolisi": "",
    "bpkb": "",
    "asalUsul": "",
    "harga": "",
    "sumberDana": "Dana KEMDIKBUD",
    "keterangan": "Intel Pentium Gold G6400/ 4GB RAM/ 1TB HDD/ 19,5 inch HD/ Win11",
  },
  {
    "dt_barang_masuk": 1662508800000,
    "dt_barang_masuk_diedit": 1662595200000,
    "kodeitem": "20220515-3",
    "kondisi": "Baik",
    "kodeLokasi": "Lokasi-0113",
    "jenisOrnamaBarang": "PC Desktop",
    "merkOrtipe": "PC Slimeline S01-PF1181D DT",
    "kategori": "Elektronik",
    "ukuran": "20 x 10 x 1.5",
    "bahan": "Plastik",
    "satuan": "Buah",
    "tahunPembelian": "2018",
    "pabrik": "HP",
    "rangka": "",
    "mesin": "",
    "noPolisi": "",
    "bpkb": "",
    "asalUsul": "",
    "harga": "",
    "sumberDana": "Dana KEMDIKBUD",
    "keterangan": "Intel Pentium Gold G6400/ 4GB RAM/ 1TB HDD/ 19,5 inch HD/ Win11",
  },
  {
    "dt_barang_masuk": 1662508800000,
    "dt_barang_masuk_diedit": 1662595200000,
    "kodeitem": "20220515-4",
    "kondisi": "Baik",
    "kodeLokasi": "Lokasi-0113",
    "jenisOrnamaBarang": "PC Desktop",
    "merkOrtipe": "PC Slimeline S01-PF1181D DT",
    "kategori": "Elektronik",
    "ukuran": "20 x 10 x 1.5",
    "bahan": "Plastik",
    "satuan": "Buah",
    "tahunPembelian": "2018",
    "pabrik": "HP",
    "rangka": "",
    "mesin": "",
    "noPolisi": "",
    "bpkb": "",
    "asalUsul": "",
    "harga": "",
    "sumberDana": "Dana KEMDIKBUD",
    "keterangan": "Intel Pentium Gold G6400/ 4GB RAM/ 1TB HDD/ 19,5 inch HD/ Win11",
  },
];
