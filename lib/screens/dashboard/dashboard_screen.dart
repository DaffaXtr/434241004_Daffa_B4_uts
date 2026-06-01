import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/user_model.dart';
import '../../models/ticket_model.dart';
import '../widgets/ticket_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).currentUser!;
    final stats = ref.watch(dashboardStatsProvider);
    final tickets = ref.watch(ticketProvider).tickets;
    final unreadCount = ref.watch(unreadCountProvider);
    final themeMode = ref.watch(themeProvider);

    final recentTickets = tickets.take(3).toList();
    final isDark = themeMode == ThemeMode.dark;

    final double completionRate = stats.total > 0 
        ? ((stats.resolved + stats.closed) / stats.total) 
        : 0.0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.primaryLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ${user.name.split(' ')[0]}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.white : AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.work_outline,
                              size: 16,
                              color: isDark ? AppColors.grey400 : AppColors.grey600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.roleLabel,
                              style: TextStyle(
                                color: isDark ? AppColors.grey400 : AppColors.grey600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // Theme Toggle
                      IconButton(
                        icon: Icon(
                          isDark ? Icons.light_mode : Icons.dark_mode,
                          color: isDark ? AppColors.grey300 : AppColors.grey600,
                        ),
                        onPressed: () => ref.read(themeProvider.notifier).toggle(),
                      ),
                      // Notifications
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.notifications_outlined, 
                              color: isDark ? AppColors.white : AppColors.primaryDark,
                            ),
                            onPressed: () => context.push('/notifications'),
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.statusOpen,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  unreadCount.toString(),
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // Avatar
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          user.name[0],
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xl),

              // OVERALL TASK COMPLETION CARD (With Premium Gradient)
              Container(
                padding: const EdgeInsets.all(AppSizes.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      isDark ? AppColors.primaryDark : const Color(0xFF5C9CFF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      height: 80,
                      width: 80,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: 1.0, // Background circle
                            strokeWidth: 8,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.2)),
                          ),
                          CircularProgressIndicator(
                            value: completionRate,
                            strokeWidth: 8,
                            backgroundColor: Colors.transparent,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          Center(
                            child: Text(
                              '${(completionRate * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSizes.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.role == UserRole.user 
                                ? 'Tingkat Penyelesaian' 
                                : 'Overall Task Completion',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.role == UserRole.user
                                ? 'Persentase tiket Anda yang sudah terselesaikan.'
                                : 'Pencapaian penyelesaian tiket secara keseluruhan.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // RINGKASAN STATISTIK HEADER
              Text(
                'Ringkasan Statistik',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white : AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // STATS GRID (Modern Pastel Cards)
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.05,
                children: [
                  _buildModernStatCard(
                    context, 
                    title: 'Open Tickets', 
                    desc: 'Tiket baru masuk', 
                    count: stats.open, 
                    total: stats.total, 
                    icon: Icons.computer_outlined,
                    color: AppColors.statusOpen,
                    onTap: () {
                      ref.read(ticketProvider.notifier).setFilter(TicketStatus.open);
                      context.push('/tickets');
                    },
                  ),
                  _buildModernStatCard(
                    context, 
                    title: 'In Progress', 
                    desc: 'Sedang ditangani', 
                    count: stats.inProgress, 
                    total: stats.total, 
                    icon: Icons.dashboard_outlined,
                    color: AppColors.statusInProgress,
                    onTap: () {
                      ref.read(ticketProvider.notifier).setFilter(TicketStatus.inProgress);
                      context.push('/tickets');
                    },
                  ),
                  _buildModernStatCard(
                    context, 
                    title: 'Resolved', 
                    desc: 'Berhasil diatasi', 
                    count: stats.resolved, 
                    total: stats.total, 
                    icon: Icons.campaign_outlined,
                    color: AppColors.statusResolved,
                    onTap: () {
                      ref.read(ticketProvider.notifier).setFilter(TicketStatus.resolved);
                      context.push('/tickets');
                    },
                  ),
                  _buildModernStatCard(
                    context, 
                    title: 'Closed', 
                    desc: 'Selesai & ditutup', 
                    count: stats.closed, 
                    total: stats.total, 
                    icon: Icons.view_in_ar_outlined,
                    color: AppColors.statusClosed,
                    onTap: () {
                      ref.read(ticketProvider.notifier).setFilter(TicketStatus.closed);
                      context.push('/tickets');
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xl),

              // RECENT TICKETS HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tiket Terbaru',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.primaryDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/tickets'),
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),

              // RECENT TICKETS LIST
              if (recentTickets.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Text(
                      'Belum ada aktivitas',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTickets.length,
                  itemBuilder: (context, index) =>
                      TicketCard(ticket: recentTickets[index]),
                ),

              const SizedBox(height: AppSizes.xxl),
            ],
          ),
        ),
      ),
      floatingActionButton: user.role == UserRole.user
          ? FloatingActionButton(
              onPressed: () => context.push('/create-ticket'),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildModernStatCard(
    BuildContext context, {
    required String title,
    required String desc,
    required int count,
    required int total,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = total > 0 ? (count / total) : 0.0;
    
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = "${months[DateTime.now().month - 1]} ${DateTime.now().day}, ${DateTime.now().year}";

    final bgColor = isDark ? AppColors.darkContainer : Colors.white; 
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedTextColor = isDark ? Colors.white54 : Colors.black54;
    final iconColor = color;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Date & More Vert
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateStr, style: TextStyle(color: mutedTextColor, fontSize: 11, fontWeight: FontWeight.w600)),
                    Icon(Icons.chevron_right, color: mutedTextColor, size: 18),
                  ],
                ),
                
                const Spacer(),
                
                // Middle Row: Icon & Title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(icon, color: iconColor, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            desc,
                            style: TextStyle(
                              color: mutedTextColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Bottom Row: Progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(color: mutedTextColor, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Stack(
                      children: [
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '$count/$total',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
