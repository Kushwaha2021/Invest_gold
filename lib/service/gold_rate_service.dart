import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/gold_rate_model.dart';

class GoldRateService {
  static Future<List<GoldRate>> fetchGoldRates(int daysToFetch) async {
    final response = await http.get(
      Uri.parse(
        'https://agent-marketing-api.gfau.augmont.com/api/goldsilverrate?metalType=gold&days=$daysToFetch',
      ),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['result']['data']['goldSilverRate'] as List)
          .map((item) => GoldRate.fromJson(item))
          .toList();
    } else {
      return [];
    }
  }
}
