import 'package:flutter/material.dart';
import '../services/checkin_service.dart';

class ToolboxScreen extends StatefulWidget {
  const ToolboxScreen({super.key});

  @override
  State<ToolboxScreen> createState() => _ToolboxScreenState();
}

class _ToolboxScreenState extends State<ToolboxScreen> {
  // Palet Warna
  final Color _primaryColor = const Color(0xFF5B9A8B);
  final Color _backgroundColor = const Color(0xFFF7F9F9);
  final Color _surfaceColor = Colors.white;
  final Color _textColor = const Color(0xFF2D3B38);

  List<dynamic> _tools = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTools();
  }

  Future<void> _loadTools() async {
    final tools = await CheckinService.getTools();
    setState(() {
      _tools = tools;
      _isLoading = false;
    });
  }

  void _showToolDetail(Map<String, dynamic> tool) {
    if (tool['type'] == 'sos') {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                backgroundColor: _surfaceColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                title: const Text("Emergency Contacts",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: (tool['contacts'] as List)
                        .map((c) => ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.phone_rounded,
                                    color: Colors.red.shade400, size: 20),
                              ),
                              title: Text(c['name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              subtitle: Text(c['number'] ?? c['url']),
                            ))
                        .toList()),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Close",
                          style: TextStyle(color: Colors.grey.shade600)))
                ],
              ));
      return;
    }

    // Detail Sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 32),
            Text(tool['title'],
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _textColor)),
            const SizedBox(height: 16),
            Text(tool['description'],
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, color: Colors.grey.shade600, height: 1.5)),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Start Practice",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text("Emotional First Aid",
            style: TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: _textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _tools.length,
              itemBuilder: (context, index) {
                final tool = _tools[index];
                final isSOS = tool['type'] == 'sos';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _showToolDetail(tool),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSOS
                                    ? Colors.red.shade50
                                    : _primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isSOS
                                    ? Icons.sos_rounded
                                    : Icons.self_improvement_rounded,
                                color:
                                    isSOS ? Colors.red.shade400 : _primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tool['title'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: _textColor)),
                                  const SizedBox(height: 4),
                                  Text(
                                      isSOS
                                          ? "Emergency help lines"
                                          : "${tool['duration_min']} min • Relaxation",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: Colors.grey.shade300),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
