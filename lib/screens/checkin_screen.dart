import 'package:flutter/material.dart';
import '../models/daily_checkin.dart';
import '../services/checkin_service.dart';

class CheckinScreen extends StatefulWidget {
  final DailyCheckin? existingCheckin;
  const CheckinScreen({super.key, this.existingCheckin});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  // Palet Warna
  final Color _primaryColor = const Color(0xFF5B9A8B);
  final Color _backgroundColor = const Color(0xFFF7F9F9);
  final Color _surfaceColor = Colors.white;
  final Color _textColor = const Color(0xFF2D3B38);

  late int _mood;
  late String _energy;
  late bool _sleep;
  final TextEditingController _journalController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  String _prompt = "Loading thought starter...";

  @override
  void initState() {
    super.initState();
    _mood = widget.existingCheckin?.mood ?? 3;
    _energy = widget.existingCheckin?.energy ?? 'mid';
    _sleep = widget.existingCheckin?.sleep ?? true;

    if (widget.existingCheckin?.journalEntry != null) {
      _journalController.text = widget.existingCheckin!.journalEntry!;
    }
    _loadPrompt();
  }

  Future<void> _loadPrompt() async {
    final p = await CheckinService.getJournalPrompt();
    if (mounted) setState(() => _prompt = p);
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final checkin = DailyCheckin(
        mood: _mood,
        energy: _energy,
        sleep: _sleep,
        journalEntry: _journalController.text,
        tags: []);

    final result = await CheckinService.submitCheckin(checkin);

    setState(() => _isLoading = false);

    if (result['success']) {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      setState(() => _error = result['error']);
    }
  }

  // Helper untuk mendapatkan Ikon Mood (Tanpa Emoji Kuning)
  IconData _getMoodIcon(int m) {
    switch (m) {
      case 1:
        return Icons.sentiment_very_dissatisfied_rounded;
      case 2:
        return Icons.sentiment_dissatisfied_rounded;
      case 3:
        return Icons.sentiment_neutral_rounded;
      case 4:
        return Icons.sentiment_satisfied_rounded;
      case 5:
        return Icons.sentiment_very_satisfied_rounded;
      default:
        return Icons.sentiment_neutral_rounded;
    }
  }

  String _getMoodLabel(int m) =>
      ['', 'Heavy', 'Low', 'Okay', 'Good', 'Amazing'][m];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: _textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.existingCheckin != null
              ? 'Update Check-in'
              : 'Daily Reflection',
          style: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- MOOD CARD ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Text('How are you feeling?',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _textColor)),
                  const SizedBox(height: 24),
                  Icon(
                    _getMoodIcon(_mood),
                    size: 80,
                    color: _primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getMoodLabel(_mood),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor),
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _primaryColor,
                      inactiveTrackColor: _primaryColor.withOpacity(0.2),
                      thumbColor: _primaryColor,
                      overlayColor: _primaryColor.withOpacity(0.1),
                    ),
                    child: Slider(
                        value: _mood.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        onChanged: (v) => setState(() => _mood = v.round())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- ENERGY & SLEEP ROW ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildEnergyCard()),
                const SizedBox(width: 16),
                Expanded(child: _buildSleepCard()),
              ],
            ),

            const SizedBox(height: 24),

            // --- JOURNALING CARD ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.edit_note_rounded, color: _primaryColor),
                      const SizedBox(width: 8),
                      Text('Daily Journal',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _textColor)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_rounded,
                            size: 20, color: _primaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(_prompt,
                                style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 13,
                                    color: Colors.grey.shade700))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _journalController,
                    maxLines: 5,
                    style: TextStyle(color: _textColor),
                    decoration: InputDecoration(
                      hintText: "Pour your thoughts here...",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: _backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            BorderSide(color: _primaryColor, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                ],
              ),
            ),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_error!,
                      style: TextStyle(color: Colors.red.shade700)),
                ),
              ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16))),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Save Check-in',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Text('Energy',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textColor)),
          const SizedBox(height: 16),
          _buildOptionBtn(
              'low', 'Low', Icons.battery_1_bar_rounded, _energy == 'low'),
          const SizedBox(height: 8),
          _buildOptionBtn(
              'mid', 'Mid', Icons.battery_4_bar_rounded, _energy == 'mid'),
          const SizedBox(height: 8),
          _buildOptionBtn(
              'high', 'High', Icons.battery_full_rounded, _energy == 'high'),
        ],
      ),
    );
  }

  Widget _buildSleepCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Text('Sleep',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textColor)),
          const SizedBox(height: 16),
          _buildSleepOption(true, 'Good', Icons.bedtime_rounded),
          const SizedBox(height: 12),
          _buildSleepOption(false, 'Bad', Icons.bedtime_off_rounded),
        ],
      ),
    );
  }

  Widget _buildOptionBtn(
      String val, String label, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _energy = val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : _backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : Colors.grey.shade400,
                size: 20),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepOption(bool val, String label, IconData icon) {
    bool isSelected = _sleep == val;
    return GestureDetector(
      onTap: () => setState(() => _sleep = val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : _backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : Colors.grey.shade400,
                size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
