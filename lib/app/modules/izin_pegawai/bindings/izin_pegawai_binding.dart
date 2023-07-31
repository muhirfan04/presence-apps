import 'package:get/get.dart';

import '../controllers/izin_pegawai_controller.dart';

class IzinPegawaiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IzinPegawaiController>(
      () => IzinPegawaiController(),
    );
  }
}
