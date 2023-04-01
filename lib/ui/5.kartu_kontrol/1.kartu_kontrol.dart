import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:program_inventaris/global_database/1.daftar_item_barang_provider.dart';
import 'package:program_inventaris/global_database/3.master_lokasi_provider.dart';
import 'package:program_inventaris/global_database/6.kartu_kontrol.dart';
import 'package:random_string/random_string.dart';
import 'package:collection/collection.dart';

import '../../global_database/2.daftar_barang_keluar_provider.dart';

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
  List<Map<String, dynamic>> selectBarangDikembalikan = [];

  int setViewSubMenu = 0;

  TextEditingController controllerKodeBarang = TextEditingController(text: '');
  TextEditingController keterangan = TextEditingController(text: "");

  void cariKodeBarang(String kodeBarang) async {
    var detailBarangResult = await streamDaftarItemBarangProvider.selectDataBarang(kodeItem: kodeBarang);
    var selectBarangDikembalikanResult =
        await streamDaftarBarangKeluarProvider.daftarBarangKeluarValue(kodeBarang: kodeBarang, addEditDeleteView: "listBarangKeluarByKodeBarang");
    if (kDebugMode) {
      print('detailBarangResult = $detailBarangResult');
    }
    if (detailBarangResult.isNotEmpty) {
      var dbKartuKontrolResult = await dbKartuKontrol.dbKartuKontrol(aksi: 'list', kodeBarang: kodeBarang);
      setState(() {
        isBarangDitemukan = true;
        isFormPencarianKosong = false;
        enableInput = false;
        mapDetailBarang = detailBarangResult;
        listKartuKontrol = dbKartuKontrolResult;
        selectBarangDikembalikan = selectBarangDikembalikanResult;
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

  void tambahDataKontrol({required String idLokasi}) {
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
                            'status_history': 'regular_checking',
                            'kondisi': radioKondisiIndex,
                            'id_lokasi': idLokasi,
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
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                        elevation: setViewSubMenu == 0 ? 4 : 0,
                                        backgroundColor: setViewSubMenu == 0 ? null : Colors.grey[400],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          setViewSubMenu = 0;
                                        });
                                      },
                                      child: const Text(
                                        'Daftar Kartu Kontrol',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                        elevation: setViewSubMenu == 0 ? 0 : 4,
                                        backgroundColor: setViewSubMenu == 0 ? Colors.grey[400] : null,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          setViewSubMenu = 1;
                                        });
                                      },
                                      child: const Text(
                                        'Riwayat Perpindahan Barang',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
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
                      setViewSubMenu == 0 ? widgetKartuKontrol() : riwayatPerpindahanBarang(),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Widget containerDetailBarang(Map<String, dynamic> data) {
    int indexLokasi = daftarLokasi.indexWhere((e1) => e1["kodeLokasi"].toString() == data["kodeLokasi"].toString());
    int indexLokasi1 = daftarLokasi.indexWhere((e1) => e1["kodeLokasi"].toString() == selectBarangDikembalikan[0]["id_lokasi_terakhir"].toString());
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(foregroundColor: Colors.red.shade700, backgroundColor: Colors.grey.shade50),
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
                      decoration: const InputDecoration(labelText: 'Lokasi Awal'),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: TextFormField(
                      enabled: false,
                      initialValue: indexLokasi1 != -1 ? daftarLokasi[indexLokasi1]['namaLokasi'] : '-',
                      decoration: const InputDecoration(labelText: 'Lokasi Akhir'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                    onPressed: selectBarangDikembalikan[0]["dikembalikan"] == true
                        ? () {
                            tambahDataKontrol(idLokasi: data[indexLokasi]["kodeLokasi"]);
                          }
                        : null,
                    child: const Text('TAMBAH DATA KONTROL'),
                  ),
                  selectBarangDikembalikan[0]["dikembalikan"] == true
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.only(top: 12, right: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.info_outline,
                                color: Colors.black38,
                                size: 14,
                              ),
                              SizedBox(width: 8),
                              Text('Barang Masih Dipinjam', style: TextStyle(color: Colors.black38, fontSize: 14)),
                            ],
                          ),
                        ),
                ],
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

  Widget riwayatPerpindahanBarang() {
    return StreamBuilder<List<Map<String, dynamic>>>(
        stream: dbKartuKontrol.getStream,
        initialData: listKartuKontrol,
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              children: snapshot.data!.reversed.mapIndexed(
                (index, e) {
                  int indexLokasi = daftarLokasi.indexWhere((e1) => e1["kodeLokasi"].toString() == e["id_lokasi"].toString());
                  return e['status_history'] != 'regular_checking'
                      ? ListTile(
                          iconColor: e['status_history'] == 'first_time_input'
                              ? Colors.green.shade700
                              : e['status_history'] == 'item_borrowed'
                                  ? Colors.red.shade600
                                  : Colors.yellow.shade700,
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(e['status_history'] == 'first_time_input'
                                  ? Icons.south
                                  : e['status_history'] == 'item_borrowed'
                                      ? Icons.north_east
                                      : Icons.call_received),
                            ],
                          ),
                          title: Text(
                            e['status_history'] == 'first_time_input'
                                ? "Barang Diinput Pertama Kali"
                                : e['status_history'] == 'item_borrowed'
                                    ? "Barang Dipinjamkan"
                                    : "Barang Dikembalikan",
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Waktu : ${DateFormat.yMMMEd("id_ID").add_Hm().format(DateTime.fromMillisecondsSinceEpoch(e["tanggal"]))}"),
                              Text('Lokasi : ${indexLokasi != -1 ? daftarLokasi[indexLokasi]["namaLokasi"] : '-'}'),
                            ],
                          ),
                        )
                      : const SizedBox();
                },
              ).toList(),
            ),
          );
        });
  }
}
