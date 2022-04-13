Map<int, String> d = {
  1: 'One',
  2: 'Two',
  3: 'Three',
  4: 'Four',
  5: 'Five',
  6: 'Six',
  7: 'Seven',
  8: 'Eight',
  9: 'Nine',
  10: 'Ten',
  11: 'Eleven',
  12: 'Twelve',
  13: 'Thirteen',
  14: 'Fourteen',
  15: 'Fifteen',
  16: 'Sixteen',
  17: 'Seventeen',
  18: 'Eighteen',
  19: 'Ninteen',
  20: 'Twenty',
  30: 'Thirty',
  40: 'Forty',
  50: 'Fifty',
  60: 'Sixty',
  70: 'Seventy',
  80: 'Eighty',
  90: 'Ninety',
  100: 'Hundred',
  1000: 'Thousand',
  100000: 'Lakh',
  10000000: 'Crore',
};

String numberToWords(int n) {
  if (n / 1000000000000 >= 1) {
    return (numberToWords(n ~/ 1000000000000)) + ' ' + (d[1000000000000] ?? '') + ' ' + (numberToWords(n % 1000000000000));
  } else if (n ~/ 1000000000 >= 1) {
    return (numberToWords(n ~/ 1000000000)) + ' ' + (d[1000000000] ?? '') + ' ' + (numberToWords(n % 1000000000));
  } else if (n ~/ 1000000 >= 1) {
    return (numberToWords(n ~/ 1000000)) + ' ' + (d[1000000] ?? '') + ' ' + (numberToWords(n % 1000000));
  } else if (n ~/ 1000 >= 1) {
    return (numberToWords(n ~/ 1000)) + ' ' + (d[1000] ?? '') + ' ' + (numberToWords(n % 1000));
  } else if (n ~/ 100 >= 1) {
    return (d[n ~/ 100] ?? '') + ' ' + (d[100] ?? '') + ' ' + (numberToWords(n % 100));
  } else if (n ~/ 10 > 1) {
    return (d[(n ~/ 10) * 10] ?? '') + ' ' + (numberToWords(n % 10));
  } else if (n != 0) {
    return (d[n] ?? '');
  } else if (n == 0) {
    return 'Zero';
  }
  return '-';
}

String convertIntoWords(int number) {
  if (number == 0) return "zero";
  if (number < 0) return "minus " + convertIntoWords(number.abs());
  String words = "";
  if ((number ~/ 10000000) > 0) {
    words += convertIntoWords(number ~/ 10000000) + " crores ";
    number %= 10000000;
  }
  if ((number ~/ 100000) > 0) {
    words += convertIntoWords(number ~/ 100000) + " lacs ";
    number %= 100000;
  }
  if ((number ~/ 1000) > 0) {
    words += convertIntoWords(number ~/ 1000) + " thousand ";
    number %= 1000;
  }
  if ((number ~/ 100) > 0) {
    words += convertIntoWords(number ~/ 100) + " hundred ";
    number %= 100;
  }
  if (number > 0) {
    var unitsMap = [
      "zero",
      "one",
      "two",
      "three",
      "four",
      "five",
      "six",
      "seven",
      "eight",
      "nine",
      "ten",
      "eleven",
      "twelve",
      "thirteen",
      "fourteen",
      "fifteen",
      "sixteen",
      "seventeen",
      "eighteen",
      "nineteen"
    ];
    var tensMap = ["zero", "ten", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"];
    if (number < 20) {
      words += unitsMap[number];
    } else {
      words += tensMap[number ~/ 10];
      if ((number % 10) > 0) words += " " + unitsMap[number % 10];
    }
  }
  return words;
}
