import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/ticket_model.dart';
import '../../providers/ticket_provider.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_colors.dart';

class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  ConsumerState<CreateTicketScreen> createState() =>
      _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  TicketPriority _priority = TicketPriority.medium;
  TicketCategory _category = TicketCategory.other;
  final List<String> _attachments = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan deskripsi harus diisi')),
      );
      return;
    }

    await ref.read(ticketProvider.notifier).createTicket(
          title: _titleCtrl.text,
          description: _descCtrl.text,
          priority: _priority,
          category: _category,
          attachments: _attachments,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tiket berhasil dibuat')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(ticketProvider).isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: isDark ? AppColors.darkSurface : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
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
                    'Buat Tiket Baru',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 48), // Balancing space
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Judul Tiket',
                      style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    TextField(
                      controller: _titleCtrl,
                      enabled: !isLoading,
                      decoration: inputDecoration.copyWith(
                        hintText: 'Tulis masalah utama secara singkat...',
                        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),

                    Text(
                      'Deskripsi',
                      style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    TextField(
                      controller: _descCtrl,
                      enabled: !isLoading,
                      maxLines: 5,
                      decoration: inputDecoration.copyWith(
                        hintText: 'Jelaskan masalah secara detail, langkah-langkah untuk mereproduksi, atau error yang muncul...',
                        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Prioritas',
                                style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                              ),
                              const SizedBox(height: AppSizes.sm),
                              DropdownButtonFormField<TicketPriority>(
                                initialValue: _priority,
                                items: TicketPriority.values
                                    .map((p) => DropdownMenuItem(
                                          value: p,
                                          child: Text(p.toString().split('.').last.toUpperCase()),
                                        ))
                                    .toList(),
                                onChanged: !isLoading ? (value) => setState(() => _priority = value!) : null,
                                decoration: inputDecoration,
                                icon: const Icon(Icons.keyboard_arrow_down),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kategori',
                                style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                              ),
                              const SizedBox(height: AppSizes.sm),
                              DropdownButtonFormField<TicketCategory>(
                                initialValue: _category,
                                items: TicketCategory.values
                                    .map((c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(c.toString().split('.').last.toUpperCase()),
                                        ))
                                    .toList(),
                                onChanged: !isLoading ? (value) => setState(() => _category = value!) : null,
                                decoration: inputDecoration,
                                icon: const Icon(Icons.keyboard_arrow_down),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.xl),

                    Text(
                      'Lampiran',
                      style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    // Dashed Attachment Box
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Simulasi buka lampiran')));
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white24 : Colors.grey.shade300,
                            style: BorderStyle.solid, // Flutter doesn't have native dashed borders easily, using solid with tint
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.cloud_upload_outlined, size: 48, color: AppColors.primary.withOpacity(0.5)),
                            const SizedBox(height: 8),
                            Text('Ketuk untuk mengunggah gambar/file', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
                            const SizedBox(height: 4),
                            Text('Maks. 5MB (JPG, PNG, PDF)', style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),

                    if (_attachments.isNotEmpty) ...[
                      const SizedBox(height: AppSizes.md),
                      Wrap(
                        spacing: AppSizes.sm,
                        children: _attachments
                            .map((file) => Chip(
                                  label: Text(file),
                                  onDeleted: () => setState(() => _attachments.remove(file)),
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  deleteIconColor: AppColors.primary,
                                ))
                            .toList(),
                      ),
                    ],

                    const SizedBox(height: AppSizes.xxl),
                    
                    // Large Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                              )
                            : const Text('Kirim Tiket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: AppSizes.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
