import 'package:flutter/material.dart';
import 'package:traffic_control_dashboard/screens/widget/status_badge_widget.dart';
import '../models/agent_data.dart';

class AgentDetailScreen extends StatelessWidget {
  final AgentData agent;
  
  const AgentDetailScreen({super.key, required this.agent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agent: ${agent.agentId}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildStatsCard(),
            const SizedBox(height: 16),
            _buildConfigCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              agent.isOnline ? Icons.check_circle : Icons.error,
              color: agent.isOnline ? Colors.green : Colors.red,
              size: 48,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StatusBadgeWidget(status: agent.status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid() {
    final latestReward = agent.rewards.isNotEmpty
        ? agent.rewards.last.toStringAsFixed(2)
        : 'N/A';
        
    final latestQueueLength = agent.queueLengths.isNotEmpty
        ? agent.queueLengths.last.toStringAsFixed(2)
        : 'N/A';
        
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildStatItem('Current Episode', '${agent.lastEpisode}'),
        _buildStatItem('Total Episodes', '${agent.rewards.length}'),
        _buildStatItem('Latest Reward', latestReward),
        _buildStatItem('Latest Queue Length', latestQueueLength),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agent Configuration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...agent.config.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Text(
                      '${entry.key}:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text('${entry.value}'),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}