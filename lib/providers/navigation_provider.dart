import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Ganti StateProvider menjadi NotifierProvider murni
final NotifierProvider<NavigationIndexNotifier, int> navigationIndexProvider = 
    NotifierProvider<NavigationIndexNotifier, int>(
  () => NavigationIndexNotifier(),
);

// 2. Buat kelas Notifier untuk menampung indeks integer
class NavigationIndexNotifier extends Notifier<int> {
  
  // 3. Definisikan indeks awal (0) di dalam method build()
  @override
  int build() {
    return 0;
  }

  // 4. Buat fungsi helper untuk mengubah nilai indeks saat tab diklik
  void setIndex(int newIndex) {
    state = newIndex;
  }
}