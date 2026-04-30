import 'dart:convert';

import 'package:intl/intl.dart';

class Formatters {
  const Formatters._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  static final DateFormat _dateTime = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _date = DateFormat('dd/MM/yyyy');

  static String money(num value) => _currency.format(value);

  static String dateTime(DateTime? value) {
    if (value == null) return '--';
    return _dateTime.format(value.toLocal());
  }

  static String date(DateTime? value) {
    if (value == null) return '--';
    return _date.format(value.toLocal());
  }

  static String orderStatusLabel(String status) {
    switch (status) {
      case 'PENDING':
        return 'Chờ xác nhận';
      case 'CONFIRMED':
        return 'Đã xác nhận';
      case 'PREPARING':
        return 'Đang chuẩn bị';
      case 'READY_FOR_PICKUP':
        return 'Sẵn sàng lấy';
      case 'PICKED_UP':
        return 'Đã lấy hàng';
      case 'ON_THE_WAY':
        return 'Đang giao';
      case 'DELIVERED':
        return 'Đã giao';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  static String paymentMethodLabel(String method) {
    switch (method) {
      case 'COD':
        return 'Tiền mặt (COD)';
      case 'CREDIT_CARD':
        return 'Thẻ ngân hàng';
      case 'MOMO':
        return 'MoMo';
      case 'ZALOPAY':
        return 'ZaloPay';
      default:
        return method;
    }
  }

  static Map<String, dynamic>? parseAddressSnapshot(String? snapshot) {
    if (snapshot == null || snapshot.isEmpty) return null;
    try {
      final decoded = jsonDecode(snapshot);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
