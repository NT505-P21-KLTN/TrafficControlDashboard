import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/agent_provider.dart';
import '../widgets/agent_list.dart';
import '../widgets/agent_details.dart';
import '../widgets/chart_display.dart';
import '../widgets/log_display.dart';
import '../widgets/app_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? selectedAgent;
  bool autoRefreshLogs = true;

  @override
  void initState() {
    super.initState();
    // Start periodic data refresh
    Future.delayed(Duration.zero, () {
      final provider = Provider.of<AgentProvider>(context, listen: false);
      provider.startPeriodicRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traffic Control Dashboard'),
        actions: [
          Consumer<AgentProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                        '${provider.onlineAgents}/${provider.totalAgents} Online'),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Row(
        children: [
          // Left sidebar
          SizedBox(
            width: 300,
            child: Card(
              margin: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // Agent summary
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Agent Summary',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Consumer<AgentProvider>(
                          builder: (context, provider, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatBox(
                                  'Total Agents',
                                  provider.totalAgents.toString(),
                                ),
                                _buildStatBox(
                                  'Online',
                                  provider.onlineAgents.toString(),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // Agent list
                  const Expanded(
                    child: AgentList(),
                  ),
                ],
              ),
            ),
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // Charts section
                Expanded(
                  flex: 2,
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Performance Charts',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Consumer<AgentProvider>(
                                builder: (context, provider, child) {
                                  return Text(
                                    'Last updated: ${provider.lastUpdateTime}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const Expanded(
                          child: ChartDisplay(),
                        ),
                      ],
                    ),
                  ),
                ),
                // Agent details and logs section
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      // Agent details
                      Expanded(
                        flex: 1,
                        child: Card(
                          margin: const EdgeInsets.all(8),
                          child: AgentDetails(
                            selectedAgent: selectedAgent,
                          ),
                        ),
                      ),
                      // Logs
                      Expanded(
                        flex: 1,
                        child: Card(
                          margin: const EdgeInsets.all(8),
                          child: LogDisplay(
                            autoRefresh: autoRefreshLogs,
                            onAutoRefreshChanged: (value) {
                              setState(() {
                                autoRefreshLogs = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
