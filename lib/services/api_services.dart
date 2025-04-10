import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/agent_data.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<AgentSummary> getAgentStatus() async {
    final response = await http.get(Uri.parse('$baseUrl/api/status'));

    if (response.statusCode == 200) {
      return AgentSummary.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load agent status');
    }
  }

  Future<Map<String, dynamic>> getAllAgentData() async {
    final response = await http.get(Uri.parse('$baseUrl/api/data'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load agent data');
    }
  }

  Future<Map<String, dynamic>> getLatestCharts() async {
    final response = await http.get(Uri.parse('$baseUrl/api/latest_charts'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load charts data');
    }
  }

  Future<List<AgentData>> getFormattedAgentData() async {
    final allData = await getAllAgentData();
    final List<AgentData> agents = [];

    allData.forEach((agentId, data) {
      agents.add(AgentData.fromJson(agentId, data));
    });

    return agents;
  }
}