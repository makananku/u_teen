import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat decimalFormat = NumberFormat.decimalPattern('id_ID');
}