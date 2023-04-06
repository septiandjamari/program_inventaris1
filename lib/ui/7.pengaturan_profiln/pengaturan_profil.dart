import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:program_inventaris/global_database/5.manajemen_akun.dart';
import 'package:program_inventaris/no_space_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HalamanPengaturanProfil extends StatefulWidget {
  const HalamanPengaturanProfil({Key? key}) : super(key: key);

  @override
  State<HalamanPengaturanProfil> createState() => _HalamanPengaturanProfilState();
}

class _HalamanPengaturanProfilState extends State<HalamanPengaturanProfil> {
  // String addedProfileImagePath = "";
  // FileInfo? addedProfileImage;
  TextEditingController realName = TextEditingController(text: "");
  TextEditingController username = TextEditingController(text: "");
  TextEditingController password = TextEditingController(text: "");
  bool passwordVisible = false;
  TextEditingController newPassword = TextEditingController(text: "");
  bool newPasswordVisible = false;
  TextEditingController reNewPassword = TextEditingController(text: "");
  bool reNewPasswordVisible = false;

  Map<String, dynamic> userInfo = {};
  void loadUserInfo() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    Map<String, dynamic> userDetailResult = jsonDecode(sp.getString("userDetail")!);
    var initialDataResult = await streamListAkunProvider.dataListAkunValue(viewOrEditListAkun: "select", idPengguna: userDetailResult["id_user"]);
    setState(() {
      userInfo = userDetailResult;

      realName.text = initialDataResult[0]["real_name"];
      username.text = initialDataResult[0]["username"];
    });
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
          dataToPass.addAll({"path_photo_profile": filePath});
          streamListAkunProvider.dataListAkunValue(viewOrEditListAkun: "edit", idPengguna: userInfo["id_user"], dataAkun: dataToPass);
          if (kDebugMode) {
            print("filePath $filePath");
            print("newAddedProfilePicture: $addedProfileImage");
          }
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

  void saveChanges({required Map<String, dynamic> dataToPass}) {
    streamListAkunProvider.dataListAkunValue(
      viewOrEditListAkun: "edit",
      idPengguna: userInfo["id_user"],
      dataAkun: dataToPass,
    );
  }

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
        stream: streamListAkunProvider.getStream,
        // initialData: initialStreamData,
        builder: (context, snapshot) {
          if (kDebugMode) {
            print("Terjadi perubahan data pada : ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}");
          }
          if (snapshot.hasData) {
            return SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // NOTE: container digunakan untuk container foto profil
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: snapshot.data![0]["path_photo_profile"] == ""
                              ? const AssetImage('assets/images/foto-profile.jpg')
                              : Image.file(
                                  File(snapshot.data![0]["path_photo_profile"]),
                                ).image,
                          fit: BoxFit.cover,
                        ),
                        boxShadow: const [BoxShadow(blurRadius: 1)]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ambilGambar(dataToPass: {
                        "id_user": snapshot.data![0]["id_user"],
                        "username": snapshot.data![0]["username"],
                        "real_name": snapshot.data![0]["real_name"],
                        "password": snapshot.data![0]["password"],
                        "role": snapshot.data![0]["role"],
                        "privileges": snapshot.data![0]["privileges"],
                      });
                    },
                    child: const Text("Ubah Foto Profil"),
                  ),
                  const SizedBox(height: 48),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Row(
                          children: const [
                            Text(
                              "Ubah Detail Akun",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: username,
                        inputFormatters: [
                          NoSpaceFormatter(),
                        ],
                        decoration: const InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(),
                          label: Text("Username"),
                        ),
                        onChanged: (_) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: realName,
                        decoration: const InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(),
                          label: Text("Nama Asli"),
                        ),
                        onChanged: (_) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: username.text.trim() != snapshot.data![0]["username"] || realName.text.trim() != snapshot.data![0]["real_name"]
                                ? () {
                                    streamListAkunProvider.dataListAkunValue(
                                      viewOrEditListAkun: "edit",
                                      idPengguna: userInfo["id_user"],
                                      dataAkun: {
                                        "id_user": snapshot.data![0]["id_user"],
                                        "username": username.text.trim(),
                                        "real_name": realName.text.trim(),
                                        "password": snapshot.data![0]["password"],
                                        "role": snapshot.data![0]["role"],
                                        "privileges": snapshot.data![0]["privileges"],
                                        "path_photo_profile": snapshot.data![0]["path_photo_profile"],
                                      },
                                    );
                                  }
                                : null,
                            child: const Text("Simpan Detail Akun"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text(
                              "Ubah Password (Opsional)",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: password,
                            obscureText: passwordVisible == false ? true : false,
                            decoration: InputDecoration(
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              border: const OutlineInputBorder(),
                              prefixIcon: snapshot.data![0]["password"] == password.text ? const Icon(Icons.check, color: Colors.green) : null,
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (passwordVisible == true) {
                                        passwordVisible = false;
                                      } else {
                                        passwordVisible = true;
                                      }
                                    });
                                  },
                                  icon: Icon(passwordVisible == true ? Icons.visibility_off : Icons.visibility)),
                              label: const Text("Password Lama"),
                            ),
                            onChanged: (_) {
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: newPassword,
                            obscureText: newPasswordVisible == false ? true : false,
                            decoration: InputDecoration(
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              border: const OutlineInputBorder(),
                              prefixIcon: newPassword.text.isEmpty
                                  ? null
                                  : newPassword.text != password.text
                                      ? const Icon(Icons.check, color: Colors.green)
                                      : const Icon(Icons.close, color: Colors.red),
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (newPasswordVisible == true) {
                                        newPasswordVisible = false;
                                      } else {
                                        newPasswordVisible = true;
                                      }
                                    });
                                  },
                                  icon: Icon(newPasswordVisible == true ? Icons.visibility_off : Icons.visibility)),
                              label: const Text("Password Baru"),
                            ),
                            onChanged: (_) {
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: reNewPassword,
                            obscureText: reNewPasswordVisible == false ? true : false,
                            decoration: InputDecoration(
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              border: const OutlineInputBorder(),
                              prefixIcon: reNewPassword.text.isEmpty
                                  ? null
                                  : reNewPassword.text == newPassword.text
                                      ? const Icon(Icons.check, color: Colors.green)
                                      : const Icon(Icons.close, color: Colors.red),
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (reNewPasswordVisible == true) {
                                        reNewPasswordVisible = false;
                                      } else {
                                        reNewPasswordVisible = true;
                                      }
                                    });
                                  },
                                  icon: Icon(reNewPasswordVisible == true ? Icons.visibility_off : Icons.visibility)),
                              label: const Text("Ulangi Password Baru"),
                            ),
                            onChanged: (_) {
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: password.text.trim() != "" &&
                                    password.text == snapshot.data![0]["password"] &&
                                    password.text.trim() != newPassword.text.trim() &&
                                    newPassword.text == reNewPassword.text
                                ? () {
                                    streamListAkunProvider.dataListAkunValue(
                                      viewOrEditListAkun: "edit",
                                      idPengguna: userInfo["id_user"],
                                      dataAkun: {
                                        "id_user": snapshot.data![0]["id_user"],
                                        "username": snapshot.data![0]["username"],
                                        "real_name": snapshot.data![0]["real_name"],
                                        "password": reNewPassword.text.trim(),
                                        "role": snapshot.data![0]["role"],
                                        "privileges": snapshot.data![0]["privileges"],
                                        "path_photo_profile": snapshot.data![0]["path_photo_profile"],
                                      },
                                    );
                                  }
                                : null,
                            child: const Text("Simpan Password Baru"),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ));
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
}

class FileInfo {
  File file;
  FileInfo({required this.file});
}
