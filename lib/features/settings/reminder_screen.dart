import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readflow/core/theme/app_theme.dart';
import 'package:readflow/features/settings/widgets/day_selector.dart';
import 'package:readflow/providers/book_providers.dart';
import 'package:readflow/providers/book_reminder_provider.dart';

import '../../core/widgets/app_toast.dart';
import '../../data/models/book_reminder.dart';

class ReminderScreen extends ConsumerWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(bookReminderProvider);
    final notifier = ref.read(bookReminderProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminders'),
        actions: [
          IconButton(
            onPressed: () => showReminderSheet(context, ref, notifier),
            icon: Icon(Icons.add, color: AppColors.textSecondary),
          ),
        ],
      ),
      body: reminders.isEmpty
          ? const Center(child: Text('No reminders yet - tap + add one'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => SizedBox(height: 10),
              itemCount: reminders.length,
              itemBuilder: (context, i) {
                final r = reminders[i];
                final books = ref.watch(bookProviders);
                final linkedBook = r.bookID != null
                    ? books.where((b) => b.bookId == r.bookID).firstOrNull
                    : null;

                return InkWell(
                  onTap: () =>
                      showReminderSheet(context, ref, notifier, existing: r),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _buildCoverThumbnail(linkedBook?.coverImagePath),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${r.hour.toString().padLeft(2, '0')}:${r.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: r.enabled,
                          onChanged: (_) {
                            notifier.toggleEnable(r);
                            AppToast.show(
                              r.enabled
                                  ? 'Reminder turned off'
                                  : 'Reminder turned on',
                              type: ToastType.info,
                            );
                          },
                          activeThumbColor: AppColors.primary,
                        ),
                        IconButton(
                          onPressed: () {
                            notifier.deleteRemindre(r);
                            AppToast.show(
                              'Reminder removed',
                              type: ToastType.error,
                            );
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void showReminderSheet(
      BuildContext context,
      WidgetRef ref,
      BookReminderNotifier notifier, {
        BookReminder? existing, // null = add mode, non-null = edit mode
      }) {
    final labelController = TextEditingController(text: existing?.label ?? '');
    TimeOfDay pickedTime = existing != null
        ? TimeOfDay(hour: existing.hour, minute: existing.minute)
        : TimeOfDay.now();
    String? selectedBookId = existing?.bookID;
    List<int> selectedDays = existing?.daysOfWeek ?? [1, 2, 3, 4, 5, 6, 7]; // default: every day

    final books = ref.read(bookProviders);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existing == null ? 'New Reminder' : 'Edit Reminder',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),

                  // Book picker
                  DropdownButtonFormField<String?>(
                    value: selectedBookId,
                    decoration: const InputDecoration(
                      labelText: 'Link to a book (optional)',
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('No book — general reminder'),
                      ),
                      ...books.map(
                            (b) => DropdownMenuItem(
                          value: b.bookId,
                          child: Text(b.title),
                        ),
                      ),
                    ],
                    onChanged: (bookId) {
                      setSheetState(() {
                        selectedBookId = bookId;
                        final book = books.firstWhereOrNull((b) => b.bookId == bookId);
                        if (book != null && labelController.text.trim().isEmpty) {
                          labelController.text = book.title; // auto-fill, only if label is empty
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: labelController,
                    decoration: const InputDecoration(labelText: 'Label'),
                  ),
                  const SizedBox(height: 16),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Time'),
                    trailing: Text(pickedTime.format(context)),
                    onTap: () async {
                      final result = await showTimePicker(
                        context: context,
                        initialTime: pickedTime,
                      );
                      if (result != null) {
                        setSheetState(() => pickedTime = result);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Repeat on',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  DaySelector(
                    selectedDays: selectedDays,
                    onChanged: (days) => setSheetState(() => selectedDays = days),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (labelController.text.trim().isEmpty) return;
                        if (selectedDays.isEmpty) {
                          AppToast.show('Pick at least one day', type: ToastType.error);
                          return;
                        }

                        if (existing == null) {
                          notifier.addReminder(
                            label: labelController.text.trim(),
                            hour: pickedTime.hour,
                            minute: pickedTime.minute,
                            bookId: selectedBookId,
                            selectedDays: selectedDays,
                          );
                        } else {
                          notifier.editReminder(
                            existing,
                            label: labelController.text.trim(),
                            hour: pickedTime.hour,
                            minute: pickedTime.minute,
                            bookId: selectedBookId,
                            selectedDays: selectedDays,
                          );
                        }
                        AppToast.show('Reminder saved');
                        Navigator.pop(context);
                      },
                      child: Text(existing == null ? 'Add Reminder' : 'Save Changes'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCoverThumbnail(String? coverImagePath) {
    const size = 44.0;

    if (coverImagePath == null || coverImagePath.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.menu_book_outlined,
          color: AppColors.textSecondary,
          size: 22,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.file(
        File(coverImagePath),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.menu_book_outlined,
            color: AppColors.textSecondary,
            size: 22,
          ),
        ),
      ),
    );
  }
}
