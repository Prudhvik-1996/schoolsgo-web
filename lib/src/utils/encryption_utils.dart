int convStrToNum(String str) {
  var oneten = <String, int>{
    'one': 1,
    'two': 2,
    'three': 3,
    'four': 4,
    'five': 5,
    'six': 6,
    'seven': 7,
    'eight': 8,
    'nine': 9,
    'zero': 0,
  };
  return oneten[str] ?? -1;
}

String convNumToStr(int str) {
  var oneten = <int, String>{
    1: 'one',
    2: 'two',
    3: 'three',
    4: 'four',
    5: 'five',
    6: 'six',
    7: 'seven',
    8: 'eight',
    9: 'nine',
    0: 'zero',
  };
  return oneten[str] ?? "-";
}

String encrypt(int num) {
  return (num * 8985)
      .toString()
      .split("")
      .map((e) => int.parse(e))
      .map((e) => convNumToStr(e))
      .join("-")
      .split("")
      .map((e) => encryptChar(e))
      .join("");
}

int decrypt(String code) {
  return int.parse(code
          .split("")
          .map((e) => decryptChar(e))
          .join("")
          .split("-")
          .map((e) => convStrToNum(e))
          .join("")) ~/
      8985;
}

String encryptChar(String char) {
  switch (char) {
    case 'a':
      return "0";
    case 'b':
      return "1";
    case 'c':
      return "2";
    case 'd':
      return "3";
    case 'e':
      return "4";
    case 'f':
      return "5";
    case 'g':
      return "6";
    case 'h':
      return "7";
    case 'i':
      return "8";
    case 'j':
      return "9";
    case 'k':
      return "Z";
    case 'l':
      return "-";
    case 'm':
      return "A";
    case 'n':
      return "B";
    case 'o':
      return "C";
    case 'p':
      return "D";
    case 'q':
      return "E";
    case 'r':
      return "F";
    case 's':
      return "G";
    case 't':
      return "H";
    case 'u':
      return "I";
    case 'v':
      return "J";
    case 'w':
      return "K";
    case 'x':
      return "L";
    case 'y':
      return "M";
    case 'z':
      return "N";
    default:
      return "O";
  }
}

String decryptChar(String char) {
  switch (char) {
    case "0":
      return "a";
    case "1":
      return "b";
    case "2":
      return "c";
    case "3":
      return "d";
    case "4":
      return "e";
    case "5":
      return "f";
    case "6":
      return "g";
    case "7":
      return "h";
    case "8":
      return "i";
    case "9":
      return "j";
    case "Z":
      return "k";
    case "-":
      return "l";
    case "A":
      return "m";
    case "B":
      return "n";
    case "C":
      return "o";
    case "D":
      return "p";
    case "E":
      return "q";
    case "F":
      return "r";
    case "G":
      return "s";
    case "H":
      return "t";
    case "I":
      return "u";
    case "J":
      return "v";
    case "K":
      return "w";
    case "L":
      return "x";
    case "M":
      return "y";
    case "N":
      return "z";
    default:
      return "-";
  }
}
