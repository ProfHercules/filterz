extension Helpers on int {
  int floorDivide(num withNum) => (this / withNum).floor();
  int lerp(num withNum, [double amount = 0.5]) =>
      (this * (1.0 - amount) + withNum * amount).round();

  int wrap(int minVal, int maxVal) {
    var val = this;
    if (this < maxVal && this > minVal) return this;

    final range = maxVal - minVal + 1;

    if (this < minVal) val += range * ((minVal - val).floorDivide(range) + 1);

    return minVal + (val - minVal) % range;
  }

  int map(num inputStart, num inputEnd, num outputStart, num outputEnd) {
    final inputRange = inputEnd - inputStart;
    final outputRange = outputEnd - outputStart;

    return (outputStart + (outputRange / inputRange) * (this - inputStart))
        .round();
  }
}
