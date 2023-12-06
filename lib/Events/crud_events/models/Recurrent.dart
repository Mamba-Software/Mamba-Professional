class Recurrent {
  final DateTime? oneWeek;
  final DateTime? twoWeek;
  final DateTime? oneMonth;
  final DateTime? threeMonth;
  final DateTime? sixMonth;
  final DateTime? nineMonth;
  final DateTime? twelveMonth;
  final List<bool>? values;
  final int? value;

  Recurrent({
    this.oneWeek,
    this.twoWeek,
    this.oneMonth,
    this.threeMonth,
    this.sixMonth,
    this.nineMonth,
    this.twelveMonth,
    this.values,
    this.value,
  });

  Recurrent copyWith({
    DateTime? oneWeek,
    DateTime? twoWeek,
    DateTime? oneMonth,
    DateTime? threeMonth,
    DateTime? sixMonth,
    DateTime? nineMonth,
    DateTime? twelveMonth,
    List<bool>? values,
    int? value,
  }) {
    return Recurrent(
      oneWeek: oneWeek ?? this.oneWeek,
      twoWeek: twoWeek ?? this.twoWeek,
      oneMonth: oneMonth ?? this.oneMonth,
      threeMonth: threeMonth ?? this.threeMonth,
      sixMonth: sixMonth ?? this.sixMonth,
      nineMonth: nineMonth ?? this.nineMonth,
      twelveMonth: twelveMonth ?? this.twelveMonth,
      values: values ?? this.values,
      value: value ?? this.value,
    );
  }
}
