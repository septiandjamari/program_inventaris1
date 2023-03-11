import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:program_inventaris/global_database/1.daftar_item_barang_provider.dart';
import 'package:program_inventaris/global_database/2.daftar_barang_keluar_provider.dart';
import 'package:program_inventaris/global_database/3.master_lokasi_provider.dart';

class HalamanLaporan extends StatefulWidget {
  const HalamanLaporan({Key? key, required this.colorThemeIndex}) : super(key: key);
  final int colorThemeIndex;

  @override
  State<HalamanLaporan> createState() => _HalamanLaporanState();
}

class _HalamanLaporanState extends State<HalamanLaporan> {
  @override
  void initState() {
    super.initState();
    loadData();
  }

  bool fakeLoading = true;
  bool filterApplied = false;

  List<Map<String, dynamic>> daftarLokasi = [];
  List<Map<String, dynamic>> daftarBarangMasuk = [];
  List<Map<String, dynamic>> daftarBarangMasukFilter = [];
  List<Map<String, dynamic>> daftarBarangKeluar = [];
  List<Map<String, dynamic>> daftarBarangKeluarFilter = [];

  DateTime? filterTglAwal;
  DateTime? filterTglAkhir;

  TextEditingController formFilterTglAwal = TextEditingController(text: '');
  TextEditingController formFilterTglAkhir = TextEditingController(text: '');

  void filterDatePicker({required startOrFinish}) async {
    DateTime? dtFilter = await showDatePicker(
      context: context,
      initialDate: startOrFinish == 'start' ? DateTime.now().subtract(const Duration(days: 7)) : DateTime.now(),
      firstDate: DateTime(2010, 1, 1),
      lastDate: DateTime.now(),
    );
    if (dtFilter != null) {
      setState(() {
        if (startOrFinish == 'start') {
          filterTglAwal = dtFilter;
          formFilterTglAwal.text = DateFormat('dd/MM/yyy').format(dtFilter);
        } else {
          filterTglAkhir = dtFilter.add(const Duration(days: 1));
          formFilterTglAkhir.text = DateFormat('dd/MM/yyy').format(dtFilter);
        }
      });
    }
    if (filterTglAwal != null && filterTglAkhir != null) {
      applyDateFilter();
    }
  }

  void applyDateFilter() {
    daftarBarangMasukFilter = [];
    daftarBarangKeluarFilter = [];
    for (Map<String, dynamic> element in daftarBarangMasuk) {
      if (element['dt_barang_masuk_diedit'] >= filterTglAwal!.millisecondsSinceEpoch &&
          element['dt_barang_masuk_diedit'] <= filterTglAkhir!.millisecondsSinceEpoch) {
        daftarBarangMasukFilter.add(element);
      }
    }
    for (Map<String, dynamic> element in daftarBarangKeluar) {
      if (element['dt_barang_keluar_diedit'] >= filterTglAwal!.millisecondsSinceEpoch &&
          element['dt_barang_keluar_diedit'] <= filterTglAkhir!.millisecondsSinceEpoch) {
        daftarBarangKeluarFilter.add(element);
      }
    }
    setState(() {
      filterApplied = true;
    });
  }

  void removeDateFilter() {
    setState(() {
      filterApplied = false;
      formFilterTglAwal.text = '';
      formFilterTglAkhir.text = '';
    });
  }

  void loadData() async {
    await Future.delayed(const Duration(seconds: 1));
    var daftarBarangMasukResult = await streamDaftarItemBarangProvider.daftarItemBarangValue(addEditDeleteViewListDaftarBarang: "list");
    daftarBarangMasukResult.sort((b, a) {
      return a['dt_barang_masuk_diedit'].compareTo(b['dt_barang_masuk_diedit']);
    });
    var daftarBarangKeluarResult = await streamDaftarBarangKeluarProvider.daftarBarangKeluarValue(addEditDeleteView: "list");
    daftarBarangKeluarResult.sort(
      (b, a) {
        return a['dt_barang_keluar_diedit'].compareTo(b['dt_barang_keluar_diedit']);
      },
    );
    var daftarLokasiResult = await streamMasterLokasiProvider.masterLokasiValue(addEditDeleteViewListMasterLokasi: "list");
    setState(() {
      daftarBarangMasuk = daftarBarangMasukResult;
      daftarBarangKeluar = daftarBarangKeluarResult;
      daftarLokasi = daftarLokasiResult;
      fakeLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: fakeLoading
          ? const Center(child: CircularProgressIndicator())
          : Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.grey.shade50,
                title: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: TextFormField(
                        readOnly: true,
                        onTap: () {
                          filterDatePicker(startOrFinish: 'start');
                        },
                        textAlign: TextAlign.center,
                        controller: formFilterTglAwal,
                        decoration: const InputDecoration(hintText: 'Tanggal Awal'),
                      ),
                    ),
                    Text("-", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Theme.of(context).colorScheme.primary)),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: TextFormField(
                        readOnly: true,
                        onTap: () {
                          filterDatePicker(startOrFinish: 'finish');
                        },
                        textAlign: TextAlign.center,
                        controller: formFilterTglAkhir,
                        decoration: const InputDecoration(hintText: 'Tanggal Selesai'),
                      ),
                    ),
                    // ElevatedButton(
                    //   style: ElevatedButton.styleFrom(primary: Colors.green.shade800),
                    //   onPressed: formFilterTglAwal.text.isEmpty && formFilterTglAkhir.text.isEmpty
                    //       ? null
                    //       : () {
                    //           applyDateFilter();
                    //         },
                    //   child: const Icon(Icons.search),
                    // ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
                      onPressed: formFilterTglAwal.text.isEmpty || formFilterTglAkhir.text.isEmpty
                          ? null
                          : () {
                              removeDateFilter();
                            },
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                bottom: TabBar(
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Colors.black45,
                  tabs: const [
                    Tab(icon: Icon(Icons.inventory_outlined), text: 'Barang Masuk'),
                    Tab(icon: Icon(Icons.output_outlined), text: 'Barang Keluar'),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  _dataTableBarangMasuk(listData: !filterApplied ? daftarBarangMasuk : daftarBarangMasukFilter),
                  _dataTableBarangKeluar(listData: !filterApplied ? daftarBarangKeluar : daftarBarangKeluarFilter),
                ],
              ),
            ),
    );
  }

  Widget _dataTableBarangMasuk({required List<Map<String, dynamic>> listData}) {
    return Column(
      children: [
        Container(
          color: Colors.grey.shade300,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.075,
                      child: const Text(
                        "No.",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.250,
                      child: const Text(
                        "Tgl. Edit",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.275,
                      child: const Text(
                        "Nama Barang",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.275,
                      child: const Text(
                        "Merk/Tipe",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.info_outline),
              ],
            ),
          ),
        ),
        listData.isEmpty
            ? const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: Text('Tidak ada daftar barang...', style: TextStyle(fontWeight: FontWeight.bold))),
              )
            : Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: listData.map((e) {
                      int indexOf = listData.indexOf(e);
                      int indexLokasi = daftarLokasi.indexWhere((e1) => e1["kodeLokasi"].toString() == e["kodeLokasi"].toString());
                      return Column(
                        children: [
                          ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 10),
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.075,
                                  child: Text(
                                    "${indexOf + 1}.",
                                    style: const TextStyle(fontSize: 12, color: Colors.black),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(right: 10),
                                  width: MediaQuery.of(context).size.width * 0.250,
                                  child: Text(
                                    DateFormat('dd-MM-yyyy').add_Hm().format(DateTime.fromMillisecondsSinceEpoch(e["dt_barang_masuk_diedit"])),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(right: 10),
                                  width: MediaQuery.of(context).size.width * 0.275,
                                  child: Text("${e["jenisOrnamaBarang"]}", style: const TextStyle(color: Colors.black)),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(right: 10),
                                  width: MediaQuery.of(context).size.width * 0.250,
                                  child: Text("${e["pabrik"]} - ${e["merkOrtipe"]}", style: const TextStyle(color: Colors.black)),
                                ),
                              ],
                            ),
                            children: [
                              const Divider(),
                              const Text('Detail Barang Masuk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: TextFormField(
                                      enabled: false,
                                      initialValue: DateFormat('dd-MM-yyyy').add_Hm().format(DateTime.fromMillisecondsSinceEpoch(e["dt_barang_masuk"])),
                                      decoration: const InputDecoration(labelText: 'Tgl. Input'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: TextFormField(
                                      enabled: false,
                                      initialValue: e['kodeitem'],
                                      decoration: const InputDecoration(labelText: 'No. Kode Barang'),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: TextFormField(
                                      enabled: false,
                                      initialValue: e['kategori'].trim() != '' ? e['kategori'] : '-',
                                      decoration: const InputDecoration(labelText: 'Kategori Barang'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: TextFormField(
                                      enabled: false,
                                      initialValue: e['kondisi'],
                                      decoration: const InputDecoration(labelText: 'Kondisi'),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                      initialValue: e['ukuran'].trim() != '' ? e['ukuran'] : '-',
                                      decoration: const InputDecoration(labelText: 'Ukuran'),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: TextFormField(
                                      enabled: false,
                                      initialValue: e['bahan'].trim() != '' ? e['bahan'] : '-',
                                      decoration: const InputDecoration(labelText: 'Bahan'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: TextFormField(
                                      enabled: false,
                                      initialValue: e['satuan'].trim() != '' ? e['satuan'] : '-',
                                      decoration: const InputDecoration(labelText: 'Satuan'),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: TextFormField(
                                      enabled: false,
                                      initialValue: e['tahunPembelian'].trim() != '' ? e['tahunPembelian'] : '-',
                                      decoration: const InputDecoration(labelText: 'Tahun Pembelian'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: TextFormField(
                                      enabled: false,
                                      initialValue: e['asalUsul'].trim() != '' ? e['asalUsul'] : '-',
                                      decoration: const InputDecoration(labelText: 'Asal Usul'),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: TextFormField(
                                      enabled: false,
                                      initialValue: e['harga'].trim() != '' ? e['harga'] : '-',
                                      decoration: const InputDecoration(labelText: 'Harga'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: TextFormField(
                                      enabled: false,
                                      initialValue: e['sumberDana'],
                                      decoration: const InputDecoration(labelText: 'Sumber Dana'),
                                    ),
                                  ),
                                ],
                              ),
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
                          ),
                          Container(height: 1, color: Colors.black54),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _dataTableBarangKeluar({required List<Map<String, dynamic>> listData}) {
    return Column(
      children: [
        Container(
          color: Colors.grey.shade300,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.075,
                      child: const Text(
                        "No.",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.250,
                      child: const Text(
                        "Tgl. Edit",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.275,
                      child: const Text(
                        "Nama Barang",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.275,
                      child: const Text(
                        "Merk/Tipe",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.info_outline),
              ],
            ),
          ),
        ),
        listData.isEmpty
            ? const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: Text('Tidak ada daftar barang...', style: TextStyle(fontWeight: FontWeight.bold))),
              )
            : Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: listData.map((e) {
                      int indexOf = listData.indexOf(e);
                      int indexBarang = daftarBarangMasuk.indexWhere((e1) => e1["kodeitem"] == e["id_barang"]);
                      int indexLokasiAwal =
                          indexBarang != -1 ? daftarLokasi.indexWhere((e1) => e1["kodeLokasi"] == daftarBarangMasuk[indexBarang]["kodeLokasi"]) : -1;
                      if (kDebugMode) {
                        print("listData = $e");
                        print("daftarBarangMasuk = ${daftarBarangMasuk[0]}");
                      }
                      int indexLokasiTerakhir = daftarLokasi.indexWhere((e1) => e1["kodeLokasi"].toString() == e["id_lokasi_terakhir"]);
                      return Column(
                        children: [
                          ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 10),
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.075,
                                  child: Text(
                                    "${indexOf + 1}.",
                                    style: const TextStyle(fontSize: 12, color: Colors.black),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(right: 10),
                                  width: MediaQuery.of(context).size.width * 0.250,
                                  child: Text(
                                    DateFormat('dd-MM-yyyy').add_Hm().format(DateTime.fromMillisecondsSinceEpoch(e["dt_barang_keluar_diedit"])),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(right: 10),
                                  width: MediaQuery.of(context).size.width * 0.275,
                                  child: Text("${indexBarang != -1 ? daftarBarangMasuk[indexBarang]["jenisOrnamaBarang"] : "Null"}",
                                      style: const TextStyle(color: Colors.black)),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(right: 10),
                                  width: MediaQuery.of(context).size.width * 0.250,
                                  child: Text(
                                      "${indexBarang != -1 ? daftarBarangMasuk[indexBarang]["pabrik"] : "Null"} - ${indexBarang != -1 ? daftarBarangMasuk[indexBarang]["merkOrtipe"] : "Null"}",
                                      style: const TextStyle(color: Colors.black)),
                                ),
                              ],
                            ),
                            children: [
                              const Divider(),
                              const Text('Detail Barang Keluar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: TextFormField(
                                      enabled: false,
                                      initialValue: DateFormat('dd-MM-yyyy').add_Hm().format(DateTime.fromMillisecondsSinceEpoch(e["dt_barang_keluar"])),
                                      decoration: const InputDecoration(labelText: 'Tgl. Input'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: TextFormField(
                                      enabled: false,
                                      initialValue: e['id_form'],
                                      decoration: const InputDecoration(labelText: 'No. Kode Form'),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: TextFormField(
                                      enabled: false,
                                      initialValue: indexLokasiAwal != -1
                                          ? daftarLokasi[indexLokasiAwal]['namaLokasi'].trim() != ''
                                              ? daftarLokasi[indexLokasiAwal]['namaLokasi']
                                              : '-'
                                          : "-",
                                      decoration: const InputDecoration(labelText: 'Lokasi Awal'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: TextFormField(
                                      enabled: false,
                                      initialValue: indexLokasiTerakhir != -1
                                          ? daftarLokasi[indexLokasiTerakhir]['namaLokasi'].trim() != ''
                                              ? daftarLokasi[indexLokasiTerakhir]['namaLokasi']
                                              : '-'
                                          : "-",
                                      decoration: const InputDecoration(labelText: 'Lokasi Terakhir'),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: TextFormField(
                                  enabled: false,
                                  maxLines: null,
                                  initialValue: e['keterangan'].trim() != '' ? e['keterangan'] : '-',
                                  decoration: const InputDecoration(labelText: 'Keterangan'),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                          Container(height: 1, color: Colors.black54),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
      ],
    );
  }
}
