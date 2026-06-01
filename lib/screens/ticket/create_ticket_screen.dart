import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/ticket_model.dart';
import '../../providers/ticket_provider.dart';
import '../../core/constants/app_sizes.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Tiket Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            Text(
              'Judul Tiket',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: _titleCtrl,
              enabled: !isLoading,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Tulis judul tiket...',
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Description Field
            Text(
              'Deskripsi',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: _descCtrl,
              enabled: !isLoading,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Jelaskan masalah secara detail...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Priority
            Text(
              'Prioritas',
              style: Theme.of(context).textTheme.titleSmall,
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
              decoration: const InputDecoration(
                hintText: 'Pilih prioritas',
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Category
            Text(
              'Kategori',
              style: Theme.of(context).textTheme.titleSmall,
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
              decoration: const InputDecoration(
                hintText: 'Pilih kategori',
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Attachments (simulation)
            Text(
              'Lampiran (Opsional)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSizes.sm),
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                color: Colors.grey.withValues(alpha: 0.05),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.image),
                        label: const Text('Dari Galeri'),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitur ini adalah simulasi'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: AppSizes.md),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Dari Kamera'),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitur ini adalah simulasi'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  if (_attachments.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.md),
                    Wrap(
                      spacing: AppSizes.sm,
                      children: _attachments
                          .map((file) => Chip(
                                label: Text(file),
                                onDeleted: () {
                                  setState(() => _attachments.remove(file));
                                },
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xxl),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Buat Tiket'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
