import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/agent_data.dart';

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = 'http://localhost:5000'});

  Future<AgentStatus> getAgentStatus() async {
    final response = await http.get(Uri.parse('$baseUrl/api/status'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return AgentStatus.fromJson(data);
    } else {
      throw Exception('Failed to load agent status');
    }
  }

  Future<Map<String, AgentData>> getAgentData() async {
    final response = await http.get(Uri.parse('$baseUrl/api/data'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Map.fromEntries(
        data.entries.map(
          (entry) => MapEntry(
            entry.key,
            AgentData.fromJson(entry.value as Map<String, dynamic>),
          ),
        ),
      );
    } else {
      throw Exception('Failed to load agent data');
    }
  }

  Future<Map<String, dynamic>> getLatestCharts() async {
    final response = await http.get(Uri.parse('$baseUrl/api/latest_charts'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load charts');
    }
  }

  Future<List<String>> getLogs() async {
    final response = await http.get(Uri.parse('$baseUrl/api/logs'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data['logs']);
    } else {
      throw Exception('Failed to load logs');
    }
  }
}
