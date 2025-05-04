import 'package:flutter/material.dart';
import 'package:invest_gold/view_model/gold_rate_view_model.dart';
import 'package:provider/provider.dart';

class GoldPriceScreen extends StatelessWidget {
  const GoldPriceScreen({super.key});

  Future<void> _selectCustomDateRange(BuildContext context, GoldRateViewModel viewModel) async {

    final initialRange = viewModel.selectedRange == 'custom' &&
        viewModel.customStartDate != null &&
        viewModel.customEndDate != null
        ? DateTimeRange(
      start: viewModel.customStartDate!,
      end: viewModel.customEndDate!,
    )
        : DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: initialRange,
    );

    if (picked != null) {
      viewModel.setCustomDays(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoldRateViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date Range Filter
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8.0),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: const Text('Select'),
                                    onTap: () {
                                      viewModel.setDays(365, 'none', 'Date Range');
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: const Text('Last 7 Days'),
                                    onTap: () {
                                      viewModel.setDays(7, '7', 'Last 7 Days');
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: const Text('Last 30 Days'),
                                    onTap: () {
                                      viewModel.setDays(30, '30', 'Last 30 Days');
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: const Text('Last 365 Days'),
                                    onTap: () {
                                      viewModel.setDays(365, '365', 'Last 365 Days');
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: const Text('Custom'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _selectCustomDateRange(context, viewModel);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            viewModel.selectedRangeDisplay,
                            style: const TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Sort Filter
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8.0),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: const Text('Select'),
                                    onTap: () {
                                      viewModel.sortRates('none', 'Sort');
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: const Text('High to Low'),
                                    onTap: () {
                                      viewModel.sortRates('desc', 'High to Low');
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: const Text('Low to High'),
                                    onTap: () {
                                      viewModel.sortRates('asc', 'Low to High');
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            children: [
                              Text(
                                viewModel.selectedSortDisplay,
                                style: const TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: viewModel.goldRates.length,
                itemBuilder: (context, index) {
                  final rate = viewModel.goldRates[index];
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.diamond, color: Colors.amber), // Changed to gold icon
                      title: const Text('Gold'),
                      subtitle: Text(_formatDate(rate.date)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Buy: ₹${rate.buyRate.toStringAsFixed(2)}/g'),
                          Text('Sell: ₹${rate.sellRate.toStringAsFixed(2)}/g'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
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
