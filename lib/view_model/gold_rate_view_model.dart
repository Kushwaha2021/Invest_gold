import 'package:flutter/material.dart';
import '../model/gold_rate_model.dart';

import '../service/gold_rate_service.dart';

class GoldRateViewModel extends ChangeNotifier {
  List<GoldRate> _goldRates = [];
  List<GoldRate> _filteredRates = [];
  bool _isLoading = false;
  String _sortOrder = 'none';
  int _days = 365;
  String _selectedRange = 'none';
  String _selectedRangeDisplay = 'Date Range';
  String _selectedSortDisplay = 'Sort';

  List<GoldRate> get goldRates => _filteredRates;

  bool get isLoading => _isLoading;

  String get selectedRange => _selectedRange;

  String get sortOrder => _sortOrder;

  String get selectedRangeDisplay => _selectedRangeDisplay;

  String get selectedSortDisplay => _selectedSortDisplay;

  Future<void> fetchGoldRates({int? customDays}) async {
    _isLoading = true;
    notifyListeners();

    int daysToFetch = customDays ?? _days;
    try {
      _goldRates = await GoldRateService.fetchGoldRates(daysToFetch);
      _sortRates();
    } catch (e) {
      print('Error fetching gold rates: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void setDays(int days, String range, String displayText) {
    _days = days;
    _selectedRange = range;
    _selectedRangeDisplay = displayText;
    fetchGoldRates();
  }

  void setCustomDays(DateTime start, DateTime end) {
    final days = end.difference(start).inDays + 1;
    _days = days;
    _selectedRange = 'custom';
    _selectedRangeDisplay = 'Custom';
    fetchGoldRates(customDays: days);
  }

  void sortRates(String order, String displayText) {
    _sortOrder = order;
    _selectedSortDisplay = displayText;
    _sortRates();
  }

  void _sortRates() {
    _filteredRates = List.from(_goldRates);
    if (_sortOrder != 'none') {
      _filteredRates.sort(
        (a, b) =>
            _sortOrder == 'asc'
                ? a.buyRate.compareTo(b.buyRate)
                : b.buyRate.compareTo(a.buyRate),
      );
    }
    notifyListeners();
  }
}
