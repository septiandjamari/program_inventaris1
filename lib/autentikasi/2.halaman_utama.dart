import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:program_inventaris/autentikasi/0.halaman_controller.dart';
import 'package:program_inventaris/autentikasi/auth_controller.dart';
import 'package:program_inventaris/global_database/4.pengaturan.dart';
import 'package:program_inventaris/ui/0.beranda/0.beranda.dart';
import 'package:program_inventaris/ui/1.daftar_item_barang/1.daftar_item_barang.dart';
import 'package:program_inventaris/ui/2.barang_keluar/1.daftar_barang_keluar.dart';
import 'package:program_inventaris/ui/3.master_lokasi/1.daftar_lokasi.dart';
import 'package:program_inventaris/ui/4.laporan_inventaris/1.laporan_inventaris_barang.dart';
import 'package:program_inventaris/ui/5.kartu_kontrol/1.kartu_kontrol.dart';

import 'package:program_inventaris/ui/6.pengaturan/1.pengaturan.dart';
import 'package:program_inventaris/ui/7.pengaturan_profiln/pengaturan_profil.dart';
import 'package:program_inventaris/ui/8.manajemen_pengguna/1.manajemen_pengguna.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({Key? key}) : super(key: key);

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  List<String> appbarTitle = [
    "Beranda",
    "Barang Masuk",
    "Barang Keluar",
    "Lokasi",
    "Laporan Barang",
    "Kartu Kontrol",
    "Pengaturan Aplikasi",
    "Pengaturan Profil",
    "Manajemen Pengguna"
  ];

  Map<String, dynamic> dataPengaturan = {"warnaTemaAplikasi": 0, "namaSekolah": ""};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    var mapResult = await streamDataPengaturanProvider.dataPengaturanValue(viewOrEditDataPengaturan: "view");
    setState(() {
      dataPengaturan = mapResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (halamanUtamaController.indexPage != 0) {
          halamanUtamaController.changeIndex(index: 0);
          return false;
        } else {
          return true;
        }
      },
      child: StreamBuilder<List<int>>(
        stream: streamLoginState.getStream,
        initialData: streamLoginState.loginState,
        builder: (context, snapshot) {
          bool isAdmin;
          if (snapshot.data![1] == 1) {
            isAdmin = true;
          } else {
            isAdmin = false;
          }
          return StreamBuilder<Map<String, dynamic>>(
              stream: streamDataPengaturanProvider.getStream,
              builder: (context, snapshot0) {
                if (snapshot0.hasData) {
                  int colorThemeIndex = snapshot0.data!["warnaTemaAplikasi"];
                  return Theme(
                    data: ThemeData(
                      primarySwatch: appThemeColorList[colorThemeIndex],
                      inputDecorationTheme: const InputDecorationTheme(
                        labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    child: Scaffold(
                      appBar: AppBar(
                        title: StreamBuilder<int>(
                            stream: halamanUtamaController.getStream,
                            initialData: halamanUtamaController.indexPage,
                            builder: (context, snapshot1) {
                              return FittedBox(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: snapshot1.data! == 0
                                      ? GestureDetector(
                                          onTap: () {
                                            halamanUtamaController.changeIndex(index: 4);
                                          },
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text("Inventaris Sekolah", style: TextStyle(fontSize: 18)),
                                              Text(snapshot0.data!["namaSekolah"] != "" ? snapshot0.data!["namaSekolah"] : "Ubah Nama Sekolah",
                                                  style: TextStyle(fontSize: snapshot0.data!["namaSekolah"] != "" ? 16 : 14)),
                                            ],
                                          ),
                                        )
                                      : Text(appbarTitle[snapshot1.data!]),
                                ),
                              );
                            }),
                        actions: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  isAdmin ? "ADMIN" : "PEMERHATI",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      drawer: InventarisDrawer(colorThemeIndex: colorThemeIndex),
                      body: StreamBuilder<int>(
                          stream: halamanUtamaController.getStream,
                          initialData: halamanUtamaController.indexPage,
                          builder: (context, snapshot1) {
                            int index = snapshot1.data!;
                            List<Widget> halaman = [
                              Beranda(colorThemeIndex: colorThemeIndex),
                              const DaftarItemBarang(),
                              const DaftarBarangKeluar(),
                              const MasterLokasi(),
                              HalamanLaporan(colorThemeIndex: colorThemeIndex),
                              const KartuKontrol(),
                              const HalamanPengaturan(),
                              const HalamanPengaturanProfil(),
                              const ManajemenPengguna(),
                            ];
                            return halaman[index];
                          }),
                      // const DaftarBarang(),
                    ),
                  );
                } else {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              });
        },
      ),
    );
  }
}

class InventarisDrawer extends StatefulWidget {
  const InventarisDrawer({Key? key, required this.colorThemeIndex}) : super(key: key);
  final int colorThemeIndex;
  @override
  State<InventarisDrawer> createState() => _InventarisDrawerState();
}

class _InventarisDrawerState extends State<InventarisDrawer> {
  Map<String, dynamic> userInfo = {};
  Map<String, dynamic> mapPengaturan = {};
  bool showFakeLoading = true;
  void loadUserInfo() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      userInfo = jsonDecode(sp.getString("userDetail")!);
      mapPengaturan = jsonDecode(sp.getString("dataPengaturan")!);
      showFakeLoading = false;
    });
    if (kDebugMode) {
      print(userInfo);
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: halamanUtamaController.getStream,
      initialData: halamanUtamaController.indexPage,
      builder: (context, snapshot) {
        FocusScope.of(context).requestFocus(FocusNode());
        return Drawer(
          child: SingleChildScrollView(
            child: Column(
              children: [
                showFakeLoading == false
                    ? Container(
                        height: 200,
                        decoration: mapPengaturan["photo_banner_path"] != ""
                            ? BoxDecoration(
                                image: DecorationImage(
                                  image: Image.file(
                                    File(mapPengaturan["photo_banner_path"]),
                                  ).image,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : BoxDecoration(color: appThemeColorList[widget.colorThemeIndex]),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 80,
                              color: appThemeColorList[widget.colorThemeIndex].withOpacity(0.9),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 56,
                                      width: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: userInfo["path_photo_profile"] == ""
                                              ? const AssetImage('assets/images/foto-profile.jpg')
                                              : Image.file(
                                                  File(userInfo["path_photo_profile"]),
                                                ).image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    SizedBox(
                                      width: 160,
                                      child: FittedBox(
                                        fit: BoxFit.fitHeight,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${userInfo["real_name"]} (${userInfo["privileges"]})",
                                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: fontColor[widget.colorThemeIndex]),
                                            ),
                                            Text(
                                              userInfo["username"] != "" ? "Username : ${userInfo["username"]}" : "",
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: fontColor[widget.colorThemeIndex]),
                                            ),
                                            Text(
                                              userInfo["role"] != "" ? "Jabatan : ${userInfo["role"]}" : "",
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: fontColor[widget.colorThemeIndex]),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(),
                        )),
                const SizedBox(height: 24),
                const Text(
                  "Menu",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Column(
                            children: listTileMenuAplikasi.map((e) {
                              int listTileMenuAplikasiIndex = listTileMenuAplikasi.indexOf(e);
                              return ListTile(
                                dense: true,
                                selected: snapshot.data == listTileMenuAplikasiIndex ? true : false,
                                selectedColor: fontColor[widget.colorThemeIndex],
                                selectedTileColor: appThemeColorList[widget.colorThemeIndex],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                onTap: () {
                                  halamanUtamaController.changeIndex(index: listTileMenuAplikasiIndex);
                                  Navigator.of(context).pop();
                                },
                                leading: Icon(e.iconMenu),
                                title: Text(e.namaMenu),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 48),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Divider(
                              height: 40,
                              thickness: 2,
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: 1,
                            child: ElevatedButton(
                              onPressed: () {
                                AuthController.logout();
                              },
                              child: const Text(
                                "LOGOUT",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

List<ListTileMenuAplikasi> listTileMenuAplikasi = [
  ListTileMenuAplikasi(
    iconMenu: Icons.home,
    namaMenu: "Beranda",
  ),
  ListTileMenuAplikasi(
    iconMenu: Icons.inventory_outlined,
    namaMenu: "Barang Masuk",
  ),
  ListTileMenuAplikasi(
    iconMenu: Icons.output_outlined,
    namaMenu: "Barang Keluar",
  ),
  ListTileMenuAplikasi(
    iconMenu: Icons.pin_drop,
    namaMenu: "Lokasi",
  ),
  ListTileMenuAplikasi(
    iconMenu: Icons.note_alt_outlined,
    namaMenu: "Laporan Barang",
  ),
  ListTileMenuAplikasi(
    iconMenu: Icons.assignment,
    namaMenu: "Kartu Kontrol",
  ),
  ListTileMenuAplikasi(
    iconMenu: Icons.settings,
    namaMenu: "Pengaturan Aplikasi",
  ),
  ListTileMenuAplikasi(
    iconMenu: Icons.manage_accounts,
    namaMenu: "Pengaturan Profil",
  ),
  ListTileMenuAplikasi(
    iconMenu: Icons.group_add_rounded,
    namaMenu: "Manajemen Pengguna",
  ),
];

class ListTileMenuAplikasi {
  IconData iconMenu;
  String namaMenu;
  ListTileMenuAplikasi({required this.iconMenu, required this.namaMenu});
}
