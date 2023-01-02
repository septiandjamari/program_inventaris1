import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:program_inventaris/global_database/1.daftar_item_barang_provider.dart';
import 'package:program_inventaris/global_database/2.daftar_barang_keluar_provider.dart';
import 'package:program_inventaris/global_database/3.master_lokasi_provider.dart';
import 'package:program_inventaris/ui/2.barang_keluar/2.form_barang_keluar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DaftarBarangKeluar extends StatefulWidget {
  const DaftarBarangKeluar({Key? key}) : super(key: key);

  @override
  State<DaftarBarangKeluar> createState() => _DaftarBarangKeluarState();
}

class _DaftarBarangKeluarState extends State<DaftarBarangKeluar> {
  int itemShow = 10;
  int currentPage = 0;
  int firstPage = 0;
  int lastPage = 0;

  int showingItemFrom = 0;
  int showingItemTo = 0;
  int showingItemOfMuchEntry = 0;

  bool showSearchBar = false;
  bool showFilterBar = false;

  TextEditingController searchController = TextEditingController(text: "");

  List<Map<String, dynamic>> listBeforeFilter = [];
  List<Map<String, dynamic>> listAfterFilter = [];

  List<Map<String, dynamic>> daftarItemBarang = [];
  List<Map<String, dynamic>> daftarLokasi = [];
  List<Map<String, dynamic>> daftarBarangKeluar = [];
  bool fakeloading = true;
  Map<String, dynamic> userInfo = {};

  @override
  void initState() {
    super.initState();
    loadUserInfo();
    loadDaftarBarangKeluarValue();
  }

  void loadUserInfo() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      userInfo = jsonDecode(sp.getString("userDetail")!);
    });
    if (kDebugMode) {
      print(userInfo);
    }
  }

  void loadDaftarBarangKeluarValue() async {
    await Future.delayed(const Duration(seconds: 1));
    var initialData = await streamDaftarBarangKeluarProvider.daftarBarangKeluarValue(addEditDeleteView: "list");
    var daftarLokasiResult = await streamMasterLokasiProvider.masterLokasiValue(addEditDeleteViewListMasterLokasi: "list");
    var daftarItemBarangResult = await streamDaftarItemBarangProvider.daftarItemBarangValue(addEditDeleteViewListDaftarBarang: "list");
    setState(() {
      daftarBarangKeluar = initialData;
      daftarLokasi = daftarLokasiResult;
      daftarItemBarang = daftarItemBarangResult;
      showingItemFrom = 1;
      showingItemTo = initialData.length;
      showingItemOfMuchEntry = initialData.length;
      fakeloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: streamDaftarBarangKeluarProvider.getStream,
      initialData: daftarBarangKeluar,
      builder: (context, snapshot) {
        if (fakeloading == false) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Menampilkan",
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "$showingItemFrom - ${snapshot.data!.length}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black),
                          ),
                          const Text(
                            " dari ",
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                          Text(
                            "${snapshot.data!.length}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black),
                          ),
                          const Text(
                            " data",
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      userInfo["privileges"] == "admin" || userInfo["privileges"] == "super_admin"
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const FormBarangKeluar(addViewEdit: "add"),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.blue.shade700),
                                child: const Text(
                                  "TAMBAH DATA",
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                            )
                          : const SizedBox(),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                      //   child: TextButton(
                      //     onPressed: () {
                      //       setState(() {
                      //         if (showFilterBar) {
                      //           showFilterBar = false;
                      //         } else {
                      //           showFilterBar = true;
                      //         }
                      //         showSearchBar = false;
                      //       });
                      //     },
                      //     style: TextButton.styleFrom(backgroundColor: Colors.pinkAccent, primary: Colors.white),
                      //     child: const Text(
                      //       "FILTER LOKASI",
                      //       style: TextStyle(fontSize: 10),
                      //     ),
                      //   ),
                      // ),
                      // TextButton.icon(
                      //   style: TextButton.styleFrom(primary: Colors.black),
                      //   onPressed: () {
                      //     setState(() {
                      //       if (showSearchBar) {
                      //         showSearchBar = false;
                      //       } else {
                      //         showSearchBar = true;
                      //       }
                      //       showFilterBar = false;
                      //     });
                      //   },
                      //   icon: const Icon(Icons.search),
                      //   label: const Text("CARI"),
                      // ),
                    ],
                  ),
                ],
              ),
              backgroundColor: Colors.blueGrey.shade50,
              bottom: showSearchBar || showFilterBar
                  ? PreferredSize(
                      preferredSize: Size.fromHeight(AppBar().preferredSize.height),
                      child: showSearchBar
                          ? Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.70,
                                  child: TextFormField(
                                    controller: searchController,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      label: const Text("Masukkan Kata Kunci"),
                                      suffixIcon: TextButton(
                                        onPressed: searchController.text.trim() == "" ? null : () {},
                                        child: const Text("CARI"),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      showSearchBar = false;
                                      searchController.text = "";
                                    });
                                  },
                                  child: const Text("BATALKAN", style: TextStyle(color: Colors.black)),
                                ),
                              ],
                            )
                          : showFilterBar
                              ? Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.75,
                                      child: ListTile(
                                        onTap: () {},
                                        leading: const Icon(Icons.filter_list_alt),
                                        title: const Text("FILTER LOKASI"),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          showFilterBar = false;
                                        });
                                      },
                                      child: const Text("BATALKAN", style: TextStyle(color: Colors.black)),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                    )
                  : null,
            ),
            body: _dataTable(listData: snapshot.data!),
            // bottomNavigationBar: _bottomNavigation(),
          );
        } else {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 24),
                Text("Memuat Data...", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _dataTable({required List<Map<String, dynamic>> listData}) {
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
                        "No. Barang",
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
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: listData.map((e) {
                int indexOf = listData.indexOf(e);
                int indexBarang = daftarItemBarang.indexWhere((e1) => e1["kodeitem"].toString() == e["id_barang"]);
                int indexLokasiAwal = daftarLokasi.indexWhere((e1) => e1["kodeLokasi"].toString() == daftarItemBarang[indexBarang]["kodeLokasi"]);
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
                            child: Text("${e["id_form"]}", style: const TextStyle(color: Colors.black)),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 10),
                            width: MediaQuery.of(context).size.width * 0.275,
                            child: Text("${daftarItemBarang[indexBarang]["jenisOrnamaBarang"]}", style: const TextStyle(color: Colors.black)),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 10),
                            width: MediaQuery.of(context).size.width * 0.250,
                            child: Text("${daftarItemBarang[indexBarang]["pabrik"]} - ${daftarItemBarang[indexBarang]["merkOrtipe"]}",
                                style: const TextStyle(color: Colors.black)),
                          ),
                        ],
                      ),
                      children: [
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.075,
                              ),
                              Container(
                                padding: const EdgeInsets.only(right: 10),
                                width: MediaQuery.of(context).size.width * 0.275,
                                child: const Text("Lokasi Awal", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                padding: const EdgeInsets.only(right: 10),
                                width: MediaQuery.of(context).size.width * 0.275,
                                child: const Text("Lokasi Terakhir", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.075,
                              ),
                              Container(
                                padding: const EdgeInsets.only(right: 10),
                                width: MediaQuery.of(context).size.width * 0.275,
                                child: indexLokasiAwal == -1
                                    ? Text("Lokasi Belum Ditentukan", style: TextStyle(color: Colors.red.shade900))
                                    : Text("${daftarLokasi[indexLokasiAwal]["namaLokasi"]}"),
                              ),
                              Container(
                                padding: const EdgeInsets.only(right: 10),
                                width: MediaQuery.of(context).size.width * 0.275,
                                child: indexLokasiTerakhir == -1
                                    ? Text("Lokasi Belum Ditentukan", style: TextStyle(color: Colors.red.shade900))
                                    : Text("${daftarLokasi[indexLokasiTerakhir]["namaLokasi"]}"),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextButton.icon(
                                style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.green.shade700),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FormBarangKeluar(addViewEdit: "view", idForm: e["id_form"]),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.document_scanner),
                                label: const Text("Lihat Detail"),
                              ),
                            ),
                            (userInfo["privileges"] == "admin" || userInfo["privileges"] == "super_admin") && e['dikembalikan'] == false
                                ? Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: TextButton.icon(
                                          style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.yellow.shade700),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => FormBarangKeluar(addViewEdit: "edit", idForm: e["id_form"]),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.edit),
                                          label: const Text("Edit"),
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                          ],
                        )
                      ],
                    ),
                    Container(height: 0.5, color: Colors.black54),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // Widget _bottomNavigation() {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       Container(width: MediaQuery.of(context).size.width, height: 0.5, color: Colors.black54),
  //       Material(
  //         color: Colors.blueGrey.shade50,
  //         child: Container(
  //           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  //           height: 56,
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               Row(
  //                 children: [
  //                   Material(
  //                     elevation: 2,
  //                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
  //                     child: Container(
  //                       padding: const EdgeInsets.all(8),
  //                       child: PopupMenuButton(
  //                         onSelected: (dynamic _) {
  //                           setState(() {
  //                             if (_ == 0) {
  //                               itemShow = 10;
  //                             } else if (_ == 1) {
  //                               itemShow = 20;
  //                             } else if (_ == 2) {
  //                               itemShow = 50;
  //                             }
  //                           });
  //                         },
  //                         itemBuilder: (itemBuilder) => [
  //                           const PopupMenuItem(
  //                             value: 0,
  //                             child: Text("10 Items"),
  //                           ),
  //                           const PopupMenuItem(
  //                             value: 1,
  //                             child: Text("20 Items"),
  //                           ),
  //                           const PopupMenuItem(
  //                             value: 2,
  //                             child: Text("50 Items"),
  //                           ),
  //                         ],
  //                         child: Text(
  //                           "$itemShow Items",
  //                           style: const TextStyle(fontWeight: FontWeight.bold),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   IconButton(
  //                     icon: const Icon(Icons.chevron_left),
  //                     onPressed: () {},
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.all(4),
  //                     child: Row(
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         Text(currentPage.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //                         const Text(" / "),
  //                         Text(lastPage.toString(),
  //                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: lastPage == currentPage ? Colors.black : Colors.grey))
  //                       ],
  //                     ),
  //                   ),
  //                   IconButton(
  //                     icon: const Icon(Icons.chevron_right),
  //                     onPressed: () {},
  //                   ),
  //                 ],
  //               )
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
