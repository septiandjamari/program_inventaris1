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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.blue.shade700),
              onPressed: () {},
              child: const Text("TAMBAH DATA"),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: listAkun.map((e) => Container()).toList(),
      )),
    );
  }
}
