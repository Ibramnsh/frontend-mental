import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/daily_checkin.dart';
import '../services/checkin_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Palet Warna
  final Color _primaryColor = const Color(0xFF5B9A8B);
  final Color _backgroundColor = const Color(0xFFF7F9F9);
  final Color _surfaceColor = Colors.white;
  final Color _textColor = const Color(0xFF2D3B38);

  List<DailyCheckin> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await CheckinService.getHistory(days: 7);
    setState(() {
      _history = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          "Mood Trends",
          style: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
        ),
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
          : _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart_rounded,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text("No data yet. Start checking in!",
                          style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- CHART SECTION ---
                      Container(
                        height: 320,
                        padding: const EdgeInsets.fromLTRB(16, 24, 24, 10),
                        decoration: BoxDecoration(
                          color: _surfaceColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, bottom: 20),
                              child: Text("Last 7 Days",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _textColor,
                                      fontSize: 16)),
                            ),
                            Expanded(
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 1,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey.shade100,
                                        strokeWidth: 1,
                                        dashArray: [
                                          5,
                                          5
                                        ], // Garis putus-putus agar lebih rapi
                                      );
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize:
                                            32, // PERBAIKAN: Memberi ruang agar teks hari tidak terpotong
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          int index = value.toInt();
                                          if (index >= 0 &&
                                              index < _history.length) {
                                            final date =
                                                _history[index].createdAt;
                                            return SideTitleWidget(
                                              axisSide: meta.axisSide,
                                              space:
                                                  8, // Jarak dari garis chart ke teks
                                              child: Text(
                                                date != null
                                                    ? DateFormat('E').format(
                                                        date) // Mon, Tue, etc.
                                                    : '',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade400,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            );
                                          }
                                          return const SizedBox();
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize:
                                            42, // PERBAIKAN: Memberi ruang lebih untuk emotikon
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          // PERBAIKAN: Cek modulo agar tidak render di nilai desimal (mencegah double)
                                          if (value % 1 != 0)
                                            return const SizedBox();

                                          const icons = [
                                            Icons
                                                .sentiment_very_dissatisfied_rounded, // 1
                                            Icons
                                                .sentiment_dissatisfied_rounded, // 2
                                            Icons
                                                .sentiment_neutral_rounded, // 3
                                            Icons
                                                .sentiment_satisfied_rounded, // 4
                                            Icons
                                                .sentiment_very_satisfied_rounded // 5
                                          ];
                                          int idx = value.toInt();
                                          if (idx >= 1 && idx <= 5) {
                                            return SideTitleWidget(
                                              axisSide: meta.axisSide,
                                              child: Icon(icons[idx - 1],
                                                  size: 22,
                                                  color: Colors.grey.shade400),
                                            );
                                          }
                                          return const SizedBox();
                                        },
                                      ),
                                    ),
                                    topTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  minX: 0,
                                  maxX: (_history.length - 1).toDouble(),
                                  minY: 1,
                                  maxY:
                                      5.5, // Sedikit padding atas agar emotikon mood 5 tidak terpotong
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: _history.asMap().entries.map((e) {
                                        return FlSpot(e.key.toDouble(),
                                            e.value.mood.toDouble());
                                      }).toList(),
                                      isCurved: true,
                                      color: _primaryColor,
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(
                                          show: true,
                                          getDotPainter:
                                              (spot, percent, barData, index) {
                                            return FlDotCirclePainter(
                                              radius:
                                                  6, // Titik sedikit lebih besar
                                              color: _surfaceColor,
                                              strokeWidth: 3,
                                              strokeColor: _primaryColor,
                                            );
                                          }),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            _primaryColor.withOpacity(0.25),
                                            _primaryColor.withOpacity(0.0),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      Text("History Log",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _textColor)),
                      const SizedBox(height: 16),

                      // --- LIST LOG ---
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final log = _history[
                              _history.length - 1 - index]; // Reverse order
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: _surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  log.mood.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _primaryColor,
                                      fontSize: 16),
                                ),
                              ),
                              title: Text(
                                log.createdAt != null
                                    ? DateFormat('EEEE, d MMM')
                                        .format(log.createdAt!)
                                    : '-',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _textColor,
                                    fontSize: 14),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  if (log.journalEntry != null &&
                                      log.journalEntry!.isNotEmpty)
                                    Text(
                                      log.journalEntry!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500),
                                    )
                                  else
                                    Text("No journal entry",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade400,
                                            fontStyle: FontStyle.italic)),
                                ],
                              ),
                              trailing: Chip(
                                label: Text(log.energy.toUpperCase()),
                                labelStyle: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                backgroundColor: _primaryColor.withOpacity(0.8),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
    );
  }
}
