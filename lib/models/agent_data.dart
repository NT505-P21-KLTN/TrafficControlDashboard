class AgentStatus {
  final int totalAgents;
  final int onlineAgents;
  final Map<String, AgentInfo> agents;

  AgentStatus({
    required this.totalAgents,
    required this.onlineAgents,
    required this.agents,
  });

  factory AgentStatus.fromJson(Map<String, dynamic> json) {
    return AgentStatus(
      totalAgents: json['total_agents'] ?? 0,
      onlineAgents: json['online_agents'] ?? 0,
      agents: Map.fromEntries((json['agents'] as Map<String, dynamic>)
          .entries
          .map((e) => MapEntry(e.key, AgentInfo.fromJson(e.value)))),
    );
  }
}

class AgentInfo {
  final bool online;
  final String status;
  final int lastEpisode;

  AgentInfo({
    required this.online,
    required this.status,
    required this.lastEpisode,
  });

  factory AgentInfo.fromJson(Map<String, dynamic> json) {
    return AgentInfo(
      online: json['online'] ?? false,
      status: json['status'] ?? 'Unknown',
      lastEpisode: json['last_episode'] ?? 0,
    );
  }
}

class AgentData {
  final String agentId;
  final bool online;
  final String status;
  final int lastEpisode;
  final Map<String, dynamic> config;
  final List<Map<String, dynamic>> states;
  final List<double> rewards;
  final List<double> queueLengths;
  final List<double> waitingTimes;
  final Map<String, dynamic>? metrics;
  final Map<String, dynamic>? hyperparameters;
  final Map<String, dynamic>? environmentConfig;
  final double? latitude;
  final double? longitude;

  AgentData({
    required this.agentId,
    required this.online,
    required this.status,
    required this.lastEpisode,
    required this.config,
    required this.states,
    required this.rewards,
    required this.queueLengths,
    required this.waitingTimes,
    this.metrics,
    this.hyperparameters,
    this.environmentConfig,
    this.latitude,
    this.longitude,
  });

  factory AgentData.fromJson(Map<String, dynamic> json) {
    // Extract location from topology if available
    double? lat;
    double? lng;
    if (json['topology'] != null && json['topology']['location'] != null) {
      lat =
          double.tryParse(json['topology']['location']['latitude'].toString());
      lng =
          double.tryParse(json['topology']['location']['longitude'].toString());
    }

    return AgentData(
      agentId: json['agent_id'] ?? '',
      online: json['online'] ?? false,
      status: json['status'] ?? 'Unknown',
      lastEpisode: json['last_episode'] ?? 0,
      config: json['config'] ?? {},
      states: List<Map<String, dynamic>>.from(json['states'] ?? []),
      rewards: List<double>.from(json['rewards'] ?? []),
      queueLengths: List<double>.from(json['queue_lengths'] ?? []),
      waitingTimes: List<double>.from(json['waiting_times'] ?? []),
      metrics: json['metrics'],
      hyperparameters: json['hyperparameters'],
      environmentConfig: json['environment_config'],
      latitude: lat,
      longitude: lng,
    );
  }

  double get latestReward => rewards.isNotEmpty ? rewards.last : 0.0;
  double get latestQueueLength =>
      queueLengths.isNotEmpty ? queueLengths.last : 0.0;
  double get latestWaitingTime =>
      waitingTimes.isNotEmpty ? waitingTimes.last : 0.0;

  // Performance metrics
  double get averageReward =>
      rewards.isEmpty ? 0.0 : rewards.reduce((a, b) => a + b) / rewards.length;
  double get averageQueueLength => queueLengths.isEmpty
      ? 0.0
      : queueLengths.reduce((a, b) => a + b) / queueLengths.length;
  double get averageWaitingTime => waitingTimes.isEmpty
      ? 0.0
      : waitingTimes.reduce((a, b) => a + b) / waitingTimes.length;

  // Training progress
  double get trainingProgress => lastEpisode > 0
      ? (lastEpisode / (config['max_episodes'] ?? 1)) * 100
      : 0.0;

  // Get formatted metrics
  Map<String, String> get formattedMetrics {
    final Map<String, String> result = {
      'Latest Reward': latestReward.toStringAsFixed(2),
      'Average Reward': averageReward.toStringAsFixed(2),
      'Latest Queue Length': latestQueueLength.toStringAsFixed(2),
      'Average Queue Length': averageQueueLength.toStringAsFixed(2),
      'Latest Waiting Time': latestWaitingTime.toStringAsFixed(2),
      'Average Waiting Time': averageWaitingTime.toStringAsFixed(2),
      'Training Progress': '${trainingProgress.toStringAsFixed(1)}%',
      'Total Episodes': lastEpisode.toString(),
    };

    if (metrics != null) {
      metrics!.forEach((key, value) {
        if (value is num) {
          result[key] = value.toStringAsFixed(2);
        } else {
          result[key] = value.toString();
        }
      });
    }

    return result;
  }
}
