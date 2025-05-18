import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/agent_provider.dart';
import '../services/api_service.dart';

class LogDisplay extends StatefulWidget {
  final bool autoRefresh;
  final ValueChanged<bool> onAutoRefreshChanged;

  const LogDisplay({
    super.key,
    required this.autoRefresh,
    required this.onAutoRefreshChanged,
  });

  @override
  State<LogDisplay> createState() => _LogDisplayState();
}

class _LogDisplayState extends State<LogDisplay> {
  final ScrollController _scrollController = ScrollController();
  List<String> _logs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final logs = await apiService.getLogs();

      setState(() {
        _logs = logs;
      });

      // Scroll to bottom
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading logs: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'System Logs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  // Auto-refresh toggle
                  Row(
                    children: [
                      const Text('Auto-refresh'),
                      Switch(
                        value: widget.autoRefresh,
                        onChanged: widget.onAutoRefreshChanged,
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Refresh button
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadLogs,
                  ),
                  // Clear button
                  IconButton(
                    icon: const Icon(Icons.clear_all),
                    onPressed: () {
                      setState(() {
                        _logs.clear();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // Log list
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      return _buildLogEntry(log);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogEntry(String log) {
    Color textColor = Colors.black;
    if (log.toLowerCase().contains('error')) {
      textColor = Colors.red;
    } else if (log.toLowerCase().contains('warning')) {
      textColor = Colors.orange;
    } else if (log.toLowerCase().contains('success')) {
      textColor = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        log,
        style: TextStyle(
          color: textColor,
          fontFamily: 'monospace',
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
