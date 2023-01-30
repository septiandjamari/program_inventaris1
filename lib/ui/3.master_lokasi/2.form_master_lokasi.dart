import 'package:flutter/material.dart';
import 'package:program_inventaris/global_database/3.master_lokasi_provider.dart';
import 'package:random_string/random_string.dart';

class FormMasterLokasi extends StatefulWidget {
  const FormMasterLokasi({Key? key, required this.addViewEdit, this.kodeLokasi}) : super(key: key);
  final String? kodeLokasi;
  final String addViewEdit;
  @override
  State<FormMasterLokasi> createState() => _FormMasterLokasiState();
}

class _FormMasterLokasiState extends State<FormMasterLokasi> {
  final _formKey = GlobalKey<FormState>();
  bool isLoaded = false;
  TextEditingController kodeLokasi = TextEditingController(text: "");
  TextEditingController namaLokasi = TextEditingController(text: "");
  TextEditingController keterangan = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    if (widget.addViewEdit != "add") {
      loadData();
    } else {
      kodeLokasi.text = 'Lokasi-${randomNumeric(4)}';
      isLoaded = true;
    }
  }

  void loadData() async {
    var mapResult = await streamMasterLokasiProvider.selectLokasi(kodeLokasi: widget.kodeLokasi!);
    setState(() {
      kodeLokasi.text = mapResult["kodeLokasi"];
      namaLokasi.text = mapResult["namaLokasi"];
      keterangan.text = mapResult["keterangan"];
      isLoaded = true;
    });
  }

  void saveData() {
    if (_formKey.currentState!.validate()) {
      dialogSuccess();
      Map<String, dynamic> mapLokasi = {
        "kodeLokasi": kodeLokasi.text,
        "namaLokasi": namaLokasi.text,
        "keterangan": keterangan.text,
      };
      if (widget.addViewEdit == "add") {
        streamMasterLokasiProvider.addDataLokasi(dataMasterLokasi: mapLokasi);
      } else {
        streamMasterLokasiProvider.editDataLokasi(dataMasterLokasi: mapLokasi, kodeLokasi: widget.kodeLokasi!);
      }
    } else {
      dialogFailed();
    }
  }

  void dialogSuccess() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogSuccessCtx) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            Navigator.pop(dialogSuccessCtx);
          });
          Future.delayed(const Duration(milliseconds: 2000), () {
            Navigator.pop(context);
          });
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, color: Colors.green.shade600, size: 160),
                const SizedBox(height: 16),
                Text(
                  widget.addViewEdit == "add" ? "Berhasil menambahkan data..." : "Berhasil mengedit data...",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        });
  }

  void dialogFailed() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext ctx) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          Navigator.pop(ctx);
        });
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.close, color: Colors.red.shade600, size: 160),
              const SizedBox(height: 16),
              const Text(
                "Silahkan isi form data yang dibutuhkan...",
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
    return Theme(
      data: ThemeData(
        fontFamily: 'Quicksand',
        primarySwatch: widget.addViewEdit == "add"
            ? Colors.blue
            : widget.addViewEdit == "view"
                ? Colors.green
                : Colors.yellow,
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: widget.addViewEdit == "add"
                      ? Colors.blue.shade700
                      : widget.addViewEdit == "view"
                          ? Colors.green.shade700
                          : Colors.yellow.shade700)),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black54)),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: widget.addViewEdit == "add"
              ? Colors.blue.shade700
              : widget.addViewEdit == "view"
                  ? Colors.green.shade700
                  : Colors.yellow.shade700,
          title: Text(widget.addViewEdit == "add"
              ? "Tambah Lokasi"
              : widget.addViewEdit == "view"
                  ? "Lihat Lokasi"
                  : "Edit Lokasi"),
          actions: widget.addViewEdit != "view"
              ? [
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: widget.addViewEdit == "edit" ? Colors.black : Colors.white),
                    onPressed: () {
                      saveData();
                    },
                    child: const Text("SIMPAN"),
                  ),
                ]
              : [],
        ),
        body: isLoaded
            ? Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      children: [
                        TextFormField(
                          enabled: false,
                          controller: kodeLokasi,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: OutlineInputBorder(),
                            label: Text("Kode. Lokasi"),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Data harus di isi";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: namaLokasi,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: OutlineInputBorder(),
                            label: Text("Nama. Lokasi"),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Data harus di isi";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          minLines: 4,
                          maxLines: null,
                          controller: keterangan,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: OutlineInputBorder(),
                            label: Text("Keterangan Lokasi"),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Data harus di isi";
                            } else {
                              return null;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 24),
                    Text("Memuat Data", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
      ),
    );
  }
}
