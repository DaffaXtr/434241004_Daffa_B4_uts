import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/navigation_provider.dart';

class DynamicBottomNavBar extends ConsumerWidget {
  final int currentIndex;

  const DynamicBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.confirmation_number),
          label: 'Tiket',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        // Update provider
        ref.read(navigationIndexProvider.notifier).setIndex(index);
        
        // Navigate based on index
        switch (index) {
          case 0:
            context.go('/dashboard');
            break;
          case 1:
            context.go('/tickets');
            break;
          case 2:
            context.go('/profile');
            break;
        }
      },
    );
  }
}
