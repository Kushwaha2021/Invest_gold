// Model
class GoldRate {
  final String date;
  final double buyRate;
  final double sellRate;

  GoldRate({required this.date, required this.buyRate, required this.sellRate});

  factory GoldRate.fromJson(Map<String, dynamic> json) {
    return GoldRate(
      date: json['todays_date'],
      buyRate: double.parse(json['buy_rate'].toString()),
      sellRate: double.parse(json['sell_rate'].toString()),
    );
  }
}
