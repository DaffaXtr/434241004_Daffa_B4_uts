import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import 'package:go_router/go_router.dart';
import '../../models/ticket_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../core/constants/app_sizes.dart';
import '../widgets/ticket_card.dart';
import '../widgets/dynamic_bottom_nav_bar.dart';

class TicketListScreen extends ConsumerWidget {
  const TicketListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navigationIndexProvider.notifier).setIndex(1);
    });
    final ticketState = ref.watch(ticketProvider);
    final user = ref.watch(authProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tiket'),
        actions: [
          if (user?.role == UserRole.user)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/create-ticket'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          if (user?.role != UserRole.user)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(AppSizes.md),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Semua'),
                    selected: ticketState.filterStatus == null,
                    onSelected: (_) {
                      ref.read(ticketProvider.notifier).setFilter(null);
                    },
                  ),
                  const SizedBox(width: AppSizes.sm),
                  FilterChip(
                    label: const Text('Open'),
                    selected: ticketState.filterStatus == TicketStatus.open,
                    onSelected: (_) {
                      ref
                          .read(ticketProvider.notifier)
                          .setFilter(TicketStatus.open);
                    },
                  ),
                  const SizedBox(width: AppSizes.sm),
                  FilterChip(
                    label: const Text('In Progress'),
                    selected:
                        ticketState.filterStatus == TicketStatus.inProgress,
                    onSelected: (_) {
                      ref
                          .read(ticketProvider.notifier)
                          .setFilter(TicketStatus.inProgress);
                    },
                  ),
                  const SizedBox(width: AppSizes.sm),
                  FilterChip(
                    label: const Text('Resolved'),
                    selected: ticketState.filterStatus == TicketStatus.resolved,
                    onSelected: (_) {
                      ref
                          .read(ticketProvider.notifier)
                          .setFilter(TicketStatus.resolved);
                    },
                  ),
                ],
              ),
            ),

          // Tickets List
          Expanded(
            child: ticketState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ticketState.filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.lg),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.assignment_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: AppSizes.md),
                              Text(
                                'Tidak ada tiket',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: ticketState.filtered.length,
                        itemBuilder: (context, index) {
                          return TicketCard(
                            ticket: ticketState.filtered[index],
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const DynamicBottomNavBar(currentIndex: 1),
    );
  }
}
