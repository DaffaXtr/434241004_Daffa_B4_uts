import '../../models/comment_model.dart';

final dummyComments = [
  CommentModel(
    id: 'c001',
    ticketId: 'TKT-002',
    authorId: 'u001',
    content: 'Sudah coba clear cache browser tapi masih error.',
    createdAt: DateTime.now().subtract(const Duration(hours: 20)),
  ),
  CommentModel(
    id: 'c002',
    ticketId: 'TKT-002',
    authorId: 'h001',
    content: 'Terima kasih pelaporannya. Sedang kami investigasi, kemungkinan ada issue di database autentikasi.',
    createdAt: DateTime.now().subtract(const Duration(hours: 18)),
  ),
  CommentModel(
    id: 'c003',
    ticketId: 'TKT-002',
    authorId: 'h001',
    content: '[INTERNAL] Reset session token user ini dari sisi server.',
    isInternal: true,
    createdAt: DateTime.now().subtract(const Duration(hours: 10)),
  ),
  CommentModel(
    id: 'c004',
    ticketId: 'TKT-003',
    authorId: 'h001',
    content: 'Sudah kami perbaiki konfigurasi access point di Gedung C. Mohon dicoba kembali.',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
];
