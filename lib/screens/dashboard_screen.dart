import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traffic_control_dashboard/screens/widget/agent_list_widget.dart';
import 'package:traffic_control_dashboard/screens/widget/agent_summart_widget.dart';
import '../models/agent_data.dart';
import '../services/api_services.dart';
import 'agent_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  AgentSummary? _agentSummary;
  List<AgentData>? _agentData;
  String? _selectedAgentId;
  Timer? _refreshTimer;
  Map<String, dynamic>? _chartsInfo;
  int _selectedChartIndex = 0;
  final List<String> _chartTypes = ['Rewards', 'Queue Length'];

  @override
  void initState() {
    super.initState();
    _loadData();
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    
    try {
      final summary = await apiService.getAgentStatus();
      final data = await apiService.getFormattedAgentData();
      final charts = await apiService.getLatestCharts();
      
      setState(() {
        _agentSummary = summary;
        _agentData = data;
        _chartsInfo = charts;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  void _selectAgent(String agentId) {
    final selectedAgent = _agentData?.firstWhere(
      (agent) => agent.agentId == agentId,
      orElse: () => throw Exception('Agent not found'),
    );
    
    if (selectedAgent != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AgentDetailScreen(agent: selectedAgent),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _buildDashboard(),
    );
  }

  Widget _buildDashboard() {
    if (_agentSummary == null) {
      return const Center(child: CircularProgressIndicator());
    }
    print('image url: localhost:5000/${_chartsInfo!['rewards_chart']}');

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard Title
            Card(
              color: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Traffic Light Control System - Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    const Text("Server status: "),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: _agentSummary!.serverStatus == 'Online'
                            ? Color.fromARGB(255, 218, 255, 219)
                            : const Color.fromARGB(255, 255, 149, 141),
                        borderRadius: BorderRadius.circular(45),
                      ),
                      child: Text(
                        _agentSummary!.serverStatus,
                        style: TextStyle(color: _agentSummary!.serverStatus == 'Online'
                            ? const Color.fromARGB(255, 46, 91, 47)
                            : const Color.fromARGB(255, 88, 47, 44)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Last updated: ${_chartsInfo?['timestamp'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column with fixed width
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AgentSummaryWidget(summary: _agentSummary!),
                      const SizedBox(height: 16),
            
                      // Agent List
                      AgentListWidget(
                        agentStatusMap: _agentSummary!.agents,
                        onSelectAgent: _selectAgent,
                      ),
                    ],
                  ),
                ),
            
                const SizedBox(width: 16),
            
                // Charts Section with fixed width
                Expanded(
                  flex: 3,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Performance Comparison',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
            
                          // Chart Type Selector
                          SegmentedButton<int>(
                            segments: _chartTypes.map((type) {
                              return ButtonSegment<int>(
                                value: _chartTypes.indexOf(type),
                                label: Text(type),
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
            
                          // Chart Display
                          SizedBox(
                            height: 300,
                            width: double.infinity,
                            child: _chartsInfo != null
                                ? Image.network('localhost:5000/${_selectedChartIndex == 0
                                  ? _chartsInfo!['rewards_chart']
                                  : _chartsInfo!['queue_chart']}',

                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Text('Failed to load chart'),
                                );
                              },
                            )
                                : const Center(child: CircularProgressIndicator()),
                          ),
            
                          const SizedBox(height: 8),
                          Text(
                            'Last chart update: ${_chartsInfo?['timestamp'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}