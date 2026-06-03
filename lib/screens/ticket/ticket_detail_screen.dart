import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/ticket_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../data/dummy/dummy_users.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../widgets/status_badge.dart';
import '../widgets/comment_bubble.dart';
import '../widgets/history_timeline.dart';
import '../../providers/history_provider.dart';
import '../../models/history_model.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  final String ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  late TextEditingController _commentCtrl;
  bool _isInternal = false;
  int _selectedTab = 0; // 0: Komentar, 1: Riwayat

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

  Color _getPriorityColor(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low: return AppColors.priorityLow;
      case TicketPriority.medium: return AppColors.priorityMedium;
      case TicketPriority.high: return AppColors.priorityHigh;
      case TicketPriority.critical: return AppColors.priorityCritical;
    }
  }

  void _showAssignBottomSheet(BuildContext context, String ticketId) {
    final staffUsers = dummyUsers
        .where((u) => u.role == UserRole.helpdesk || u.role == UserRole.admin)
        .toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Text('Tugaskan Staff', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Pilih teknisi untuk menangani tiket ini.', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
            const SizedBox(height: AppSizes.lg),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: staffUsers.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
              itemBuilder: (context, index) {
                final staff = staffUsers[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(staff.name[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(staff.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(staff.department, style: const TextStyle(fontSize: 12)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      staff.role == UserRole.admin ? 'Admin' : 'Helpdesk',
                      style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () {
                    ref.read(ticketProvider.notifier).assignTicket(ticketId, staff.id);
                    ref.read(historyProvider(ticketId).notifier).addHistory(
                      action: HistoryAction.assigned,
                      description: 'Tiket ditugaskan ke ${staff.name}',
                      actorId: ref.read(authProvider).currentUser!.id,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tiket berhasil ditugaskan ke ${staff.name}')),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }

  void _showStatusBottomSheet(BuildContext context, TicketModel ticket) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statuses = [
      {'status': TicketStatus.open, 'label': 'Open', 'color': AppColors.statusOpen},
      {'status': TicketStatus.inProgress, 'label': 'In Progress', 'color': AppColors.statusInProgress},
      {'status': TicketStatus.resolved, 'label': 'Resolved', 'color': AppColors.statusResolved},
      {'status': TicketStatus.closed, 'label': 'Closed', 'color': AppColors.statusClosed},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Text('Update Status Tiket', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Ubah status perkembangan tiket ini.', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
            const SizedBox(height: AppSizes.lg),
            ...statuses.map((s) {
              final status = s['status'] as TicketStatus;
              final color = s['color'] as Color;
              final isSelected = ticket.status == status;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () {
                    if (isSelected) {
                      Navigator.pop(context);
                      return;
                    }
                    ref.read(ticketProvider.notifier).updateStatus(ticket.id, status);
                    ref.read(historyProvider(ticket.id).notifier).addHistory(
                      action: HistoryAction.statusUpdated,
                      description: 'Status diubah menjadi ${s['label']}',
                      actorId: ref.read(authProvider).currentUser!.id,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Status tiket diubah menjadi ${s['label']}')),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withValues(alpha: 0.1) : (isDark ? AppColors.darkContainer : Colors.white),
                      border: Border.all(
                        color: isSelected ? color : (isDark ? Colors.white12 : Colors.black12),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? color : Colors.transparent,
                            border: Border.all(color: color, width: 2),
                          ),
                          child: isSelected ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          s['label'] as String,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? color : (isDark ? Colors.white : Colors.black87),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tickets = ref.watch(ticketProvider).tickets;
    final currentUser = ref.watch(authProvider).currentUser!;
    final comments = ref.watch(commentProvider(widget.ticketId));
    final histories = ref.watch(historyProvider(widget.ticketId));

    final ticket = tickets.firstWhere(
      (t) => t.id == widget.ticketId,
      orElse: () => throw Exception('Ticket not found'),
    );

    final reporter = dummyUsers.firstWhere(
      (u) => u.id == ticket.reporterId,
      orElse: () => const UserModel(
        id: 'unknown', name: 'Unknown', email: '', username: '', role: UserRole.user, department: '',
      ),
    );

    final assignee = ticket.assignedToId != null
        ? dummyUsers.firstWhere(
            (u) => u.id == ticket.assignedToId,
            orElse: () => const UserModel(
              id: 'unknown', name: 'Unknown', email: '', username: '', role: UserRole.user, department: '',
            ),
          )
        : null;

    final isStaff = currentUser.role == UserRole.helpdesk || currentUser.role == UserRole.admin;
    final isAdmin = currentUser.role == UserRole.admin;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.primaryLight,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header (Clean, no 3 dots)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, size: 20, color: isDark ? Colors.white : Colors.black87),
                    onPressed: () => context.pop(),
                  ),
                  Text(
                    'Detail Tiket',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 48), // Balancing space since we removed the 3 dots
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ID
                      Text(
                        ticket.id,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        ticket.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Pills Row
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          StatusBadge(status: ticket.status),
                          _buildPill(ticket.priorityLabel, _getPriorityColor(ticket.priority)),
                          _buildPill(ticket.categoryLabel, isDark ? Colors.white70 : Colors.black54),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Info Pastel Box
                      Container(
                        padding: const EdgeInsets.all(AppSizes.md),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkContainer : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? Colors.transparent : Colors.grey.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow('Reporter', reporter.name, isDark),
                            Divider(height: 24, thickness: 1, color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                            _buildInfoRow('Ditugaskan ke', assignee?.name ?? 'Belum ada', isDark),
                            Divider(height: 24, thickness: 1, color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                            _buildInfoRow('Dibuat', '${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year}', isDark),
                          ],
                        ),
                      ),

                      // Dedicated Action Buttons for Staff
                      if (isStaff) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (isAdmin)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showAssignBottomSheet(context, ticket.id),
                                  icon: const Icon(Icons.person_add_alt_1, size: 18),
                                  label: const Text('Tugaskan'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                    foregroundColor: AppColors.primary,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            if (isAdmin) const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showStatusBottomSheet(context, ticket),
                                icon: const Icon(Icons.update, size: 18),
                                label: const Text('Status'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'Deskripsi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ticket.description,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isDark ? AppColors.grey400 : AppColors.grey600,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Custom Tabs
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkContainer : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            if (!isDark)
                              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(child: _buildCustomTab(0, 'Komentar', Icons.chat_bubble_outline)),
                            Expanded(child: _buildCustomTab(1, 'Riwayat', Icons.history)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tab Content
                      if (_selectedTab == 0) ...[
                        if (comments.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Column(
                                children: [
                                  Icon(Icons.chat_bubble_outline, size: 48, color: isDark ? Colors.white24 : Colors.black12),
                                  const SizedBox(height: 16),
                                  Text('Belum ada komentar', style: TextStyle(color: isDark ? Colors.white54 : Colors.black38)),
                                ],
                              ),
                            ),
                          )
                        else
                          Column(
                            children: comments.map((c) => CommentBubble(comment: c, currentUserId: currentUser.id, isStaff: isStaff)).toList(),
                          ),
                      ] else ...[
                        HistoryTimeline(histories: histories),
                      ],
                      const SizedBox(height: 80), // Padding for bottom input
                    ],
                  ),
                ),
              ),
            ),
            
            if (_selectedTab == 0)
              _buildCommentInput(context, currentUser.id, isStaff),
          ],
        ),
      ),
    );
  }

  Widget _buildPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCustomTab(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              size: 16, 
              color: isSelected ? Colors.white : (isDark ? Colors.white54 : Colors.black54)
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : (isDark ? Colors.white54 : Colors.black54),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? AppColors.grey400 : AppColors.grey600,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentInput(BuildContext context, String currentUserId, bool isStaff) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, -10),
            blurRadius: 20,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isStaff)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(right: 8),
                      child: Checkbox(
                        value: _isInternal,
                        onChanged: (val) => setState(() => _isInternal = val ?? false),
                        activeColor: AppColors.statusOpen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    Text(
                      'Komentar Internal (Hanya Staff)',
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkContainer : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.transparent),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.emoji_emotions_outlined, color: isDark ? Colors.white54 : Colors.black45),
                          onPressed: () {},
                        ),
                        Expanded(
                          child: TextField(
                            controller: _commentCtrl,
                            maxLines: 5,
                            minLines: 1,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'Ketik pesan...',
                              hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: true,
                              fillColor: Colors.transparent,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.attach_file, color: isDark ? Colors.white54 : Colors.black45),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: () async {
                      if (_commentCtrl.text.trim().isEmpty) return;
                      final text = _commentCtrl.text;
                      _commentCtrl.clear();
                      
                      await ref.read(commentProvider(widget.ticketId).notifier).addComment(
                        currentUserId,
                        text,
                        isInternal: _isInternal,
                      );
                      setState(() => _isInternal = false);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}