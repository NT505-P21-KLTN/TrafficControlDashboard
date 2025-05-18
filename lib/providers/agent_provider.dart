import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/agent_data.dart';
import '../services/api_service.dart';

class AgentProvider with ChangeNotifier {
  final ApiService _apiService;
  Timer? _refreshTimer;
  Map<String, AgentData> _agents = {};
  Map<String, dynamic>? _chartsInfo;
  String _lastUpdateTime = 'N/A';
  int _totalAgents = 0;
  int _onlineAgents = 0;

  AgentProvider(this._apiService);

  // Getters
  Map<String, AgentData> get agents => _agents;
  Map<String, dynamic>? get chartsInfo => _chartsInfo;
  String get lastUpdateTime => _lastUpdateTime;
  int get totalAgents => _totalAgents;
  int get onlineAgents => _onlineAgents;

  void startPeriodicRefresh() {
    // Initial data fetch
    _loadData();

    // Set up periodic refresh
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      // Fetch agent status
      final status = await _apiService.getAgentStatus();
      _totalAgents = status.totalAgents;
      _onlineAgents = status.onlineAgents;

      // Fetch agent data
      final data = await _apiService.getAgentData();
      _agents = data;

      // Fetch charts
      _chartsInfo = await _apiService.getLatestCharts();

      // Update timestamp
      _lastUpdateTime = DateTime.now().toString().substring(11, 19);

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
