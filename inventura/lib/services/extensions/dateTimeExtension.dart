extension DateTimeExtension on DateTime? {
  String get toStringFixed => this.toString().substring(0, this.toString().lastIndexOf(':'));
}
