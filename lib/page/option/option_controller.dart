import 'package:get/get.dart';
import 'package:celechron/database/database_helper.dart';
import 'package:celechron/model/user.dart';

class OptionController extends GetxController {
  final _db = Get.find<DatabaseHelper>(tag: 'db');
  final user = Get.find<Rx<User>>(tag: 'user');
  late final Rx<Duration> _workTime;
  late final Rx<Duration> _restTime;
  late final RxInt allowTimeLength;
  late final RxInt gpaStrategy;

  OptionController() {
    _workTime = _db.getWorkTime().obs;
    _restTime = _db.getRestTime().obs;
    allowTimeLength = _db.getAllowTime().length.obs;
    gpaStrategy = 1.obs;
  }

  Duration get workTime => _workTime.value;
  set workTime(Duration value) {
    _workTime.value = value;
    _db.setWorkTime(value);
  }

  Duration get restTime => _restTime.value;
  set restTime(Duration value) {
    _restTime.value = value;
    _db.setRestTime(value);
  }

  Map<DateTime, DateTime> get allowTime => _db.getAllowTime();
  set allowTime(Map<DateTime, DateTime> value) {
    _db.setAllowTime(value);
    allowTimeLength.value = value.length;
  }

  void logout() {
    user.value.logout();
    user.refresh();
  }
}
