import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:program_inventaris/autentikasi/0.halaman_controller.dart';
import 'package:program_inventaris/global_database/4.pengaturan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HalamanPengaturan extends StatefulWidget {
  const HalamanPengaturan({Key? key}) : super(key: key);

  @override
  State<HalamanPengaturan> createState() => _HalamanPengaturanState();
}

class _HalamanPengaturanState extends State<HalamanPengaturan> {
  Map<String, dynamic> mapDataPengaturan = {};
  late int indexWarnaTema;
  bool loadCompletely = false;
  TextEditingController namaSekolah = TextEditingController(text: "");
  TextEditingController headerBaris1 = TextEditingController(text: "");
  TextEditingController headerBaris2 = TextEditingController(text: "");
  TextEditingController alamat = TextEditingController(text: "");
  TextEditingController noTelepon = TextEditingController(text: "");
  TextEditingController website = TextEditingController(text: "");
  TextEditingController email = TextEditingController(text: "");
  TextEditingController namaKepsek = TextEditingController(text: "");
  TextEditingController nipKepsek = TextEditingController(text: "");

  Map<String, dynamic> userInfo = {};

  void loadUserInfo() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      userInfo = jsonDecode(sp.getString("userDetail")!);
    });
    if (kDebugMode) {
      print(userInfo);
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
    loadUserInfo();
  }

  void ambilGambar({required Map<String, dynamic> dataToPass}) async {
    try {
      FilePickerResult? result = (await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      ));
      if (result != null) {
        Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
        String appDocumentsPath = appDocumentsDirectory.path;
        setState(() {
          // NOTE
          FileInfo addedProfileImage = FileInfo(file: File(result.files.single.path!));
          // Tulis file menggunakan path_provider
          String filePath = '$appDocumentsPath/photoProfile-${userInfo["id_user"]}.${result.files.single.extension}';
          File file = File(filePath);
          file.writeAsBytesSync(addedProfileImage.file.readAsBytesSync());

          dataToPass.addAll({
            "warnaTemaAplikasi": indexWarnaTema,
          });
          dataToPass["photo_banner_path"] = filePath;
          streamDataPengaturanProvider.dataPengaturanValue(
            viewOrEditDataPengaturan: "edit",
            dataPengaturan: dataToPass,
          );
          dialogSuccess();
        });
        if (kDebugMode) {
          print("berhasil menambahkan file...");
        }
      } else {
        if (kDebugMode) {
          print("gagal menambahkan file...");
        }
      }
    } catch (ex) {
      if (kDebugMode) {
        print(ex);
      }
    }
  }

  void loadData() async {
    Map<String, dynamic> mapResult = await streamDataPengaturanProvider.dataPengaturanValue(viewOrEditDataPengaturan: "view");
    setState(() {
      mapDataPengaturan = mapResult;
      namaSekolah.text = mapResult["namaSekolah"];
      headerBaris1.text = mapResult["headerBaris1"];
      headerBaris2.text = mapResult["headerBaris2"];
      alamat.text = mapResult["alamat"];
      noTelepon.text = mapResult["noTelepon"];
      website.text = mapResult["website"];
      email.text = mapResult["email"];
      namaKepsek.text = mapResult["namaKepsek"];
      nipKepsek.text = mapResult["nipKepsek"];
      indexWarnaTema = mapResult["warnaTemaAplikasi"];
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        loadCompletely = true;
      });
    });
  }

  void dialogSuccess() {
    FocusScope.of(context).requestFocus(FocusNode());
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogSuccessCtx) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            Navigator.pop(dialogSuccessCtx);
          });
          Future.delayed(const Duration(milliseconds: 2000), () {
            halamanUtamaController.changeIndex(index: 0);
          });
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, color: Colors.green.shade600, size: 160),
                const SizedBox(height: 16),
                const Text("Berhasil mengedit data..."),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
        stream: streamDataPengaturanProvider.getStream,
        initialData: mapDataPengaturan,
        builder: (context, snapshot) {
          bool saveButton;
          if (kDebugMode) {
            print(snapshot.data.toString());
          }
          Map<String, dynamic> mapSnapshot = {
            "namaSekolah": snapshot.data!["namaSekolah"],
            "headerBaris1": snapshot.data!["headerBaris1"],
            "headerBaris2": snapshot.data!["headerBaris2"],
            "alamat": snapshot.data!["alamat"],
            "noTelepon": snapshot.data!["noTelepon"],
            "website": snapshot.data!["website"],
            "email": snapshot.data!["email"],
            "namaKepsek": snapshot.data!["namaKepsek"],
            "nipKepsek": snapshot.data!["nipKepsek"],
            "photo_banner_path": snapshot.data!["photo_banner_path"],
          };
          Map<String, dynamic> mapFromForm = {
            "namaSekolah": namaSekolah.text,
            "headerBaris1": headerBaris1.text,
            "headerBaris2": headerBaris2.text,
            "alamat": alamat.text,
            "noTelepon": noTelepon.text,
            "website": website.text,
            "email": email.text,
            "namaKepsek": namaKepsek.text,
            "nipKepsek": nipKepsek.text,
            "photo_banner_path": snapshot.data!["photo_banner_path"],
          };
          if (mapEquals(mapSnapshot, mapFromForm)) {
            saveButton = false;
          } else {
            saveButton = true;
          }
          return loadCompletely
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        userInfo["privileges"] == "admin"
                            ? const SizedBox()
                            : Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Text(
                                      "* Anda Hanya Bisa Mengedit Warna Tema Aplikasi",
                                      style: TextStyle(color: Colors.red.shade700),
                                    ),
                                  ),
                                ],
                              ),
                        Container(
                          height: 200,
                          decoration: snapshot.data!["photo_banner_path"] != ""
                              ? BoxDecoration(
                                  image: DecorationImage(
                                    image: Image.file(
                                      File(snapshot.data!["photo_banner_path"]),
                                    ).image,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const BoxDecoration(color: Colors.grey),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: ElevatedButton(
                                  onPressed: userInfo["privileges"] == "admin" ? () {
                                    ambilGambar(dataToPass: mapSnapshot);
                                  } : null,
                                  child: const Text("Ubah Gambar Banner")),
                            ),
                          ],
                        ),
                        TextFormField(
                          enabled: userInfo["privileges"] == "admin" ? true : false,
                          controller: namaSekolah,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            label: Text("Nama Sekolah"),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Data harus di isi";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (_) {
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: userInfo["privileges"] == "admin" ? true : false,
                          controller: headerBaris1,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            label: Text("Header Baris 1"),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Data harus di isi";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (_) {
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: userInfo["privileges"] == "admin" ? true : false,
                          controller: headerBaris2,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            label: Text("Header Baris 2"),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Data harus di isi";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (_) {
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: userInfo["privileges"] == "admin" ? true : false,
                          controller: alamat,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            label: Text("Alamat Sekolah"),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Data harus di isi";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (_) {
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: userInfo["privileges"] == "admin" ? true : false,
                          controller: noTelepon,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            label: Text("No. Telepon"),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Data harus di isi";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (_) {
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: userInfo["privileges"] == "admin" ? true : false,
                          controller: website,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            label: Text("Alamat Website"),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Data harus di isi";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (_) {
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: userInfo["privileges"] == "admin" ? true : false,
                          controller: email,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            label: Text("Alamat Email"),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Data harus di isi";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (_) {
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: userInfo["privileges"] == "admin" ? true : false,
                          controller: namaKepsek,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            label: Text("Nama Kepala Sekolah"),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Data harus di isi";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (_) {
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: userInfo["privileges"] == "admin" ? true : false,
                          controller: nipKepsek,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            label: Text("NIP Kepala Sekolah"),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Data harus di isi";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (_) {
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: saveButton == true
                              ? () {
                                  mapFromForm.addAll({
                                    "warnaTemaAplikasi": indexWarnaTema,
                                  });
                                  streamDataPengaturanProvider.dataPengaturanValue(
                                    viewOrEditDataPengaturan: "edit",
                                    dataPengaturan: mapFromForm,
                                  );
                                  dialogSuccess();
                                }
                              : null,
                          child: const Text("SIMPAN"),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "* Pengaturan digunakan untuk melengkapi data detail sekolah pada laporan inventaris, dan header nama untuk aplikasi",
                          style: TextStyle(fontSize: 11),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Text(
                                  "Ubah Warna Tema Aplikasi",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: appThemeColorList.map((e) {
                                int index = appThemeColorList.indexOf(e);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      indexWarnaTema = index;
                                    });
                                    mapSnapshot.addAll({
                                      "warnaTemaAplikasi": index,
                                    });
                                    streamDataPengaturanProvider.dataPengaturanValue(
                                      viewOrEditDataPengaturan: "edit",
                                      dataPengaturan: mapSnapshot,
                                    );
                                  },
                                  child: Stack(
                                    alignment: AlignmentDirectional.center,
                                    children: [
                                      Container(
                                        height: 64,
                                        width: 64,
                                        decoration: BoxDecoration(
                                          color: e,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      index == indexWarnaTema
                                          ? Icon(
                                              Icons.check,
                                              size: 40,
                                              color: fontColor[indexWarnaTema],
                                            )
                                          : const SizedBox(),
                                    ],
                                  ),
                                );
                              }).toList(),
                            )
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 24),
                      Text("Memuat Data...", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
        });
  }
}

class FileInfo {
  File file;
  FileInfo({required this.file});
}
