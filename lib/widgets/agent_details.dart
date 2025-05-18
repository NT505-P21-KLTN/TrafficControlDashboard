import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/agent_data.dart';
import '../providers/agent_provider.dart';

class AgentDetails extends StatelessWidget {
  final String? selectedAgent;

  const AgentDetails({
    super.key,
    this.selectedAgent,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AgentProvider>(
      builder: (context, provider, child) {
        if (selectedAgent == null) {
          return const Center(
            child: Text('Select an agent to view details'),
          );
        }

        final agent = provider.agents[selectedAgent];
        if (agent == null) {
          return const Center(
            child: Text('Agent not found'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Agent Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: agent.online ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      agent.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Performance metrics
              const Text(
                'Performance Metrics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildMetricsGrid(agent),
              const SizedBox(height: 16),

              // Configuration
              const Text(
                'Configuration',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildConfigList(agent.config),

              if (agent.hyperparameters != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Hyperparameters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildConfigList(agent.hyperparameters!),
              ],

              if (agent.environmentConfig != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Environment Configuration',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildConfigList(agent.environmentConfig!),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricsGrid(AgentData agent) {
    final metrics = agent.formattedMetrics;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      childAspectRatio: 2.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: metrics.entries.map((entry) {
        return _buildDetailItem(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigList(Map<String, dynamic> config) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: config.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  entry.value.toString(),
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
