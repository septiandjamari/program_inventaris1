import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:program_inventaris/global_database/1.daftar_item_barang_provider.dart';
import 'package:program_inventaris/global_database/3.master_lokasi_provider.dart';
import 'package:random_string/random_string.dart';

import '../../global_database/6.kartu_kontrol.dart';

class FormItemBarang extends StatefulWidget {
  const FormItemBarang({Key? key, required this.addViewEdit, this.idBarang}) : super(key: key);
  final String? idBarang;
  final String addViewEdit;
  @override
  State<FormItemBarang> createState() => _FormItemBarangState();
}

class _FormItemBarangState extends State<FormItemBarang> {
  final _formKey = GlobalKey<FormState>();
  bool isLoaded = false;
  DateTime dt = DateTime.now();

  int intDtBarangMasuk = 0;
  TextEditingController kodeItem = TextEditingController(text: "");
  TextEditingController jenisOrNamaBarang = TextEditingController(text: "");
  List<String> radioKondisi = ["Baik", "Sedang", "Buruk"];
  String radioKondisiIndex = "Baik";
  List<String> radioSatuan = ["Unit", "Buah"];
  String radioSatuanIndex = "Unit";
  TextEditingController lokasi = TextEditingController(text: "");
  String kodeLokasi = "";
  /*
    texteditingcontroller dari form induk barang
  */

  TextEditingController dtBarangMasuk = TextEditingController(text: "");
  TextEditingController dtBarangMasukDiedit = TextEditingController(text: "");

  TextEditingController tipe = TextEditingController(text: "");
  TextEditingController kategori = TextEditingController(text: "");
  TextEditingController ukuran = TextEditingController(text: "");
  TextEditingController bahan = TextEditingController(text: "");

  TextEditingController tahunPembelian = TextEditingController(text: "");
  TextEditingController pabrik = TextEditingController(text: "");
  TextEditingController rangka = TextEditingController(text: "");
  TextEditingController mesin = TextEditingController(text: "");
  TextEditingController noPolisi = TextEditingController(text: "");
  TextEditingController bpkb = TextEditingController(text: "");
  TextEditingController asalUsul = TextEditingController(text: "");
  TextEditingController harga = TextEditingController(text: "");
  TextEditingController sumberDana = TextEditingController(text: "");
  TextEditingController keterangan = TextEditingController(text: "");

  Map<String, dynamic> mapDataBarang = {};
  List<Map<String, dynamic>> listJenisBarang = [];

  void kotegoriStringSetter(String value) {
    setState(() {
      kategori.text = value;
    });
  }

  late StateSetter _dialogKategoriStateSetter;
  List<String> listKategoriBarang = [
    "Perlengkapan Kelas",
    "Hiasan Ruangan",
    "Peralatan Mengajar",
    "Peralatan Elektronik",
    "Peralatan Kebun",
    "Peralatan Dapur",
    "Kendaraan Bermotor",
    "Perlengkapan P3K - Kesehatan",
    "Peralatan Olahraga",
  ];
  void dialogRadioKategori() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String _indexKategori = kategori.text;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            _dialogKategoriStateSetter = setState;
            return AlertDialog(
              title: const Text("Pilih Kategori Barang"),
              titlePadding: const EdgeInsets.only(top: 48, left: 24),
              insetPadding: const EdgeInsets.all(48),
              content: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.3,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: listKategoriBarang
                            .map(
                              (e) => RadioListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                                value: e,
                                groupValue: _indexKategori,
                                title: Text(e),
                                onChanged: (dynamic value) {
                                  _dialogKategoriStateSetter(() {
                                    _indexKategori = value;
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("BATAL"),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    kotegoriStringSetter(_indexKategori);
                  },
                  child: const Text("SIMPAN"),
                ),
              ],
            );
          },
        );
      },
      barrierDismissible: false,
    );
  }

  void mapInfoLokasiSetter(Map<String, dynamic> value) {
    setState(() {
      indexMapInfoLokasi = value;
      lokasi.text = value["namaLokasi"];
      kodeLokasi = value["kodeLokasi"];
    });
  }

  late StateSetter _dialogLokasiStateSetter;
  Map<String, dynamic> indexMapInfoLokasi = {};
  List<Map<String, dynamic>> listInfoLokasi = [];
  void dialogRadioLokasi() {
    if (widget.addViewEdit != "view") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          int _indexLokasi =
              widget.addViewEdit == "add" ? 0 : listInfoLokasi.indexWhere((element) => element["kodeLokasi"] == indexMapInfoLokasi["kodeLokasi"]);
          Map<String, dynamic> _indexMapInfoLokasi = indexMapInfoLokasi;
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              _dialogLokasiStateSetter = setState;
              return AlertDialog(
                title: const Text("Pilih Lokasi"),
                titlePadding: const EdgeInsets.only(top: 48, left: 24),
                insetPadding: const EdgeInsets.all(48),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: listInfoLokasi.map(
                            (e) {
                              return RadioListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                                value: e,
                                groupValue: widget.addViewEdit == "add"
                                    ? _indexMapInfoLokasi
                                    : _indexLokasi != -1
                                        ? listInfoLokasi[_indexLokasi]
                                        : {},
                                title: Text(e["namaLokasi"]),
                                subtitle: e["keterangan"] != "" ? Text(e["keterangan"]) : null,
                                onChanged: (dynamic value) {
                                  _dialogLokasiStateSetter(() {
                                    if (widget.addViewEdit == "add") {
                                      _indexMapInfoLokasi = value;
                                    } else {
                                      _indexLokasi = listInfoLokasi.indexWhere((element) => element["kodeLokasi"] == value["kodeLokasi"]);
                                    }
                                  });
                                },
                              );
                            },
                          ).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("BATAL"),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      mapInfoLokasiSetter(widget.addViewEdit == "add" ? _indexMapInfoLokasi : listInfoLokasi[_indexLokasi]);
                    },
                    child: const Text("SIMPAN"),
                  ),
                ],
              );
            },
          );
        },
        barrierDismissible: false,
      );
    }
  }

  void dialogInfoLokasi() {
    if (indexMapInfoLokasi.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text(
              "Detail Info Lokasi",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Kode Lokasi :", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text(indexMapInfoLokasi["kodeLokasi"]),
                  const SizedBox(height: 16),
                  const Text("Nama Lokasi :", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text(indexMapInfoLokasi["namaLokasi"]),
                  const SizedBox(height: 16),
                  const Text("Keterangan :", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text(indexMapInfoLokasi["keterangan"]),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.addViewEdit != "add") {
      loadData();
    } else {
      kodeItem.text = "${int.parse("${dt.year.toString().substring(2)}${dt.month}${dt.day}${dt.hour}${dt.minute}${dt.second}")}";
      loadLokasi();
      isLoaded = true;
    }
  }

  void loadLokasi() async {
    var listResultInfoLokasi = await streamMasterLokasiProvider.masterLokasiValue(addEditDeleteViewListMasterLokasi: "list");
    setState(() {
      listInfoLokasi = listResultInfoLokasi;
    });
  }

  void loadData() async {
    var mapResultItem = await streamDaftarItemBarangProvider.selectDataBarang(kodeItem: widget.idBarang!);
    Map<String, dynamic> mapResultInfoLokasi;
    if (mapResultItem["kodeLokasi"] != "") {
      mapResultInfoLokasi = await streamMasterLokasiProvider.selectLokasi(kodeLokasi: mapResultItem["kodeLokasi"]);
    } else {
      mapResultInfoLokasi = {};
    }
    var listResultInfoLokasi = await streamMasterLokasiProvider.masterLokasiValue(addEditDeleteViewListMasterLokasi: "list");
    setState(() {
      intDtBarangMasuk = mapResultItem["dt_barang_masuk"];
      dtBarangMasuk.text = DateFormat.yMMMEd("id_ID").add_Hm().format(DateTime.fromMillisecondsSinceEpoch(mapResultItem["dt_barang_masuk"]));
      dtBarangMasukDiedit.text = DateFormat.yMMMEd("id_ID").add_Hm().format(DateTime.fromMillisecondsSinceEpoch(mapResultItem["dt_barang_masuk_diedit"]));

      indexMapInfoLokasi = mapResultInfoLokasi;
      listInfoLokasi = listResultInfoLokasi;
      /*
        NOTE Data Item Barang
      */
      kodeItem.text = mapResultItem["kodeitem"];
      jenisOrNamaBarang.text = mapResultItem["jenisOrnamaBarang"];
      radioKondisiIndex = mapResultItem["kondisi"];
      lokasi.text = mapResultItem["kodeLokasi"] != "" ? mapResultInfoLokasi["namaLokasi"] : "";
      /*
        NOTE dari form induk barang
      */
      jenisOrNamaBarang.text = mapResultItem["jenisOrnamaBarang"];
      tipe.text = mapResultItem["merkOrtipe"];
      kategori.text = mapResultItem["kategori"];
      ukuran.text = mapResultItem["ukuran"];
      bahan.text = mapResultItem["bahan"];
      radioSatuanIndex = mapResultItem["satuan"];
      tahunPembelian.text = mapResultItem["tahunPembelian"];
      pabrik.text = mapResultItem["pabrik"];
      rangka.text = mapResultItem["rangka"];
      mesin.text = mapResultItem["mesin"];
      noPolisi.text = mapResultItem["noPolisi"];
      bpkb.text = mapResultItem["bpkb"];
      asalUsul.text = mapResultItem["asalUsul"];
      harga.text = mapResultItem["harga"];
      sumberDana.text = mapResultItem["sumberDana"];
      isLoaded = true;
    });
  }

  void dialogSuccess() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogSuccessCtx) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            Navigator.pop(dialogSuccessCtx);
          });
          Future.delayed(const Duration(milliseconds: 2000), () {
            Navigator.pop(context);
          });
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, color: Colors.green.shade600, size: 160),
                const SizedBox(height: 16),
                Text(
                  widget.addViewEdit == "add" ? "Berhasil menambahkan data..." : "Berhasil mengedit data...",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        });
  }

  void dialogFailed() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext ctx) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            Navigator.pop(ctx);
          });
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close, color: Colors.red.shade600, size: 160),
                const SizedBox(height: 16),
                const Text(
                  "Silahkan isi form data yang dibutuhkan...",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        });
  }

  void saveData() {
    if (_formKey.currentState!.validate()) {
      dialogSuccess();
      Map<String, dynamic> dataBarang = {
        "dt_barang_masuk": widget.addViewEdit == "add" ? dt.millisecondsSinceEpoch : intDtBarangMasuk,
        "dt_barang_masuk_diedit": dt.millisecondsSinceEpoch,
        "kodeitem": kodeItem.text,
        "kondisi": radioKondisiIndex,
        "kodeLokasi": kodeLokasi,
        "jenisOrnamaBarang": jenisOrNamaBarang.text,
        "kategori": kategori.text,
        "ukuran": ukuran.text,
        "bahan": bahan.text,
        "satuan": radioSatuanIndex,
        "tahunPembelian": tahunPembelian.text,
        "pabrik": pabrik.text,
        "merkOrtipe": tipe.text,
        "rangka": kategori.text == "Kendaraan Bermotor" ? rangka.text : "",
        "mesin": kategori.text == "Kendaraan Bermotor" ? mesin.text : "",
        "noPolisi": kategori.text == "Kendaraan Bermotor" ? noPolisi.text : "",
        "bpkb": kategori.text == "Kendaraan Bermotor" ? bpkb.text : "",
        "asalUsul": asalUsul.text,
        "harga": harga.text,
        "sumberDana": sumberDana.text,
        "keterangan": keterangan.text,
      };

      var data = {
        'nomer_kontrol': randomAlphaNumeric(6),
        'tanggal': DateTime.now().millisecondsSinceEpoch,
        'kode_barang': kodeItem.text,
        'status_history': 'first_time_input',
        'kondisi': radioKondisiIndex,
        'keterangan': keterangan.text,
      };

      if (widget.addViewEdit == "add") {
        dbKartuKontrol.dbKartuKontrol(aksi: 'tambah', data: data, kodeBarang: kodeItem.text);
        streamDaftarItemBarangProvider.addDataBarang(dataBarang: dataBarang);
      } else if (widget.addViewEdit == "edit") {
        streamDaftarItemBarangProvider.editDataBarang(kodeItem: widget.idBarang!, dataBarang: dataBarang);
      }
    } else {
      dialogFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primarySwatch: widget.addViewEdit == "add"
            ? Colors.blue
            : widget.addViewEdit == "view"
                ? Colors.green
                : Colors.yellow,
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: widget.addViewEdit == "add"
                      ? Colors.blue.shade700
                      : widget.addViewEdit == "view"
                          ? Colors.green.shade700
                          : Colors.yellow.shade700)),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black54)),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: widget.addViewEdit == "add"
              ? Colors.blue.shade700
              : widget.addViewEdit == "view"
                  ? Colors.green.shade700
                  : Colors.yellow.shade700,
          centerTitle: true,
          title: Text(widget.addViewEdit == "add"
              ? "Tambah Data Barang"
              : widget.addViewEdit == "view"
                  ? "Lihat Data Barang"
                  : "Edit Data Barang"),
          actions: widget.addViewEdit != "view"
              ? [
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: widget.addViewEdit == "edit" ? Colors.black : Colors.white),
                    onPressed: () {
                      saveData();
                    },
                    child: const Text("SIMPAN"),
                  ),
                ]
              : [],
        ),
        body: isLoaded
            ? Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        widget.addViewEdit != 'add'
                            ? TextFormField(
                                enabled: false,
                                controller: dtBarangMasuk,
                                decoration: const InputDecoration(
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  border: OutlineInputBorder(),
                                  label: Text("Tanggal Input"),
                                ),
                              )
                            : const SizedBox(),
                        const SizedBox(height: 16),
                        widget.addViewEdit != 'add'
                            ? TextFormField(
                                enabled: false,
                                controller: dtBarangMasukDiedit,
                                decoration: const InputDecoration(
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  border: OutlineInputBorder(),
                                  label: Text("Tanggal Input Diedit"),
                                ),
                              )
                            : const SizedBox(),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: false,
                          controller: kodeItem,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: OutlineInputBorder(),
                            label: Text("No. Kode Barang"),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: widget.addViewEdit != "view" ? true : false,
                          controller: pabrik,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Data harus di isi";
                            } else {
                              return null;
                            }
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            label: Text("Merek"),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: widget.addViewEdit != "view" ? true : false,
                          controller: tipe,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Data harus di isi";
                            } else {
                              return null;
                            }
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            label: Text("Tipe"),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: widget.addViewEdit != "view" ? true : false,
                          controller: jenisOrNamaBarang,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Data harus di isi";
                            } else {
                              return null;
                            }
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            label: Text("Nama Barang"),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          readOnly: true,
                          onTap: () {
                            dialogRadioKategori();
                          },
                          enabled: widget.addViewEdit != "view" ? true : false,
                          controller: kategori,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Data harus di isi";
                            } else {
                              return null;
                            }
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            label: Text("Kategori Barang"),
                          ),
                        ),
                        const SizedBox(height: 16),
                        kategori.text == "Kendaraan Bermotor"
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(height: 24, color: Colors.black),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    color: Colors.green.shade50,
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 16),
                                        const Text(
                                          "Detail Tambahan untuk kategori barang = kendaraan bermotor",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                        const SizedBox(height: 32),
                                        TextFormField(
                                          enabled: widget.addViewEdit != "view" ? true : false,
                                          controller: rangka,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                            label: Text("Rangka"),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          enabled: widget.addViewEdit != "view" ? true : false,
                                          controller: mesin,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                            label: Text("Mesin"),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          enabled: widget.addViewEdit != "view" ? true : false,
                                          controller: noPolisi,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                            label: Text("No Polisi"),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          enabled: widget.addViewEdit != "view" ? true : false,
                                          controller: bpkb,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                            label: Text("BPKB"),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 24, color: Colors.black),
                                ],
                              )
                            : const SizedBox(),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Kondisi",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Column(
                                children: radioKondisi
                                    .map(
                                      (e) => RadioListTile(
                                        contentPadding: EdgeInsets.zero,
                                        value: e,
                                        groupValue: radioKondisiIndex,
                                        title: Text(e),
                                        onChanged: widget.addViewEdit != "view"
                                            ? (dynamic value) {
                                                setState(() {
                                                  radioKondisiIndex = value;
                                                });
                                              }
                                            : null,
                                      ),
                                    )
                                    .toList(),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          readOnly: true,
                          onTap: () {
                            dialogRadioLokasi();
                          },
                          // enabled: widget.addViewEdit != "view" ? true : false,
                          controller: lokasi,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: const OutlineInputBorder(),
                            label: const Text("Lokasi"),
                            suffixIcon: IconButton(
                              onPressed: () {
                                dialogInfoLokasi();
                              },
                              icon: const Icon(Icons.info),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: widget.addViewEdit != "view" ? true : false,
                          controller: ukuran,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            label: Text("Ukuran (Sesuaikan dg spesifikasi di box barang)"),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: widget.addViewEdit != "view" ? true : false,
                          controller: bahan,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            label: Text("Bahan"),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Satuan",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Column(
                                children: radioSatuan
                                    .map(
                                      (e) => RadioListTile(
                                        contentPadding: EdgeInsets.zero,
                                        value: e,
                                        groupValue: radioSatuanIndex,
                                        title: Text(e),
                                        onChanged: widget.addViewEdit != "view"
                                            ? (dynamic value) {
                                                setState(() {
                                                  radioSatuanIndex = value;
                                                });
                                              }
                                            : null,
                                      ),
                                    )
                                    .toList(),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: widget.addViewEdit != "view" ? true : false,
                          controller: tahunPembelian,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Data harus di isi";
                            } else {
                              return null;
                            }
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            label: Text("Tahun Pembelian"),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: widget.addViewEdit != "view" ? true : false,
                          controller: asalUsul,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            label: Text("Asal Usul"),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: widget.addViewEdit != "view" ? true : false,
                          controller: harga,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            label: Text("Harga (Rp.)"),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: widget.addViewEdit != "view" ? true : false,
                          controller: sumberDana,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Data harus di isi";
                            } else {
                              return null;
                            }
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            label: Text("Sumber Dana"),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: widget.addViewEdit != "view" ? true : false,
                          minLines: 4,
                          maxLines: null,
                          controller: keterangan,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            label: Text("Keterangan"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 24),
                    Text("Memuat Data", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
      ),
    );
  }
}
