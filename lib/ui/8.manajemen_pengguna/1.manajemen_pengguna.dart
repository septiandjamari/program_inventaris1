import 'package:flutter/material.dart';
import 'package:program_inventaris/ui/8.manajemen_pengguna/2.dialog_tambah_edit_pengguna.dart';

class ManajemenPengguna extends StatefulWidget {
  const ManajemenPengguna({Key? key}) : super(key: key);

  @override
  State<ManajemenPengguna> createState() => _ManajemenPenggunaState();
}

List<Map<String, dynamic>> listAkun = [
  {
    "id_user": "esqPpMy4",
    "username": "admin_riswanda",
    "real_name": "Riswanda Imawan",
    "password": "katasandi",
    "role": "Pegawai Invetaris",
    "privileges": "admin",
    "path_photo_profile": "",
  },
  {
    "id_user": "q2ydPfbfw3",
    "username": "ahli_sujadi",
    "real_name": "Ahli Sujadi",
    "password": "masahlisujadi123",
    "role": "Kepala Sekolah",
    "privileges": "viewer",
    "path_photo_profile": "",
  },
  {
    "id_user": "ght3DfrIop",
    "username": "super_admin",
    "real_name": "Super Admin",
    "password": "super_admin",
    "role": "Super Admin",
    "privileges": "super_admin",
    "path_photo_profile": "",
  },
];

class _ManajemenPenggunaState extends State<ManajemenPengguna> {
  bool hidePasswordVisibility = true;
  void addEditDialog({required String addOrEdit, Map<String, dynamic>? userData}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext ctx) {
        return DialogTambahEditPengguna(addOrEdit: addOrEdit, userData: userData);
      },
    );
  }

  void resetPassword({required String namaPengguna}) {
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
                        context: context,
                        builder: (BuildContext ctx1) {
                          return const ConfirmPasswordDialog(reConfirmPassword: false);
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
                  "${listAkun.length}",
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
              return ExpansionTile(
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
                            resetPassword(namaPengguna: e["real_name"]);
                          },
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text("RESET PASSWORD"),
                        )
                      ],
                    ),
                  )
                ],
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}

class ConfirmPasswordDialog extends StatefulWidget {
  final bool reConfirmPassword;
  const ConfirmPasswordDialog({Key? key, required this.reConfirmPassword}) : super(key: key);

  @override
  State<ConfirmPasswordDialog> createState() => _ConfirmPasswordDialogState();
}

class _ConfirmPasswordDialogState extends State<ConfirmPasswordDialog> {
  bool passwordVisibility = true;
  TextEditingController confirmPassword = TextEditingController(text: "");
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
                    context: context,
                    builder: (BuildContext ctx1) {
                      return const ConfirmPasswordDialog(reConfirmPassword: true);
                    });
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
