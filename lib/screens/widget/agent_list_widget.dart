import 'package:flutter/material.dart';
import 'package:traffic_control_dashboard/models/agent_data.dart';
import 'status_badge_widget.dart';

class AgentListWidget extends StatelessWidget {
  final Map<String, AgentStatus> agentStatusMap;
  final Function(String) onSelectAgent;

  const AgentListWidget({
    Key? key,
    required this.agentStatusMap,
    required this.onSelectAgent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agent List',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (agentStatusMap.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('No agents connected')),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: agentStatusMap.length,
                itemBuilder: (context, index) {
                  final agentId = agentStatusMap.keys.elementAt(index);
                  final agentStatus = agentStatusMap[agentId]!;
                  
                  return _buildAgentListItem(agentId, agentStatus);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentListItem(String agentId, AgentStatus status) {
    return InkWell(
      onTap: () => onSelectAgent(agentId),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: status.online ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                agentId,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            StatusBadgeWidget(status: status.status),
            const SizedBox(width: 12),
            Text(
              'Ep: ${status.lastEpisode}',
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}