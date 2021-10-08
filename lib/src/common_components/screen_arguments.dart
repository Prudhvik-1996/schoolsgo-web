class ScreenArgumentsWithString {
  final String key;
  final String value;

  ScreenArgumentsWithString(this.key, this.value);
}

class ScreenArgumentsWithObject<T> {
  final String key;
  final T value;

  ScreenArgumentsWithObject(this.key, this.value);
}
