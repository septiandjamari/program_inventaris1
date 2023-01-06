import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:program_inventaris/global_database/1.daftar_item_barang_provider.dart';
import 'package:program_inventaris/global_database/3.master_lokasi_provider.dart';
import 'package:program_inventaris/global_database/6.kartu_kontrol.dart';
import 'package:random_string/random_string.dart';

class KartuKontrol extends StatefulWidget {
  const KartuKontrol({Key? key}) : super(key: key);

  @override
  State<KartuKontrol> createState() => _KartuKontrolState();
}

class _KartuKontrolState extends State<KartuKontrol> {
  bool isBarangDitemukan = false;
  bool isFormPencarianKosong = true;
  bool enableInput = true;

  Map<String, dynamic> mapDetailBarang = {};
  List<Map<String, dynamic>> daftarLokasi = [];
  List<Map<String, dynamic>> listKartuKontrol = [];

  TextEditingController controllerKodeBarang = TextEditingController(text: '');
  TextEditingController keterangan = TextEditingController(text: "");

  void cariKodeBarang(String kodeBarang) async {
    var detailBarangResult = await streamDaftarItemBarangProvider.selectDataBarang(kodeItem: kodeBarang);
    if (kDebugMode) {
      print('detailBarangResult = $detailBarangResult');
    }
    if (detailBarangResult.isNotEmpty) {
      var dbKartuKontrolResult = await dbKartuKontrol.dbKartuKontrol(aksi: 'list', kodeBarang: kodeBarang);
      if (kDebugMode) {
        print('dbKartuKontrolResult $dbKartuKontrolResult');
      }
      setState(() {
        isBarangDitemukan = true;
        isFormPencarianKosong = false;
        enableInput = false;
        mapDetailBarang = detailBarangResult;
        listKartuKontrol = dbKartuKontrolResult;
      });
    } else {
      if (kDebugMode) {
        print("Data Null");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    var daftarLokasiResult = await streamMasterLokasiProvider.masterLokasiValue(addEditDeleteViewListMasterLokasi: "list");
    setState(() {
      daftarLokasi = daftarLokasiResult;
    });
  }

  void hapusPencarian() {
    setState(() {
      controllerKodeBarang.text = '';
      isBarangDitemukan = false;
      isFormPencarianKosong = true;
      enableInput = true;
      mapDetailBarang = {};
      daftarLokasi = [];
      listKartuKontrol = [];
    });
  }

  List<String> radioKondisi = ["Baik", "Sedang", "Buruk"];
  String radioKondisiIndex = "Baik";
  late StateSetter _dialogKondisiStateSetter;
  void resetVariableDialogKartuKontrol() {
    setState(() {
      radioKondisiIndex = 'Baik';
      keterangan.text = '';
    });
  }

  void detectKeteranganInput() {
    setState(() {});
  }

  void tambahDataKontrol() {
    showDialog(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              _dialogKondisiStateSetter = setState;
              return AlertDialog(
                title: const Text('Tambah Data Kontrol'),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                                      onChanged: (dynamic value) {
                                        setState(() {
                                          _dialogKondisiStateSetter(() {
                                            radioKondisiIndex = value;
                                          });
                                        });
                                      },
                                    ),
                                  )
                                  .toList(),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        minLines: 4,
                        maxLines: null,
                        controller: keterangan,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          label: Text("Keterangan"),
                        ),
                        onChanged: (_) {
                          detectKeteranganInput();
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: Colors.black45),
                        onPressed: () {
                          resetVariableDialogKartuKontrol();
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'BATAL',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          var data = {
                            'nomer_kontrol': randomAlphaNumeric(6),
                            'tanggal': DateTime.now().millisecondsSinceEpoch,
                            'kode_barang': controllerKodeBarang.text,
                            'kondisi': radioKondisiIndex,
                            'keterangan': keterangan.text,
                          };
                          dbKartuKontrol.dbKartuKontrol(aksi: 'tambah', data: data, kodeBarang: controllerKodeBarang.text);
                          resetVariableDialogKartuKontrol();
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                        child: const Text(
                          'TAMBAH',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  )
                ],
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          elevation: 2,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 24, 0, 12),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextFormField(
                    enabled: enableInput,
                    controller: controllerKodeBarang,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      isDense: true,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(),
                      label: Text("Masukkan Kode Barang"),
                    ),
                    onChanged: (_) {
                      setState(() {
                        if (_.isEmpty) {
                          isFormPencarianKosong = true;
                        } else {
                          isFormPencarianKosong = false;
                        }
                      });
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: controllerKodeBarang.text.trim() != '' && enableInput == true
                      ? () {
                          cariKodeBarang(controllerKodeBarang.text);
                        }
                      : null,
                  child: const Text('CARI', style: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        ),
        !isBarangDitemukan
            ? Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(isFormPencarianKosong ? Icons.search : Icons.close, size: 48),
                    const SizedBox(height: 48),
                    Text(
                      isFormPencarianKosong ? 'Ketik kode barang lalu klik tombol cari' : 'Barang yang anda cari tidak ditemukan',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      containerDetailBarang(mapDetailBarang),
                      Container(
                        color: Colors.grey.shade200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              child: Text(
                                'Daftar Kartu Kontrol',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: const Text(
                                      'Tanggal',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      // textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: const Text(
                                      'Kondisi',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      widgetKartuKontrol(),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Widget containerDetailBarang(Map<String, dynamic> data) {
    int indexLokasi = daftarLokasi.indexWhere((e1) => e1["kodeLokasi"].toString() == data["kodeLokasi"].toString());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          color: Colors.grey.shade200,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Detail Barang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
                onPressed: () {
                  hapusPencarian();
                },
                child: const Text('HAPUS PENCARIAN'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: TextFormField(
                      enabled: false,
                      initialValue: data["jenisOrnamaBarang"],
                      decoration: const InputDecoration(labelText: 'Nama Barang'),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: TextFormField(
                      enabled: false,
                      initialValue: "${data["pabrik"]} - ${data["merkOrtipe"]}",
                      decoration: const InputDecoration(labelText: 'Merk/Tipe'),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: TextFormField(
                      enabled: false,
                      initialValue: indexLokasi != -1 ? daftarLokasi[indexLokasi]['namaLokasi'] : '-',
                      decoration: const InputDecoration(labelText: 'Lokasi'),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: TextFormField(
                      enabled: false,
                      initialValue: data['kategori'],
                      decoration: const InputDecoration(labelText: 'Kategori Barang'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                onPressed: () {
                  tambahDataKontrol();
                },
                child: const Text('TAMBAH DATA KONTROL'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24)
      ],
    );
  }

  Widget widgetKartuKontrol() {
    return StreamBuilder<List<Map<String, dynamic>>>(
        stream: dbKartuKontrol.getStream,
        initialData: listKartuKontrol,
        builder: (context, snapshot) {
          return Column(
            children: snapshot.data!.map((e) {
              return ExpansionTile(
                title: Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Text(
                        DateFormat.yMMMEd("id_ID").add_Hm().format(DateTime.fromMillisecondsSinceEpoch(e["tanggal"])),
                        style: const TextStyle(color: Colors.black),
                        // textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Text(
                        e['kondisi'],
                        style: const TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextFormField(
                      enabled: false,
                      initialValue: e['keterangan'].trim() != '' ? e['keterangan'] : '-',
                      decoration: const InputDecoration(labelText: 'Keterangan'),
                    ),
                  ),
                  const SizedBox(height: 24)
                ],
              );
            }).toList(),
          );
        });
  }
}
