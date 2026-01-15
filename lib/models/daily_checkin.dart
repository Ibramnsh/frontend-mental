class DailyCheckin {
  final String? id;
  final int mood;
  final String energy;
  final bool sleep;
  final String? summary;
  final String? journalEntry; // <--- Tambahan Wajib
  final List<String>? tags; // <--- Tambahan Opsional
  final DateTime? createdAt;

  DailyCheckin({
    this.id,
    required this.mood,
    required this.energy,
    required this.sleep,
    this.summary,
    this.journalEntry, // <--- Tambahan
    this.tags, // <--- Tambahan
    this.createdAt,
  });

  factory DailyCheckin.fromJson(Map<String, dynamic> json) {
    return DailyCheckin(
      id: json['_id'],
      mood: json['mood'],
      energy: json['energy'],
      sleep: json['sleep'],
      summary: json['summary'],
      // Pastikan nama key JSON sama persis dengan di backend ('journal_entry')
      journalEntry: json['journal_entry'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mood': mood,
      'energy': energy,
      'sleep': sleep,
      'journal_entry': journalEntry, // <--- Kirim balik ke backend
      'tags': tags,
    };
  }
}
