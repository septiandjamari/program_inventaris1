import 'package:flutter/material.dart';

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
  var dialogFormKey = GlobalKey<FormState>();

  TextEditingController realNameField = TextEditingController(text: "");
  TextEditingController usernameField = TextEditingController(text: "");
  TextEditingController roleField = TextEditingController(text: "");
  TextEditingController privilegesField = TextEditingController(text: "");
  TextEditingController passwordField = TextEditingController(text: "");

  void addEditDialog({required String addOrEdit}) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(addOrEdit == "add" ? "Tambah Data Pengguna" : "Edit Data Pengguna"),
          content: Form(
            key: dialogFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: realNameField,
                  decoration: const InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(),
                    label: Text("Nama Lengkap"),
                  ),
                ),
                TextFormField(
                  controller: usernameField,
                  decoration: const InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(),
                    label: Text("Username"),
                  ),
                ),
                TextFormField(
                  controller: roleField,
                  decoration: const InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(),
                    label: Text("Jabatan Pegawai"),
                  ),
                ),
                TextFormField(
                  controller: privilegesField,
                  decoration: const InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(),
                    label: Text("Hak Istimewa"),
                  ),
                ),
                TextFormField(
                  controller: passwordField,
                  decoration: const InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(),
                    label: Text("Tanggal Input"),
                  ),
                ),
              ],
            ),
          ),
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
              child: const Text("TAMBAH DATA"),
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
                            addEditDialog(addOrEdit: "edit");
                          },
                          icon: const Icon(Icons.edit_rounded),
                          label: const Text("EDIT DATA"),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () {},
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
