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
}
