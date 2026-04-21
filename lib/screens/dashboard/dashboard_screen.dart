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
import '../widgets/stat_card.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/notifications'),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.xs),
                    decoration: BoxDecoration(
                      color: AppColors.statusOpen,
                      borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
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
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => ref.read(themeProvider.notifier).toggle(),
          ),
        ],
      ),
      drawer: _buildDrawer(context, ref, user),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            Text(
              'Selamat datang, ${user.name}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              user.roleLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSizes.lg),

            // Statistics
            Text(
              'Statistik Tiket',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.md),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: AppSizes.md,
              crossAxisSpacing: AppSizes.md,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                StatCard(
                  label: 'Total',
                  value: stats.total,
                  color: AppColors.primary,
                  icon: Icons.confirmation_number,
                ),
                StatCard(
                  label: 'Open',
                  value: stats.open,
                  color: AppColors.statusOpen,
                  icon: Icons.assignment_outlined,
                ),
                StatCard(
                  label: 'In Progress',
                  value: stats.inProgress,
                  color: AppColors.statusInProgress,
                  icon: Icons.hourglass_top,
                ),
                StatCard(
                  label: 'Resolved',
                  value: stats.resolved,
                  color: AppColors.statusResolved,
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),

            // Recent Tickets
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tiket Terbaru',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () => context.push('/tickets'),
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            if (recentTickets.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Text(
                    'Tidak ada tiket',
                    style: Theme.of(context).textTheme.bodyMedium,
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

            const SizedBox(height: AppSizes.lg),

            // Create Ticket Button
            if (user.role == UserRole.user)
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Buat Tiket Baru'),
                  onPressed: () => context.push('/create-ticket'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref, UserModel user) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user.name),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              context.go('/dashboard');
            },
          ),
          ListTile(
            leading: const Icon(Icons.confirmation_number),
            title: const Text('Tiket'),
            onTap: () {
              Navigator.pop(context);
              context.push('/tickets');
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifikasi'),
            onTap: () {
              Navigator.pop(context);
              context.push('/notifications');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              context.push('/profile');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.statusOpen),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
