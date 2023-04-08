import 'package:flutter/material.dart';
import 'package:program_inventaris/global_database/5.manajemen_akun.dart';
import 'package:program_inventaris/no_space_plugin.dart';
import 'package:random_string/random_string.dart';

class DialogTambahEditPengguna extends StatefulWidget {
  final String? addOrEdit;
  final Map<String, dynamic>? userData;
  const DialogTambahEditPengguna({Key? key, this.addOrEdit, this.userData}) : super(key: key);

  @override
  State<DialogTambahEditPengguna> createState() => _DialogTambahEditPenggunaState();
}

class _DialogTambahEditPenggunaState extends State<DialogTambahEditPengguna> {
  var dialogFormKey = GlobalKey<FormState>();

  TextEditingController realNameField = TextEditingController(text: "");
  TextEditingController usernameField = TextEditingController(text: "");
  TextEditingController roleField = TextEditingController(text: "");
  TextEditingController privilegesField = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    setState(() {
      if (widget.userData != null) {
        realNameField.text = widget.userData!["real_name"];
        usernameField.text = widget.userData!["username"];
        roleField.text = widget.userData!["role"];
        privilegesField.text = widget.userData!["privileges"];
      }
    });
  }

  void dialogSuccess() {
    FocusScope.of(context).requestFocus(FocusNode());
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext ctx1) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(ctx1);
        }).then((value) {
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pop(context);
          });
        });
        return AlertDialog(
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.addOrEdit == "add" ? "Tambah Data Pengguna" : "Edit Data Pengguna"),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                TextFormField(
                  controller: realNameField,
                  decoration: const InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(),
                    label: Text("Nama Lengkap"),
                  ),
                  onChanged: ((_) {
                    setState(() {});
                  }),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: usernameField,
                  inputFormatters: [
                    NoSpaceFormatter(),
                  ],
                  decoration: const InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(),
                    label: Text("Username"),
                  ),
                  onChanged: ((_) {
                    setState(() {});
                  }),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: roleField,
                  decoration: const InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(),
                    label: Text("Jabatan Pegawai"),
                    hintText: "Contoh : Pegawai Tata Usaha",
                  ),
                  onChanged: ((_) {
                    setState(() {});
                  }),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: privilegesField,
                  decoration: const InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(),
                    label: Text("Hak Istimewa"),
                  ),
                  onChanged: ((_) {
                    setState(() {});
                  }),
                ),
                const SizedBox(height: 16),
                widget.addOrEdit == "add"
                    ? Wrap(
                        children: const [
                          Icon(Icons.info_outline_rounded),
                          SizedBox(width: 8),
                          Text("DEFAULT PASSWORD : "),
                          Text(
                            "password123",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.addOrEdit == "edit"
                    ? realNameField.text == widget.userData!["real_name"] &&
                                usernameField.text == widget.userData!["username"] &&
                                roleField.text == widget.userData!["role"] &&
                                privilegesField.text == widget.userData!["privileges"] ||
                            realNameField.text == "" ||
                            usernameField.text == "" ||
                            roleField.text == "" ||
                            privilegesField.text == ""
                        ? null
                        : () {
                            streamListAkunProvider.dataListAkunValue(
                              viewOrEditListAkun: "edit_data",
                              dataAkun: {
                                "id_user": widget.userData!["id_user"],
                                "username": usernameField.text,
                                "real_name": realNameField.text,
                                "password": widget.userData!["password"],
                                "role": roleField.text,
                                "privileges": privilegesField.text,
                                "path_photo_profile": widget.userData!["path_photo_profile"],
                              },
                            );
                            dialogSuccess();
                          }
                    : realNameField.text == "" || usernameField.text == "" || roleField.text == "" || privilegesField.text == ""
                        ? null
                        : () {
                            streamListAkunProvider.dataListAkunValue(
                              viewOrEditListAkun: "add",
                              dataAkun: {
                                "id_user": randomAlphaNumeric(8),
                                "username": usernameField.text,
                                "real_name": realNameField.text,
                                "password": privilegesField.text == "super_admin" ? "super_admin" : "password123",
                                "role": roleField.text,
                                "privileges": privilegesField.text,
                                "path_photo_profile": "",
                              },
                            );
                            dialogSuccess();
                          },
                child: const Text("SIMPAN"),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                // style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("BATAL"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
