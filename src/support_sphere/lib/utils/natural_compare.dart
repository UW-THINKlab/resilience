/// Compares strings the way people expect numbers to sort, e.g. "9 Oak St"
/// before "45 Main St" is wrong under plain string sort but "9" < "45" is
/// what naturalCompare gives, by splitting each string into alternating
/// runs of digits and non-digits and comparing numeric runs as numbers.
int naturalCompare(String a, String b) {
  final regExp = RegExp(r'(\d+|\D+)');
  final aParts = regExp.allMatches(a).map((m) => m.group(0)!).toList();
  final bParts = regExp.allMatches(b).map((m) => m.group(0)!).toList();

  for (var i = 0; i < aParts.length && i < bParts.length; i++) {
    final aNum = int.tryParse(aParts[i]);
    final bNum = int.tryParse(bParts[i]);
    final cmp = (aNum != null && bNum != null)
        ? aNum.compareTo(bNum)
        : aParts[i].compareTo(bParts[i]);
    if (cmp != 0) return cmp;
  }
  return aParts.length.compareTo(bParts.length);
}
