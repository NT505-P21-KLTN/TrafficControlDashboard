import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/agent_provider.dart';

class ChartDisplay extends StatefulWidget {
  const ChartDisplay({super.key});

  @override
  State<ChartDisplay> createState() => _ChartDisplayState();
}

class _ChartDisplayState extends State<ChartDisplay> {
  int _selectedChartIndex = 0;
  final List<String> _chartTypes = ['Rewards', 'Queue Length'];

  @override
  Widget build(BuildContext context) {
    return Consumer<AgentProvider>(
      builder: (context, provider, child) {
        final chartsInfo = provider.chartsInfo;

        if (chartsInfo == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          children: [
            // Chart type selector
            SegmentedButton<int>(
              segments: _chartTypes.asMap().entries.map((entry) {
                return ButtonSegment<int>(
                  value: entry.key,
                  label: Text(entry.value),
                );
              }).toList(),
              selected: {_selectedChartIndex},
              onSelectionChanged: (Set<int> selected) {
                setState(() {
                  _selectedChartIndex = selected.first;
                });
              },
            ),
            const SizedBox(height: 16),

            // Chart display
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'http://localhost:5000/${_selectedChartIndex == 0 ? chartsInfo['rewards_chart'] : chartsInfo['queue_chart']}',
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text('Failed to load chart'),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
