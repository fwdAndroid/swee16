int calculatePercentage(int good, int missed) {
  final total = good + missed;
  return total > 0 ? ((good / total) * 100).round() : 0;
}

// Add this to your percentage_helper.dart
String calculateOverallPercentage(int totalGood, int totalMissed) {
  final totalShots = totalGood + totalMissed;
  if (totalShots == 0) return '0.0%'; // Handle division by zero case

  final percentage = (totalGood / totalShots) * 100;
  return '${percentage.toStringAsFixed(1)}%'; // Format to 1 decimal place
}
