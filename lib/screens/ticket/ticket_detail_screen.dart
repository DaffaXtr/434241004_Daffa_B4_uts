import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ticket_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../data/dummy/dummy_users.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../widgets/status_badge.dart';
import '../widgets/comment_bubble.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  final String ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  late TextEditingController _commentCtrl;
  bool _isInternal = false;

  @override
  void initState() {
    super.initState();
    _commentCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  // --- FUNGSI BARU: Menampilkan Dialog untuk memilih Staff ---
  void _showAssignDialog(BuildContext context, String ticketId) {
    // Filter hanya user yang merupakan staff (helpdesk atau admin)
    final staffUsers = dummyUsers
        .where((u) => u.role == UserRole.helpdesk || u.role == UserRole.admin)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tugaskan ke Staff'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: staffUsers.length,
            itemBuilder: (context, index) {
              final staff = staffUsers[index];
              return ListTile(
                leading: CircleAvatar(child: Text(staff.name[0])),
                title: Text(staff.name),
                subtitle: Text(staff.department),
                onTap: () {
                  // Memanggil notifier untuk update assignedToId
                  ref
                      .read(ticketProvider.notifier)
                      .assignTicket(ticketId, staff.id);
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tiket ditugaskan ke ${staff.name}')),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tickets = ref.watch(ticketProvider).tickets;
    final currentUser = ref.watch(authProvider).currentUser!;
    final comments = ref.watch(commentProvider(widget.ticketId));

    final ticket = tickets.firstWhere(
      (t) => t.id == widget.ticketId,
      orElse: () => throw Exception('Ticket not found'),
    );

    final reporter = dummyUsers.firstWhere(
      (u) => u.id == ticket.reporterId,
      orElse: () => const UserModel(
        id: 'unknown',
        name: 'Unknown',
        email: '',
        username: '',
        role: UserRole.user,
        department: '',
      ),
    );

    final assignee = ticket.assignedToId != null
        ? dummyUsers.firstWhere(
            (u) => u.id == ticket.assignedToId,
            orElse: () => const UserModel(
              id: 'unknown',
              name: 'Unknown',
              email: '',
              username: '',
              role: UserRole.user,
              department: '',
            ),
          )
        : null;

    final isStaff =
        currentUser.role == UserRole.helpdesk || currentUser.role == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tiket'),
        actions: [
          if (isStaff)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'assign') {
                  _showAssignDialog(context, ticket.id);
                } else if (value == 'resolve') {
                  ref
                      .read(ticketProvider.notifier)
                      .updateStatus(ticket.id, TicketStatus.resolved);
                } else if (value == 'close') {
                  ref
                      .read(ticketProvider.notifier)
                      .updateStatus(ticket.id, TicketStatus.closed);
                } else if (value == 'progress') {
                  ref
                      .read(ticketProvider.notifier)
                      .updateStatus(ticket.id, TicketStatus.inProgress);
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'assign',
                  child: Row(
                    children: [
                      Icon(Icons.person_add_alt_1, size: 20),
                      SizedBox(width: 8),
                      Text('Tugaskan Staff'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'progress',
                  child: Text('Update ke In Progress'),
                ),
                const PopupMenuItem(
                  value: 'resolve',
                  child: Text('Update ke Resolved'),
                ),
                const PopupMenuItem(
                  value: 'close',
                  child: Text('Update ke Closed'),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ticket.id,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  StatusBadge(status: ticket.status),
                ],
              ),
              const SizedBox(height: AppSizes.md),

              // Title
              Text(
                ticket.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSizes.lg),

              // Info Cards
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkContainer
                      : AppColors.grey100,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Status', ticket.statusLabel),
                    _buildInfoRow('Prioritas', ticket.priorityLabel),
                    _buildInfoRow('Kategori', ticket.categoryLabel),
                    _buildInfoRow('Reporter', reporter.name),
                    _buildInfoRow(
                      'Ditugaskan ke',
                      assignee?.name ?? 'Belum ada',
                    ),
                    _buildInfoRow(
                      'Dibuat',
                      '${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Description
              Text(
                'Deskripsi',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSizes.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey300),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Text(ticket.description),
              ),
              const SizedBox(height: AppSizes.lg),

              // Comments Section
              Text(
                'Komentar (${comments.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSizes.md),
              if (comments.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                  child: Text(
                    'Belum ada komentar',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              else
                Column(
                  children: comments
                      .map((comment) => CommentBubble(
                            comment: comment,
                            currentUserId: currentUser.id,
                            isStaff: isStaff,
                          ))
                      .toList(),
                ),
              const SizedBox(height: AppSizes.lg),

              // Add Comment Form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tambah Komentar',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSizes.md),
                      TextField(
                        controller: _commentCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Tulis komentar...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      if (isStaff)
                        CheckboxListTile(
                          value: _isInternal,
                          onChanged: (value) =>
                              setState(() => _isInternal = value ?? false),
                          title: const Text('Komentar Internal (hanya staff)'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      const SizedBox(height: AppSizes.md),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _commentCtrl.text.isEmpty
                              ? null
                              : () async {
                                  await ref
                                      .read(commentProvider(widget.ticketId)
                                          .notifier)
                                      .addComment(
                                        currentUser.id,
                                        _commentCtrl.text,
                                        isInternal: _isInternal,
                                      );
                                  _commentCtrl.clear();
                                  setState(() => _isInternal = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Komentar berhasil ditambahkan'),
                                    ),
                                  );
                                },
                          child: const Text('Kirim'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.grey500
                  : AppColors.grey600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}