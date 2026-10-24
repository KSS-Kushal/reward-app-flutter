/// Presentation formatting helpers.
abstract final class Formatters {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// 1234567 -> "1,234,567"
  static String number(num value) {
    final isNegative = value < 0;
    final digits = value.abs().round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return '${isNegative ? '-' : ''}$buffer';
  }

  /// 1299 -> "₹1,299", 499.5 -> "₹499.50"
  static String price(num value, {String symbol = '₹'}) {
    final fixed = value.abs().toStringAsFixed(2).split('.');
    final whole = number(int.parse(fixed[0]));
    final cents = fixed[1] == '00' ? '' : '.${fixed[1]}';
    return '${value < 0 ? '-' : ''}$symbol$whole$cents';
  }

  /// 1500 -> "1.5K", 2300000 -> "2.3M"
  static String compact(num value) {
    final abs = value.abs();
    if (abs >= 1000000) return '${_trim(value / 1000000)}M';
    if (abs >= 1000) return '${_trim(value / 1000)}K';
    return number(value);
  }

  static String _trim(num value) {
    final text = value.toStringAsFixed(1);
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }

  /// "13 Oct 2026"
  static String date(DateTime value) {
    final local = value.toLocal();
    return '${local.day} ${_months[local.month - 1]} ${local.year}';
  }

  /// "13 Oct 2026, 4:05 PM"
  static String dateTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour < 12 ? 'AM' : 'PM';
    return '${date(local)}, $hour:$minute $period';
  }

  /// Relative time such as "5m ago", "3h ago", "2d ago".
  static String relative(DateTime value, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(value);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return date(value);
  }

  /// 75 -> "01:15"
  static String countdown(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
