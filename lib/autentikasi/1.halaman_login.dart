import 'dart:convert';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:program_inventaris/autentikasi/auth_controller.dart';
import 'package:program_inventaris/global_database/2.daftar_barang_keluar_provider.dart';
import 'package:program_inventaris/global_database/3.master_lokasi_provider.dart';
import 'package:program_inventaris/global_database/5.manajemen_akun.dart' as manajemen_akun;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:program_inventaris/global_database/1.daftar_item_barang_provider.dart';

class HalamanLogin extends StatefulWidget {
  const HalamanLogin({Key? key}) : super(key: key);

  @override
  State<HalamanLogin> createState() => _HalamanLoginState();
}

class _HalamanLoginState extends State<HalamanLogin> {
  TextEditingController username = TextEditingController(text: "");
  TextEditingController password = TextEditingController(text: "");
  bool isPasswordVisible = false;
  List<Map<String, dynamic>> listAkun = [];
  bool isSuperAdminLogiPage = false;

  @override
  void initState() {
    super.initState();
    setInitialGlobalDatabaseValue();
  }

  void setInitialGlobalDatabaseValue() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> listAkunResult;
    if (sp.getString("dataListAkun") == null) {
      sp.setString("dataListAkun", jsonEncode(manajemen_akun.listAkun));
      setState(() {
        listAkun = manajemen_akun.listAkun;
      });
    } else {
      listAkunResult = await manajemen_akun.streamListAkunProvider.dataListAkunValue(viewOrEditListAkun: "list");
      setState(() {
        listAkun = listAkunResult;
      });
    }

    if (sp.getString("listItemBarang") == null) {
      sp.setString("listItemBarang", jsonEncode(masterListItemBarang));
    }

    if (sp.getString("listBarangKeluar") == null) {
      sp.setString("listBarangKeluar", jsonEncode(masterlistBarangKeluar));
    }

    if (sp.getString("listMasterLokasi") == null) {
      sp.setString("listMasterLokasi", jsonEncode(masterLokasiList));
    }

    if (sp.getString("dataPengaturan") == null) {
      sp.setString("dataPengaturan", jsonEncode({}));
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: height * 0.4,
              color: Colors.red,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.list_alt,
                      color: Colors.white,
                      size: height * 0.25,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Selamat datang di aplikasi inventaris mobile",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 36),
                  Text(isSuperAdminLogiPage == false
                      ? "Silahkan login dengan mengisi form username dan password dibawah ini: "
                      : "Silahkan Masukkan username dan password untuk super admin dibawah ini :\n\nDefault Username = super_admin Password = super_admin"),
                  isSuperAdminLogiPage == false
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            children: const [
                              Icon(Icons.info_outline_rounded),
                              SizedBox(width: 8),
                              Flexible(child: Text("Anda bisa mengubah nama username dan password setelah login di pengaturan akun")),
                            ],
                          ),
                        ),
                  const SizedBox(height: 36),
                  TextFormField(
                    controller: username,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Masukkan Username"),
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: password,
                    obscureText: isPasswordVisible == false ? true : false,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              if (isPasswordVisible == true) {
                                isPasswordVisible = false;
                              } else {
                                isPasswordVisible = true;
                              }
                            });
                          },
                          icon: Icon(isPasswordVisible == true ? Icons.visibility_off : Icons.visibility)),
                      label: const Text("Masukkan Password"),
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 36),
                  FractionallySizedBox(
                    widthFactor: 1,
                    child: TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.black, backgroundColor: Colors.red),
                      onPressed: username.text.isNotEmpty && password.text.isNotEmpty
                          ? () {
                              if (listAkun.firstWhereOrNull((element) => element["username"] == username.text) != null) {
                                Map<String, dynamic> item = listAkun.firstWhere((element) => element["username"] == username.text);
                                int index = listAkun.indexOf(item);
                                item.addAll({
                                  "expire_session": DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch,
                                  "role_level": isSuperAdminLogiPage == true ? "super_admin" : "ordinary_user"
                                });
                                if (listAkun[index]["password"] == password.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 4),
                                      content: Text(
                                        "Selamat Datang!!\nAnda masuk aplikasi sebagai ${listAkun[index]["privileges"]}",
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  );
                                  AuthController.login(
                                      mapUser: jsonEncode(item), userPrivilege: item["privileges"] == "admin" || item["privileges"] == "super_admin" ? 1 : 0);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 4),
                                      content: Text(
                                        "Password yang anda masukkan salah. Mohon periksa dan coba lagi",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                    content: Text(
                                      "Username Tidak Ditemukan",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                );
                              }
                            }
                          : null,
                      child: Text(
                        "LOGIN",
                        style:
                            TextStyle(fontWeight: FontWeight.bold, color: username.text.isNotEmpty && password.text.isNotEmpty ? Colors.white : Colors.black54),
                      ),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: 1,
                    child: TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.black, backgroundColor: Colors.red),
                      onPressed: () {
                        setState(() {
                          isSuperAdminLogiPage = isSuperAdminLogiPage == false ? true : false;
                        });
                      },
                      child: Text(
                        isSuperAdminLogiPage == false ? "LOGIN SEBAGAI SUPER ADMIN" : "LOGIN SEBAGAI PENGGUNA BIASA",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
