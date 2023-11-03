class Recurrent {
  final DateTime? oneWeek;
  final DateTime? twoWeek;
  final DateTime? oneMonth;
  final DateTime? twoMonth;
  final DateTime? threeMonth;
  final List<bool>? values;
  final int? value;

  Recurrent({
    this.oneWeek,
    this.twoWeek,
    this.oneMonth,
    this.twoMonth,
    this.threeMonth,
    this.values,
    this.value,
  });

  Recurrent copyWith({
    DateTime? oneWeek,
    DateTime? twoWeek,
    DateTime? oneMonth,
    DateTime? twoMonth,
    DateTime? threeMonth,
    List<bool>? values,
    int? value,
  }) {
    return Recurrent(
      oneWeek: oneWeek ?? this.oneWeek,
      twoWeek: twoWeek ?? this.twoWeek,
      oneMonth: oneMonth ?? this.oneMonth,
      twoMonth: twoMonth ?? this.twoMonth,
      threeMonth: threeMonth ?? this.threeMonth,
      values: values ?? this.values,
      value: value ?? this.value,
    );
  }
}
