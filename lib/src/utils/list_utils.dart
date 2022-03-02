extension ListExtension on List {
  E? firstOrNull<E>() {
    return this == null || this.isEmpty ? null : this.first;
  }

  bool isNullOrEmpty() {
    return this == null || this.isEmpty;
  }

  T tryGet<T>(int index) => index < 0 || index >= this.length ? null : this[index];
}
