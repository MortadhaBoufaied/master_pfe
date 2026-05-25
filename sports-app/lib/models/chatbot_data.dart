class ChatbotData {
  final int id;
  final String question;
  final String answer;

  ChatbotData({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory ChatbotData.fromJson(Map<String, dynamic> json) {
    return ChatbotData(
      id: json['id'],
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
    };
  }
}


