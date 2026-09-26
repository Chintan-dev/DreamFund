import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _usdFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 0,
  );

  static String formatINR(double amount) {
    return _inrFormat.format(amount);
  }

  static String formatUSD(double amount) {
    return _usdFormat.format(amount);
  }

  static String format(double amount, {String currencySymbol = '₹'}) {
    if (currencySymbol == '₹') {
      return formatINR(amount);
    } else {
      return _usdFormat.format(amount);
    }
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM yyyy').format(date);
  }

  static String formatFullDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}
