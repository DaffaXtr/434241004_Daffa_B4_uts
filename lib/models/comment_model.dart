class CommentModel {
  final String id;
  final String ticketId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final bool isInternal; // true = hanya helpdesk/admin yang lihat

  const CommentModel({
    required this.id,
    required this.ticketId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    this.isInternal = false,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      ticketId: json['ticket_id'],
      authorId: json['author_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      isInternal: json['is_internal'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'author_id': authorId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'is_internal': isInternal,
    };
  }
}
