import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StreamListAkunProvider {
  final dataListAkunStream = StreamController<List<Map<String, dynamic>>>.broadcast();
  Stream<List<Map<String, dynamic>>> get getStream => dataListAkunStream.stream;

  Future<List<Map<String, dynamic>>> dataListAkunValue({required String viewOrEditListAkun, Map<String, dynamic>? dataAkun, String? idPengguna}) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? stringListAkun = sp.getString("dataListAkun");

    List<Map<String, dynamic>> mapListAkun = List<Map<String, dynamic>>.from(jsonDecode(stringListAkun!));
    if (mapListAkun.isNotEmpty) {
      List<Map<String, dynamic>> listSelected = [];
      await Future.delayed(const Duration(milliseconds: 250), () {
        switch (viewOrEditListAkun) {
          case "select":
            listSelected.add(mapListAkun.firstWhere((element) => element["id_user"] == idPengguna));
            break;
          case "edit":
            int index = mapListAkun.indexWhere((element) => element["id_user"] == idPengguna);
            mapListAkun[index] = dataAkun!;
            listSelected.add(dataAkun);
            dataAkun.addAll({"expire_session": DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch});
            sp.setString("userDetail", jsonEncode(dataAkun));
            sp.setString("dataListAkun", jsonEncode(mapListAkun));
            break;
          case "list":
            break;
        }
      });
      await Future.delayed(Duration.zero, () {
        if (viewOrEditListAkun != "list") {
          dataListAkunStream.sink.add(listSelected);
          mapListAkun = listSelected;
        } else {
          dataListAkunStream.sink.add(mapListAkun);
        }
      });
    } else {
      await Future.delayed(Duration.zero, () {
        mapListAkun = listAkun;
        sp.setString("dataListAkun", jsonEncode(mapListAkun));
        dataListAkunStream.sink.add(mapListAkun);
      });
    }
    return mapListAkun;
  }
}

var streamListAkunProvider = StreamListAkunProvider();

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
  {
    "id_user": "Iopghfrt3D",
    "username": "super_admin1",
    "real_name": "Super Admin",
    "password": "super_admin",
    "role": "Super Admin",
    "privileges": "super_admin",
    "path_photo_profile": "",
  },
];
