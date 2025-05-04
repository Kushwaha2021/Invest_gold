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
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  List<GoldRate> get goldRates => _filteredRates;
  bool get isLoading => _isLoading;
  String get selectedRange => _selectedRange;
  String get sortOrder => _sortOrder;
  String get selectedRangeDisplay => _selectedRangeDisplay;
  String get selectedSortDisplay => _selectedSortDisplay;
  DateTime? get customStartDate => _customStartDate;
  DateTime? get customEndDate => _customEndDate;

  Future<void> fetchGoldRates({int? customDays}) async {
    _isLoading = true;
    // Store current state to preserve it
    final preservedRange = _selectedRange;
    final preservedDisplay = _selectedRangeDisplay;
    final preservedStart = _customStartDate;
    final preservedEnd = _customEndDate;
    notifyListeners();

    int daysToFetch = customDays ?? _days;
    try {
        _goldRates = await GoldRateService.fetchGoldRates(daysToFetch);
        print('Fetched ${_goldRates.length} rates: ${_goldRates.map((r) => r.date).toList()}');
        _filterAndSortRates();
    } catch (e) {
      print('Error fetching gold rates: $e');
    }

    // Restore preserved state
    _selectedRange = preservedRange;
    _selectedRangeDisplay = preservedDisplay;
    _customStartDate = preservedStart;
    _customEndDate = preservedEnd;
    _isLoading = false;
    notifyListeners();
  }

  void setDays(int days, String range, String displayText) {
    _days = days;
    _selectedRange = range;
    _selectedRangeDisplay = displayText;
    _customStartDate = null;
    _customEndDate = null;
    fetchGoldRates();
  }

  void setCustomDays(DateTime start, DateTime end) {
    _customStartDate = start;
    _customEndDate = end;
    _selectedRange = 'custom';
    _selectedRangeDisplay = '${_formatDate(start.toString())} - ${_formatDate(end.toString())}';
    print('Set custom range: $_selectedRangeDisplay');
    // Fetch a large range (365 days) to ensure historical data is included
    fetchGoldRates(customDays: 365);
  }

  void sortRates(String order, String displayText) {
    _sortOrder = order;
    _selectedSortDisplay = displayText;
    _filterAndSortRates();
  }

  void _filterAndSortRates() {
    _filteredRates = List.from(_goldRates);

    // Apply date range filter for custom range
    if (_selectedRange == 'custom' && _customStartDate != null && _customEndDate != null) {
      _filteredRates = _filteredRates.where((rate) {
        final rateDate = DateTime.parse(rate.date);
        // Normalize to date-only comparison
        final rateDateOnly = DateTime(rateDate.year, rateDate.month, rateDate.day);
        final startDateOnly = DateTime(_customStartDate!.year, _customStartDate!.month, _customStartDate!.day);
        final endDateOnly = DateTime(_customEndDate!.year, _customEndDate!.month, _customEndDate!.day);
        return rateDateOnly.isAfter(startDateOnly.subtract(Duration(days: 1))) &&
            rateDateOnly.isBefore(endDateOnly.add(Duration(days: 1)));
      }).toList();
      print('Filtered ${_filteredRates.length} rates for range ${_formatDate(_customStartDate.toString())} to ${_formatDate(_customEndDate.toString())}');
    }

    // Apply sorting
    if (_sortOrder != 'none') {
      _filteredRates.sort((a, b) => _sortOrder == 'asc'
          ? a.buyRate.compareTo(b.buyRate)
          : b.buyRate.compareTo(a.buyRate));
    }
    notifyListeners();
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[parsedDate.month - 1]} ${parsedDate.day}, ${parsedDate.year}';
  }
}