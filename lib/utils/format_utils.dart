// lib/utils/format_utils.dart
String formatCurrency(double value) {
  // Format: Rp 1.234.000
  final intVal = value.round();
  final s = intVal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  return 'Rp $s';
}