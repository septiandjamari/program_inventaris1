import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:program_inventaris/global_database/5.manajemen_akun.dart';
import 'package:program_inventaris/ui/8.manajemen_pengguna/2.dialog_tambah_edit_pengguna.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManajemenPengguna extends StatefulWidget {
  const ManajemenPengguna({Key? key}) : super(key: key);

  @override
  State<ManajemenPengguna> createState() => _ManajemenPenggunaState();
}

class _ManajemenPenggunaState extends State<ManajemenPengguna> {
  bool hidePasswordVisibility = true;
  Map<String, dynamic> userInfo = {};

  List<Map<String, dynamic>> listAkun = [];

  void loadListAkun() async {
    var initialData = await streamListAkunProvider.dataListAkunValue(viewOrEditListAkun: "list");
    setState(() {
      listAkun = initialData;
    });
    if (kDebugMode) {
      print(listAkun);
    }
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

  @override
  void initState() {
    super.initState();
    loadUserInfo();
    loadListAkun();
  }

  void addEditDialog({required String addOrEdit, Map<String, dynamic>? userData}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext ctx) {
        return DialogTambahEditPengguna(addOrEdit: addOrEdit, userData: userData);
      },
    );
  }

  void resetPassword({required String namaPengguna, required String idPengguna}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    const TextSpan(text: "Apakah anda yakin untuk me-reset password untuk user "),
                    TextSpan(style: const TextStyle(fontWeight: FontWeight.bold), text: namaPengguna),
                    const TextSpan(text: '?')
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: const [Text("Password = "), Text("password123", style: TextStyle(fontWeight: FontWeight.bold))],
              )
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext ctx1) {
                          return ConfirmPasswordDialog(reConfirmPassword: false, idPengguna: idPengguna,);
                        });
                  },
                  child: const Text("LANJUTKAN", style: TextStyle(color: Colors.black54)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: const Text("BATAL"),
                ),
                const SizedBox(width: 16),
              ],
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
        initialData: listAkun,
        stream: streamListAkunProvider.getStream,
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              elevation: 1,
              backgroundColor: Colors.white,
              title: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Data tersimpan : ",
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                      Text(
                        "${listAkun.length - 1}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black),
                      ),
                    ],
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.blue.shade700),
                    onPressed: () {
                      addEditDialog(addOrEdit: "add");
                    },
                    child: const Text("TAMBAH PENGGUNA"),
                  )
                ],
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: listAkun.map(
                  (e) {
                    int index = listAkun.indexOf(e) + 1;
                    return e["username"] != userInfo["username"]
                        ? ExpansionTile(
                            leading: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "$index.",
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                            title: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${e["real_name"]} - ",
                                  style: const TextStyle(color: Colors.black),
                                ),
                                Text(
                                  e["username"],
                                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              "${e["role"]} / ${e["privileges"]}",
                              style: const TextStyle(color: Colors.black54),
                            ),
                            children: [
                              const Divider(),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow.shade800),
                                      onPressed: () {
                                        addEditDialog(addOrEdit: "edit", userData: e);
                                      },
                                      icon: const Icon(Icons.edit_rounded),
                                      label: const Text("EDIT DATA"),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        resetPassword(namaPengguna: e["real_name"], idPengguna: e["id_user"]);
                                      },
                                      icon: const Icon(Icons.restart_alt_rounded),
                                      label: const Text("RESET PASSWORD"),
                                    )
                                  ],
                                ),
                              )
                            ],
                          )
                        : const SizedBox();
                  },
                ).toList(),
              ),
            ),
          );
        });
  }
}

class ConfirmPasswordDialog extends StatefulWidget {
  final bool reConfirmPassword;
  final String idPengguna;
  const ConfirmPasswordDialog({Key? key, required this.reConfirmPassword, required this.idPengguna}) : super(key: key);

  @override
  State<ConfirmPasswordDialog> createState() => _ConfirmPasswordDialogState();
}

class _ConfirmPasswordDialogState extends State<ConfirmPasswordDialog> {
  bool passwordVisibility = true;
  TextEditingController confirmPassword = TextEditingController(text: "");

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
    loadUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.reConfirmPassword == true ? "Password Anda Salah" : "Konfirmasi Password"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: MediaQuery.of(context).size.width),
          widget.reConfirmPassword
              ? const Text(
                  "Password yang anda masukkan sebelumnya salah, silahkan isi password kembali:",
                  style: TextStyle(fontSize: 12),
                )
              : const SizedBox(),
          const SizedBox(height: 24),
          TextFormField(
            obscureText: passwordVisibility,
            controller: confirmPassword,
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: const OutlineInputBorder(),
              label: const Text("Masukkan Password Anda"),
              suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      passwordVisibility == true ? passwordVisibility = false : passwordVisibility = true;
                    });
                  },
                  icon: Icon(passwordVisibility ? Icons.visibility : Icons.visibility_off)),
            ),
            onChanged: ((_) {
              setState(() {});
            }),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext ctx1) {
                    if (userInfo["password"] == confirmPassword.text) {
                      Future.delayed(const Duration(seconds: 2), () {
                        Navigator.pop(ctx1);
                      });
                    }

                    return userInfo["password"] == confirmPassword.text
                        ? AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check, color: Colors.green.shade600, size: 160),
                                const SizedBox(height: 16),
                                const Text(
                                  "Berhasil Mereset Password...",
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ConfirmPasswordDialog(reConfirmPassword: true, idPengguna: widget.idPengguna);
                  },
                );
              },
              child: const Text("LANJUTKAN", style: TextStyle(color: Colors.black54)),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("BATAL"),
            ),
            const SizedBox(width: 16),
          ],
        )
      ],
    );
  }
}
