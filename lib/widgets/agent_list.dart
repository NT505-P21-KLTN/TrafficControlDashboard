import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/agent_provider.dart';

class AgentList extends StatelessWidget {
  const AgentList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AgentProvider>(
      builder: (context, provider, child) {
        final agents = provider.agents;

        if (agents.isEmpty) {
          return const Center(
            child: Text('No agents connected'),
          );
        }

        return ListView.builder(
          itemCount: agents.length,
          itemBuilder: (context, index) {
            final agentId = agents.keys.elementAt(index);
            final agent = agents[agentId]!;
            final agentInfo = provider.agents[agentId];

            return ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    agentInfo?.online == true ? Colors.green : Colors.red,
                radius: 6,
              ),
              title: Text(agentId),
              subtitle: Text(
                'Episode: ${agentInfo?.lastEpisode ?? 0}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(agentInfo?.status ?? 'Unknown'),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  agentInfo?.status ?? 'Unknown',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              onTap: () {
                // TODO: Handle agent selection
              },
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'idle':
        return Colors.blue;
      case 'training':
        return Colors.orange;
      case 'simulating':
        return Colors.purple;
      case 'terminated':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
