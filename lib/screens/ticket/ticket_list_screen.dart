import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../models/ticket_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../widgets/ticket_card.dart';

class TicketListScreen extends ConsumerWidget {
  const TicketListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navigationIndexProvider.notifier).setIndex(1);
    });
    
    final ticketState = ref.watch(ticketProvider);
    final user = ref.watch(authProvider).currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget buildFilterPill(String label, TicketStatus? status) {
      final isSelected = ticketState.filterStatus == status;
      return GestureDetector(
        onTap: () => ref.read(ticketProvider.notifier).setFilter(status),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primary 
                : (isDark ? AppColors.darkContainer : Colors.white),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (!isDark && !isSelected)
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected 
                  ? Colors.white 
                  : (isDark ? AppColors.grey300 : AppColors.grey600),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.primaryLight,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER & SEARCH
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daftar Tiket',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kelola dan pantau seluruh laporan IT Anda di sini.',
                    style: TextStyle(
                      color: isDark ? AppColors.grey400 : AppColors.grey600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  
                  // SEARCH BAR
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari ID atau judul tiket...',
                      hintStyle: TextStyle(color: isDark ? AppColors.grey500 : AppColors.grey400),
                      prefixIcon: Icon(Icons.search, color: isDark ? AppColors.grey400 : AppColors.grey500),
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurface : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.transparent : Colors.black.withValues(alpha: 0.05),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // FILTER PILLS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
              child: Row(
                children: [
                  buildFilterPill('Semua', null),
                  buildFilterPill('Open', TicketStatus.open),
                  buildFilterPill('In Progress', TicketStatus.inProgress),
                  buildFilterPill('Resolved', TicketStatus.resolved),
                  buildFilterPill('Closed', TicketStatus.closed),
                ],
              ),
            ),
            
            const SizedBox(height: AppSizes.sm),
            
            // TICKETS LIST
            Expanded(
              child: ticketState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ticketState.filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSizes.lg),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 64,
                                  color: isDark ? AppColors.grey600 : Colors.grey.shade300,
                                ),
                                const SizedBox(height: AppSizes.md),
                                Text(
                                  'Tidak ada tiket',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: isDark ? AppColors.grey400 : AppColors.grey600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: ticketState.filtered.length,
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm).copyWith(bottom: AppSizes.xxl), // padding bottom for fab
                          itemBuilder: (context, index) {
                            return TicketCard(
                              ticket: ticketState.filtered[index],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: user?.role == UserRole.user
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
}
