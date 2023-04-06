import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:program_inventaris/autentikasi/0.halaman_controller.dart';
import 'package:program_inventaris/global_database/4.pengaturan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Beranda extends StatefulWidget {
  const Beranda({Key? key, required this.colorThemeIndex}) : super(key: key);
  final int colorThemeIndex;

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  Map<String, dynamic> userInfo = {};
  List<CardMenuAplikasi> cardMenuAplikasi1 = [];
  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  void loadUserInfo() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      userInfo = jsonDecode(sp.getString("userDetail")!);
      for (CardMenuAplikasi e in cardMenuAplikasi) {
        if (userInfo["role_level"] == "ordinary_user" && e.roleAccess == "ordinary_user" ||
            userInfo["role_level"] == "super_admin" && e.roleAccess == "super_admin" ||
            e.roleAccess == "all") {
          cardMenuAplikasi1.add(e);
        }
      }
    });
    if (kDebugMode) {
      print(userInfo);
      print("cardMenuAplikasi1.length ${cardMenuAplikasi1.length}");
    }
  }

  @override
  Widget build(BuildContext context) {
    double length = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 48),
          Row(),
          Card(
            color: appThemeColorList[widget.colorThemeIndex],
            elevation: 4,
            child: SizedBox(
              width: length * 0.9,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "Selamat Datang ${userInfo["real_name"]},",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: fontColor[widget.colorThemeIndex]),
                      ),
                    ),
                    Text(
                      "Anda masuk aplikasi inventaris sebagai - ${userInfo["privileges"]}",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: fontColor[widget.colorThemeIndex]),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          Column(
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 16,
                runSpacing: 16,
                children: cardMenuAplikasi1.map((e) {
                  int index = cardMenuAplikasi.indexOf(e);
                  return userInfo["role_level"] == "ordinary_user" && e.roleAccess == "ordinary_user" ||
                          userInfo["role_level"] == "super_admin" && e.roleAccess == "super_admin" ||
                          e.roleAccess == "all"
                      ? Card(
                          color: appThemeColorList[widget.colorThemeIndex],
                          elevation: 4,
                          child: InkWell(
                            onTap: () {
                              halamanUtamaController.changeIndex(index: index + 1);
                            },
                            child: Container(
                              width: length * 0.4,
                              height: length * 0.4,
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(e.iconMenu, size: length * 0.25, color: fontColor[widget.colorThemeIndex]),
                                  Text(
                                    e.namaMenu,
                                    style: TextStyle(fontWeight: FontWeight.bold, color: fontColor[widget.colorThemeIndex]),
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container();
                }).toList(),
              ),
              SizedBox(height: length * 0.1),
            ],
          )
        ],
      ),
    );
  }
}

List<CardMenuAplikasi> cardMenuAplikasi = [
  CardMenuAplikasi(
    iconMenu: Icons.inventory_outlined,
    namaMenu: "Barang Masuk",
    roleAccess: "ordinary_user",
  ),
  CardMenuAplikasi(
    iconMenu: Icons.output_outlined,
    namaMenu: "Barang Keluar",
    roleAccess: "ordinary_user",
  ),
  CardMenuAplikasi(
    iconMenu: Icons.pin_drop,
    namaMenu: "Lokasi",
    roleAccess: "ordinary_user",
  ),
  CardMenuAplikasi(
    iconMenu: Icons.note_alt_outlined,
    namaMenu: "Laporan Barang",
    roleAccess: "ordinary_user",
  ),
  CardMenuAplikasi(
    iconMenu: Icons.assignment,
    namaMenu: "Kartu Kontrol",
    roleAccess: "ordinary_user",
  ),
  CardMenuAplikasi(
    iconMenu: Icons.settings,
    namaMenu: "Pengaturan Aplikasi",
    roleAccess: "super_admin",
  ),
  CardMenuAplikasi(
    iconMenu: Icons.manage_accounts,
    namaMenu: "Pengaturan Profil",
    roleAccess: "all",
  ),
  CardMenuAplikasi(
    iconMenu: Icons.group_add_rounded,
    namaMenu: "Manajemen Pengguna",
    roleAccess: "super_admin",
  ),
];

class CardMenuAplikasi {
  IconData iconMenu;
  String namaMenu;
  String roleAccess;
  CardMenuAplikasi({required this.iconMenu, required this.namaMenu, required this.roleAccess});
}
