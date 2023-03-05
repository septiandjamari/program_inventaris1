import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:program_inventaris/global_database/1.daftar_item_barang_provider.dart';
import 'package:program_inventaris/global_database/2.daftar_barang_keluar_provider.dart';
import 'package:program_inventaris/global_database/3.master_lokasi_provider.dart';
import 'package:random_string/random_string.dart';

import '../../global_database/6.kartu_kontrol.dart';

class FormBarangKeluar extends StatefulWidget {
  const FormBarangKeluar({Key? key, required this.addViewEdit, this.idForm}) : super(key: key);
  final String? idForm;
  final String addViewEdit;
  @override
  State<FormBarangKeluar> createState() => _FormBarangKeluarState();
}

class _FormBarangKeluarState extends State<FormBarangKeluar> {
  final _formKey = GlobalKey<FormState>();
  DateTime dt = DateTime.now();
  int intBarangKeluar = 0;
  String kodeBarang = "";
  String kodeLokasiAwal = "";
  String kodeLokasiAkhir = "";
  Map<String, dynamic> initialData = {};
  bool isLoaded = false;

  TextEditingController dtBarangKeluar = TextEditingController(text: "");
  TextEditingController dtBarangKeluarDiedit = TextEditingController(text: "");

  TextEditingController idForm = TextEditingController(text: "");
  TextEditingController tglPengembalian = TextEditingController(text: "");
  TextEditingController namaBarang = TextEditingController(text: "");
  TextEditingController merkTipe = TextEditingController(text: "");
  TextEditingController lokasiAwal = TextEditingController(text: "");
  TextEditingController lokasiAkhir = TextEditingController(text: "");
  TextEditingController keterangan = TextEditingController(text: "");

  List<String> radioPengembalian = ['Belum', 'Sudah'];
  String radioPengembalianIndex = 'Belum';

  void mapInfoLokasiAkhirSetter(Map<String, dynamic> value) {
    setState(() {
      indexMapInfoLokasiAkhir = value;
      kodeLokasiAkhir = value["kodeLokasi"];
      lokasiAkhir.text = value["namaLokasi"];
    });
  }

  late StateSetter _dialogLokasiStateSetter;
  Map<String, dynamic> indexMapInfoLokasiAwal = {};
  Map<String, dynamic> indexMapInfoLokasiAkhir = {};
  List<Map<String, dynamic>> listInfoLokasi = [];
  void dialogRadioLokasiAkhir() {
    if (widget.addViewEdit != "view") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          int _indexLokasi =
              widget.addViewEdit == "add" ? 0 : listInfoLokasi.indexWhere((element) => element["kodeLokasi"] == indexMapInfoLokasiAkhir["kodeLokasi"]);
          Map<String, dynamic> _indexMapInfoLokasi = indexMapInfoLokasiAkhir;
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
                      mapInfoLokasiAkhirSetter(widget.addViewEdit == "add" ? _indexMapInfoLokasi : listInfoLokasi[_indexLokasi]);
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

  DateTime? dtTglPengembalian;

  void tglPengembalianDatePicker() async {
    DateTime? dtResult = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (dtResult != null) {
      setState(() {
        dtTglPengembalian = dtResult;
        tglPengembalian.text = DateFormat.yMMMEd('id_ID').format(dtResult);
      });
    }
  }

  void dialogInfoLokasi(String awalOrAkhir) {
    if (awalOrAkhir == "awal" ? indexMapInfoLokasiAwal.isNotEmpty : indexMapInfoLokasiAkhir.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text(
              "Detail Info Lokasi ${awalOrAkhir == 'awal' ? 'Awal' : 'Terakhir'}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Kode Lokasi :", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text(awalOrAkhir == "awal" ? indexMapInfoLokasiAwal["kodeLokasi"] : indexMapInfoLokasiAkhir["kodeLokasi"]),
                  const SizedBox(height: 16),
                  const Text("Nama Lokasi :", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text(awalOrAkhir == "awal" ? indexMapInfoLokasiAwal["namaLokasi"] : indexMapInfoLokasiAkhir["namaLokasi"]),
                  const SizedBox(height: 16),
                  const Text("Keterangan :", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text(awalOrAkhir == "awal" ? indexMapInfoLokasiAwal["keterangan"] : indexMapInfoLokasiAkhir["keterangan"]),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void mapDetailBarangSetter(Map<String, dynamic> value) {
    int indexLokasi = listInfoLokasi.indexWhere((e) => e["kodeLokasi"] == value["kodeLokasi"]);
    indexMapInfoLokasiAwal = listInfoLokasi[indexLokasi];
    setState(() {
      indexMapInfoBarang = value;
      kodeBarang = value["kodeitem"];
      namaBarang.text = value["jenisOrnamaBarang"];
      merkTipe.text = "${value["pabrik"]} - ${value["merkOrtipe"]}";
      lokasiAwal.text = listInfoLokasi[indexLokasi]["namaLokasi"];
    });
  }

  late StateSetter _dialogItemBarangStateSetter;
  Map<String, dynamic> indexMapInfoBarang = {};
  List<Map<String, dynamic>> listItemBarang = [];
  void dialogRadioItemBarang() {
    if (widget.addViewEdit != "view") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          int _indexBarang = widget.addViewEdit == "add" ? 0 : listItemBarang.indexWhere((element) => element["kodeitem"] == indexMapInfoBarang["kodeitem"]);
          Map<String, dynamic> _indexMapInfoBarang = indexMapInfoBarang;
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              _dialogItemBarangStateSetter = setState;
              return AlertDialog(
                title: const Text("Pilih Barang"),
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
                          children: listItemBarang.map(
                            (e) {
                              int indexLokasi = listInfoLokasi.indexWhere((e1) => e1["kodeLokasi"] == e["kodeLokasi"]);
                              if (kDebugMode) {
                                print("int indexLokasi : $indexLokasi");
                              }
                              return RadioListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.fromLTRB(4, 2, 8, 2),
                                value: e,
                                groupValue: widget.addViewEdit == "add" ? _indexMapInfoBarang : listItemBarang[_indexBarang],
                                title: Row(
                                  children: [
                                    Text(
                                      "${e["kodeitem"]}",
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Expanded(
                                        child: Text(
                                      " ${e["pabrik"]} - ${e["merkOrtipe"]}",
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                  ],
                                ),
                                subtitle: Text("${e["jenisOrnamaBarang"]}${indexLokasi != -1 ? ", " + listInfoLokasi[indexLokasi]["namaLokasi"] : ""}"),
                                onChanged: (dynamic value) {
                                  _dialogItemBarangStateSetter(() {
                                    if (widget.addViewEdit == "add") {
                                      _indexMapInfoBarang = value;
                                    } else {
                                      _indexBarang = listItemBarang.indexWhere((element) => element["kodeitem"] == value["kodeitem"]);
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
                      mapDetailBarangSetter(widget.addViewEdit == "add" ? _indexMapInfoBarang : listItemBarang[_indexBarang]);
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

  void dialogSuccess(String whatSuccess) {
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
                whatSuccess == "saveData"
                    ? widget.addViewEdit == "add"
                        ? "Berhasil menambahkan data..."
                        : "Berhasil mengedit data..."
                    : "Berhasil menghapus data",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  void loadData() async {
    loadListBarang();
    loadListLokasi();
    var mapResultInitialData = await streamDaftarBarangKeluarProvider.selectDataBarangKeluar(idForm: widget.idForm!);
    var initialDataItemBarang = await streamDaftarItemBarangProvider.selectDataBarang(kodeItem: mapResultInitialData["id_barang"]);
    var initialDataLokasiAwal = await streamMasterLokasiProvider.selectLokasi(kodeLokasi: initialDataItemBarang["kodeLokasi"]);
    mapInfoLokasiAkhirSetter(await streamMasterLokasiProvider.selectLokasi(kodeLokasi: mapResultInitialData["id_lokasi_terakhir"]));

    if (kDebugMode) {
      print(mapResultInitialData);
    }

    setState(() {
      tglPengembalian.text = DateFormat.yMMMEd('id_ID').format(DateTime.fromMillisecondsSinceEpoch(mapResultInitialData["tanggal_pengembalian"]));
      dtTglPengembalian = DateTime.fromMillisecondsSinceEpoch(mapResultInitialData['tanggal_pengembalian']);
      radioPengembalianIndex = mapResultInitialData['dikembalikan'] == true ? 'Sudah' : 'Belum';
      intBarangKeluar = mapResultInitialData["dt_barang_keluar"];
      dtBarangKeluar.text = DateFormat.yMMMEd('id_ID').add_Hm().format(DateTime.fromMillisecondsSinceEpoch(mapResultInitialData["dt_barang_keluar"]));
      dtBarangKeluarDiedit.text =
          DateFormat.yMMMEd('id_ID').add_Hm().format(DateTime.fromMillisecondsSinceEpoch(mapResultInitialData["dt_barang_keluar_diedit"]));
      idForm.text = widget.idForm!;
      indexMapInfoLokasiAwal = initialDataLokasiAwal;
      indexMapInfoBarang = initialDataItemBarang;
      kodeBarang = initialDataItemBarang["kodeitem"];
      namaBarang.text = initialDataItemBarang["jenisOrnamaBarang"];
      merkTipe.text = "${initialDataItemBarang["pabrik"]} - ${initialDataItemBarang["merkOrtipe"]}";
      lokasiAwal.text = initialDataLokasiAwal["namaLokasi"];
      keterangan.text = mapResultInitialData["keterangan"];
      isLoaded = true;
    });
  }

  void loadListBarang() async {
    var listResultItemBarang = await streamDaftarItemBarangProvider.daftarItemBarangValue(addEditDeleteViewListDaftarBarang: "list");
    setState(() {
      listItemBarang = listResultItemBarang;
    });
  }

  void loadListLokasi() async {
    var listResultInfoLokasi = await streamMasterLokasiProvider.masterLokasiValue(addEditDeleteViewListMasterLokasi: "list");
    setState(() {
      listInfoLokasi = listResultInfoLokasi;
    });
  }

  List<Map<String, dynamic>> listKodeBarang = [];

  void loadDaftarBarangKeluar() async {
    var lisResultBarangKeluar = await streamDaftarBarangKeluarProvider.daftarBarangKeluarValue(addEditDeleteView: 'list');
    for (var element in List.from(lisResultBarangKeluar)) {
      if (element['dikembalikan'] == false) {
        listKodeBarang.add({'kodeBarang': element['id_barang'], 'tanggal_pengembalian': element['tanggal_pengembalian']});
      }
    }
    if (kDebugMode) {
      print(listKodeBarang);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.addViewEdit == "add") {
      idForm.text = "${dt.year.toString().substring(2)}${dt.month}${dt.day}${dt.hour}${dt.minute}${dt.second}";
      loadListBarang();
      loadListLokasi();
      loadDaftarBarangKeluar();
      isLoaded = true;
    } else {
      loadData();
    }
  }

  void saveData() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> dataBarangKeluar = {
        "dt_barang_keluar": widget.addViewEdit == "add" ? dt.millisecondsSinceEpoch : intBarangKeluar,
        "dt_barang_keluar_diedit": dt.millisecondsSinceEpoch,
        "id_form": idForm.text,
        "id_barang": indexMapInfoBarang["kodeitem"],
        "id_lokasi_terakhir": indexMapInfoLokasiAkhir["kodeLokasi"],
        "keterangan": keterangan.text,
        "dikembalikan": radioPengembalianIndex == 'Sudah' ? true : false,
        "tanggal_pengembalian": dtTglPengembalian!.millisecondsSinceEpoch,
      };

      var data = {
        'nomer_kontrol': randomAlphaNumeric(6),
        'tanggal': DateTime.now().millisecondsSinceEpoch,
        'kode_barang': indexMapInfoBarang["kodeitem"],
        'status_history': radioPengembalianIndex == 'Sudah' ? 'item_returned' : 'item_borrowed',
        'kondisi': indexMapInfoBarang["kondisi"],
        'keterangan': keterangan.text,
      };

      if (widget.addViewEdit == "add") {
        dbKartuKontrol.dbKartuKontrol(aksi: 'tambah', data: data, kodeBarang: indexMapInfoBarang["kodeitem"]);
        streamDaftarBarangKeluarProvider.addDataBarangKeluar(dataBarang: dataBarangKeluar);
      } else {
        if (radioPengembalianIndex == 'Sudah') {
          dbKartuKontrol.dbKartuKontrol(aksi: 'tambah', data: data, kodeBarang: indexMapInfoBarang["kodeitem"]);
        }
        streamDaftarBarangKeluarProvider.editDataBarangKeluar(dataBarang: dataBarangKeluar, kodeForm: idForm.text);
      }
      dialogSuccess('saveData');
    } else {
      dialogFailed();
    }
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
      },
    );
  }

  void dialogHapusData() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Konfirmasi Hapus Data"),
          content: const Text("Apakah anda yakin untuk menghapus data ini ?"),
          actions: [
            TextButton(
              onPressed: () async {
                streamDaftarBarangKeluarProvider.delete(kodeForm: widget.idForm!);
                await Future.delayed(const Duration(milliseconds: 500)).then((value) => Navigator.pop(ctx));
                dialogSuccess('deleteData');
                // await Future.delayed(const Duration(milliseconds: 750)).then((value) => Navigator.pop(context));
              },
              child: const Text("YA", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Future.delayed(const Duration(milliseconds: 500)).then((value) => Navigator.pop(ctx));
              },
              child: const Text("BATAL", style: TextStyle(color: Colors.black45)),
            )
          ],
        );
      },
    );
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
                ? "Tambah Data Barang Keluar"
                : widget.addViewEdit == "view"
                    ? "Lihat Data Barang Keluar"
                    : "Edit Data Barang Keluar"),
            actions: widget.addViewEdit != "view" && !listKodeBarang.any((element) => element['kodeBarang'] == indexMapInfoBarang['kodeitem'])
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
                        children: [
                          widget.addViewEdit == 'view'
                              ? Column(
                                  children: [
                                    TextFormField(
                                      enabled: false,
                                      controller: dtBarangKeluar,
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
                                        label: Text("Tanggal Input"),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      enabled: false,
                                      controller: dtBarangKeluarDiedit,
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
                                        label: Text("Tanggal Input Diedit"),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                )
                              : const SizedBox(),
                          TextFormField(
                            enabled: false,
                            controller: idForm,
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
                              label: Text("No. Form"),
                            ),
                          ),
                          const SizedBox(height: 16),

                          listKodeBarang.any((element) => element['kodeBarang'] == indexMapInfoBarang['kodeitem']) && widget.addViewEdit == 'add'
                              ? Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                  color: Colors.yellow.shade200,
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Barang Telah Dipinjamakan dan belum Dikembalikan\n',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                          'Silahkan coba kembali pada : ${DateFormat.yMMMEd('id_ID').format(DateTime.fromMillisecondsSinceEpoch(listKodeBarang[listKodeBarang.indexWhere((element) => element['kodeBarang'] == indexMapInfoBarang['kodeitem'])]['tanggal_pengembalian']))}'),
                                      const SizedBox(
                                        height: 24,
                                      ),
                                      TextButton(
                                          onPressed: () {
                                            dialogRadioItemBarang();
                                          },
                                          child: const Text(
                                            'PILIH BARANG LAINNYA',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          )),
                                    ],
                                  ),
                                )
                              : Column(
                                  children: [
                                    widget.addViewEdit != 'add'
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.black54),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Sudah Dikembalikan",
                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                ),
                                                Column(
                                                  children: radioPengembalian
                                                      .map(
                                                        (e) => RadioListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          value: e,
                                                          groupValue: radioPengembalianIndex,
                                                          title: Text(e),
                                                          onChanged: widget.addViewEdit != "view"
                                                              ? (dynamic value) {
                                                                  setState(() {
                                                                    radioPengembalianIndex = value;
                                                                  });
                                                                }
                                                              : null,
                                                        ),
                                                      )
                                                      .toList(),
                                                )
                                              ],
                                            ),
                                          )
                                        : const SizedBox(),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      readOnly: true,
                                      onTap: () {
                                        tglPengembalianDatePicker();
                                      },
                                      enabled: widget.addViewEdit == 'add' ? true : false,
                                      controller: tglPengembalian,
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
                                        label: Text("Tanggal. Pengembalian"),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      enabled: widget.addViewEdit == "add" ? true : false,
                                      readOnly: true,
                                      onTap: () {
                                        dialogRadioItemBarang();
                                      },
                                      controller: namaBarang,
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
                                      enabled: widget.addViewEdit == "add" ? true : false,
                                      readOnly: true,
                                      onTap: () {
                                        dialogRadioItemBarang();
                                      },
                                      controller: merkTipe,
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
                                        label: Text("Merk/Tipe Barang"),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      enabled: widget.addViewEdit == "add" ? true : false,
                                      readOnly: true,
                                      onTap: widget.addViewEdit == "add"
                                          ? () {
                                              if (widget.addViewEdit == "view") {
                                                dialogInfoLokasi("awal");
                                              } else {
                                                dialogRadioItemBarang();
                                              }
                                            }
                                          : null,
                                      controller: lokasiAwal,
                                      decoration: InputDecoration(
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                        border: const OutlineInputBorder(),
                                        label: const Text("Lokasi Awal"),
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            dialogInfoLokasi("awal");
                                          },
                                          icon: const Icon(Icons.info),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      enabled: widget.addViewEdit == "add" ? true : false,
                                      readOnly: true,
                                      onTap: widget.addViewEdit == "add"
                                          ? () {
                                              dialogRadioLokasiAkhir();
                                            }
                                          : null,
                                      controller: lokasiAkhir,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return "Data harus di isi";
                                        } else {
                                          return null;
                                        }
                                      },
                                      decoration: InputDecoration(
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                        border: const OutlineInputBorder(),
                                        label: const Text("Lokasi Terakhir"),
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            dialogInfoLokasi("akhir");
                                          },
                                          icon: const Icon(Icons.info),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      minLines: 4,
                                      maxLines: null,
                                      enabled: widget.addViewEdit != "view" ? true : false,
                                      controller: keterangan,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                        label: Text("Keterangan"),
                                      ),
                                    ),
                                  ],
                                ),
                          const SizedBox(height: 48),
                          // widget.addViewEdit == "edit"
                          //     ? ElevatedButton(
                          //         style: ElevatedButton.styleFrom(primary: Colors.red, onPrimary: Colors.white),
                          //         onPressed: () {
                          //           dialogHapusData();
                          //         },
                          //         child: const Text("Hapus Data Barang Keluar"))
                          //     : const SizedBox(),
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
        ));
  }
}
