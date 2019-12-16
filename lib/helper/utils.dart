String toPersianNumber(String numberStr) {
  return numberStr
      .replaceAll('0', '۰')
      .replaceAll('0', '۰')
      .replaceAll('1', '۱')
      .replaceAll('2', '۲')
      .replaceAll('3', '۳')
      .replaceAll('4', '۴')
      .replaceAll('5', '۵')
      .replaceAll('6', '۶')
      .replaceAll('7', '۷')
      .replaceAll('8', '۸')
      .replaceAll('9', '۹');
}

String toPersianPrice(String priceStr) {
  String x = toPersianNumber(priceStr);

  String k = x[x.length - 1];
  for (int i = 1; i < x.length; i++) {
    if (i % 3 == 0) {
      k = ',' + k;
    }
    k = x[x.length - i - 1] + k;
  }

  return k;
}
