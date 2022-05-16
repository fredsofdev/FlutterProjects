import 'package:bloc/bloc.dart';
import 'package:catchchanceio/repository/authentication/inventory_repository.dart';
import 'package:equatable/equatable.dart';

part 'mail_state.dart';

class MailCubit extends Cubit<MailState> {
  MailCubit(this._inventoryRepository, String myId)
      : assert(_inventoryRepository != null),
        super(const MailState()) {
    emit(state.updateState(myId: myId));
    getMail(myId);

    getNotice();
  }

  Future<void> getMail(String id) async {
    final data = await _inventoryRepository.listMail(id);
    if (data.isNotEmpty) {
      emit(state.updateState(mail: data));
    }
  }

  Future<void> getNotice() async {
    final data = await _inventoryRepository.listNotice();
    if (data.isNotEmpty) {
      emit(state.updateState(notice: data));
    }
  }

  Future<Map<String, dynamic>> getItem(String id, String collection) {
    return _inventoryRepository.getItem(id, collection);
  }

  Future<void> acceptItem({Map<String, dynamic>? datas, String? itemId}) async {
    final data = state.mail;

    for (final element in data) {
      if (element['id'] == itemId && datas != null) {
        element.addAll({'desc': datas['s_desc'], 'title': datas['title']});
      }
    }
    final int index = data.indexWhere((element) => element['id'] == itemId);

    if (data[index]['product_type'] == "Coupon") {
      await _inventoryRepository.acceptItems(state.myId, data[index]);
    } else {
      data[index]
          .addAll({'itemType': datas?['type'], 'amount': datas?['amount']});
      await _inventoryRepository.acceptSendItem(state.myId, data[index]);
    }
    final List<Map<String, dynamic>> mail = [];
    mail.addAll(state.mail);
    mail.removeWhere((element) => element['id'] == itemId);
    emit(state.updateState(mail: mail));
  }

  void removeItem(String id) {
    final data = state.notice;
    data.removeWhere((element) => element['id'] == id);
    emit(state.updateState(notice: data));
  }

  final InventoryRepository _inventoryRepository;
}
