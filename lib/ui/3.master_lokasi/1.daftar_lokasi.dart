import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:program_inventaris/global_database/3.master_lokasi_provider.dart';
import 'package:program_inventaris/ui/3.master_lokasi/2.form_master_lokasi.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MasterLokasi extends StatefulWidget {
  const MasterLokasi({Key? key}) : super(key: key);

  @override
  State<MasterLokasi> createState() => _MasterLokasiState();
}

class _MasterLokasiState extends State<MasterLokasi> {
  int itemShow = 10;
  int currentPage = 0;
  int firstPage = 0;
  int lastPage = 0;

  int showingItemFrom = 0;
  int showingItemTo = 0;
  int showingItemOfMuchEntry = 0;

  bool showSearchBar = false;

  TextEditingController searchController = TextEditingController(text: "");

  List<Map<String, dynamic>> listBeforeFilter = [];
  List<Map<String, dynamic>> listAfterFilter = [];

  List<Map<String, dynamic>> daftarMasterLokasiValue = [];
  bool fakeloading = true;

  Map<String, dynamic> userInfo = {};
  @override
  void initState() {
    super.initState();
    loadUserInfo();
    loadDaftarMasterLokasiValue();
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

  void loadDaftarMasterLokasiValue() async {
    await Future.delayed(const Duration(seconds: 1));
    var initialData = await streamMasterLokasiProvider.masterLokasiValue(addEditDeleteViewListMasterLokasi: "list");
    setState(() {
      daftarMasterLokasiValue = initialData;
      showingItemFrom = 1;
      showingItemTo = initialData.length;
      showingItemOfMuchEntry = initialData.length;
      fakeloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
        stream: streamMasterLokasiProvider.getStream,
        initialData: daftarMasterLokasiValue,
        builder: (context, snapshot) {
          if (fakeloading == false) {
            if (kDebugMode) {
              print("snapshot.data!.length : ${snapshot.data!.length}");
            }
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
                            ? TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const FormMasterLokasi(addViewEdit: "add"),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.blue.shade700),
                                child: const Text("TAMBAH DATA"),
                              )
                            : const SizedBox(),
                        // TextButton.icon(
                        //   style: TextButton.styleFrom(primary: Colors.black),
                        //   onPressed: () {
                        //     setState(() {
                        //       if (showSearchBar) {
                        //         showSearchBar = false;
                        //       } else {
                        //         showSearchBar = true;
                        //       }
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
                bottom: showSearchBar
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
        });
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
                        "Kode Lokasi",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.275,
                      child: const Text(
                        "Nama Lokasi",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.275,
                      child: const Text(
                        "Keterangan",
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
                return Column(
                  children: [
                    ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 10),
                      title: Row(
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
                            child: Text("${e["kodeLokasi"]}", style: const TextStyle(color: Colors.black)),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 10),
                            width: MediaQuery.of(context).size.width * 0.275,
                            child: Text("${e["namaLokasi"]}", style: const TextStyle(color: Colors.black)),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 10),
                            width: MediaQuery.of(context).size.width * 0.250,
                            child: Text("${e["keterangan"]}", style: const TextStyle(color: Colors.black)),
                          ),
                        ],
                      ),
                      children: [
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
                                      builder: (context) => FormMasterLokasi(addViewEdit: "view", kodeLokasi: e["kodeLokasi"]),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.document_scanner),
                                label: const Text("Lihat Detail"),
                              ),
                            ),
                            userInfo["privileges"] == "admin" || userInfo["privileges"] == "super_admin"
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
                                                builder: (context) => FormMasterLokasi(addViewEdit: "edit", kodeLokasi: e["kodeLokasi"]),
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
  //               Material(
  //                 elevation: 2,
  //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
  //                 child: Container(
  //                   padding: const EdgeInsets.all(8),
  //                   child: PopupMenuButton(
  //                     onSelected: (dynamic _) {
  //                       setState(() {
  //                         if (_ == 0) {
  //                           itemShow = 10;
  //                         } else if (_ == 1) {
  //                           itemShow = 20;
  //                         } else if (_ == 2) {
  //                           itemShow = 50;
  //                         }
  //                       });
  //                     },
  //                     itemBuilder: (itemBuilder) => [
  //                       const PopupMenuItem(
  //                         value: 0,
  //                         child: Text("10 Items"),
  //                       ),
  //                       const PopupMenuItem(
  //                         value: 1,
  //                         child: Text("20 Items"),
  //                       ),
  //                       const PopupMenuItem(
  //                         value: 2,
  //                         child: Text("50 Items"),
  //                       ),
  //                     ],
  //                     child: Text(
  //                       "$itemShow Items",
  //                       style: const TextStyle(fontWeight: FontWeight.bold),
  //                     ),
  //                   ),
  //                 ),
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
