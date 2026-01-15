class ChatMessage {
  final String id;
  final String message;
  final bool isUser; // Field penting
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Logic untuk mendeteksi apakah pesan dari User atau AI
    // Backend mengirim: "role": "user" atau "role": "ai"
    bool isUserCheck = false;

    if (json['role'] != null) {
      isUserCheck = json['role'] == 'user';
    } else if (json['isUser'] != null) {
      isUserCheck = json['isUser']; // Fallback jika format lama
    }

    return ChatMessage(
      id: json['_id'] ?? json['id'] ?? '',
      message: json['message'] ?? '',
      isUser: isUserCheck,
      timestamp: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
