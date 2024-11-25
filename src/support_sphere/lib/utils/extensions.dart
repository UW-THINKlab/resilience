extension StringExtensions on String {
  String capitalize() {
    return isEmpty
        ? ''
        : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
