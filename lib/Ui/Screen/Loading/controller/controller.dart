import 'package:get/get.dart';
import '../../../../../Core/core.dart';
import '../../../../../Core/Service/session_lease.dart';
import '../../../../Data/data.dart';

class LoadingController extends GetxController {
  AppControllerX app = Get.find();
  SessionLeaseX? _readyLease;
  int _request = 0;

  Future<void> init() async {
    final request = ++_request;
    _readyLease = null;
    final ready = await app.init();
    if (isClosed || request != _request || ready?.isCurrent != true) return;
    _readyLease = ready;
  }

  void finish() {
    if (_readyLease?.isCurrent != true) return;
    _readyLease = null;
    Get.offAllNamed(LocalDataX.route);
  }
}
