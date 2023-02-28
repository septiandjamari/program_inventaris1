import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.addOrEdit == "add" ? "Tambah Data Pengguna" : "Edit Data Pengguna"),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Form(
          key: dialogFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                  ? Row(
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
                            privilegesField.text == widget.userData!["privileges"]
                        ? null
                        : () {}
                    : realNameField.text == "" && usernameField.text == "" && roleField.text == "" && privilegesField.text == ""
                        ? null
                        : () {},
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
