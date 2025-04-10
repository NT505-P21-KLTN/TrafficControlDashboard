class AgentData {
  final String agentId;
  final String status;
  final num lastEpisode;
  final List<num> rewards;
  final List<num> queueLengths;
  final Map<String, dynamic> config;
  final bool isOnline;

  AgentData({
    required this.agentId,
    required this.status,
    required this.lastEpisode,
    required this.rewards,
    required this.queueLengths,
    required this.config,
    required this.isOnline,
  });

  factory AgentData.fromJson(String id, Map<String, dynamic> json) {
    return AgentData(
      agentId: id,
      status: json['status'] ?? 'unknown',
      lastEpisode: json['last_episode'] ?? -1,
      rewards: List<num>.from(json['rewards'] ?? []),
      queueLengths: List<num>.from(json['queue_lengths'] ?? []),
      config: json['config'] ?? {},
      isOnline: true, // This will be set from status response
    );
  }
}

class AgentSummary {
  final num totalAgents;
  final num onlineAgents;
  final Map<String, AgentStatus> agents;
  String serverStatus = 'Unknown'; // Default value

  AgentSummary({
    required this.totalAgents,
    required this.onlineAgents,
    required this.agents,
  }) {
    serverStatus = 'Online'; // Default to online, can be updated based on agent status
  }

  factory AgentSummary.fromJson(Map<String, dynamic> json) {
    final agentsMap = <String, AgentStatus>{};

    if (json['agents'] != null) {
      json['agents'].forEach((key, value) {
        agentsMap[key] = AgentStatus.fromJson(value);
      });
    }

    return AgentSummary(
      totalAgents: json['total_agents'] ?? 0,
      onlineAgents: json['online_agents'] ?? 0,
      agents: agentsMap,
    );
  }
}

class AgentStatus {
  final bool online;
  final num lastUpdate;
  final num dataPoints;
  final num lastEpisode;
  final String status;

  AgentStatus({
    required this.online,
    required this.lastUpdate,
    required this.dataPoints,
    required this.lastEpisode,
    required this.status,
  });

  factory AgentStatus.fromJson(Map<String, dynamic> json) {
    return AgentStatus(
      online: json['online'] ?? false,
      lastUpdate: json['last_update'] ?? 0,
      dataPoints: json['data_points'] ?? 0,
      lastEpisode: json['last_episode'] ?? -1,
      status: json['status'] ?? 'unknown',
    );
  }
}