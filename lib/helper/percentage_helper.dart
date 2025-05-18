int calculatePercentage(int good, int missed) {
  final total = good + missed;
  return total > 0 ? ((good / total) * 100).round() : 0;
}
