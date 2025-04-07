import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../utils/app_localization.dart';
import '../models/plant_reminder.dart';
import '../services/simple_notification_service.dart';
import '../services/scheduled_notification_service.dart';
import '../services/basic_notification.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({Key? key}) : super(key: key);

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  bool isLoading = false;
  String? errorMessage;
  List<PlantReminder> reminders = [];
  final String _remindersKey = 'plant_reminders';
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final SimpleNotificationService _notificationService =
      SimpleNotificationService();
  final ScheduledNotificationService _scheduledNotificationService =
      ScheduledNotificationService();

  @override
  void initState() {
    super.initState();
    _loadReminders();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }

  Future<void> _loadReminders() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedReminders = prefs.getStringList(_remindersKey) ?? [];

      reminders = savedReminders
          .map((str) => PlantReminder.fromJson(jsonDecode(str)))
          .toList();
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load reminders: ${e.toString()}';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedReminders =
          reminders.map((reminder) => jsonEncode(reminder.toJson())).toList();
      await prefs.setStringList(_remindersKey, encodedReminders);

      // Reschedule all reminders whenever they are saved
      await _scheduledNotificationService.scheduleAllReminders();
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to save reminders: ${e.toString()}';
      });
    }
  }

  Future<void> _showTestNotification(PlantReminder reminder) async {
    setState(() => isLoading = true);

    try {
      print(
          "Attempting to show test notification for plant: ${reminder.plantName}");
      final success = await _notificationService.showSimpleNotification(
        title: "Reminder: ${reminder.plantName}",
        body: reminder.notes.isEmpty
            ? "It's time to check on your plant!"
            : reminder.notes,
      );

      if (success) {
        print("Notification reported as successfully sent!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test notification sent!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print("Notification service returned false, notification was not sent");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Failed to send notification. Please check notification permissions.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print("CRITICAL ERROR showing notification: ${e.toString()}");
      setState(() {
        errorMessage = 'Failed to send notification: ${e.toString()}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _addReminder() async {
    final result = await showDialog<PlantReminder>(
      context: context,
      builder: (context) => ReminderDialog(),
    );

    if (result != null) {
      setState(() {
        reminders.add(result);
        _listKey.currentState?.insertItem(reminders.length - 1);
      });
      await _saveReminders();
    }
  }

  Future<void> _editReminder(int index) async {
    final currentReminder = reminders[index];

    final result = await showDialog<PlantReminder>(
      context: context,
      builder: (context) => ReminderDialog(reminder: currentReminder),
    );

    if (result != null) {
      setState(() {
        reminders[index] = result;
      });
      await _saveReminders();
    }
  }

  Future<void> _deleteReminder(int index) async {
    final reminder = reminders[index];

    setState(() {
      reminders.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildReminderItem(reminder, animation, index),
      );
    });

    await _saveReminders();
  }

  Future<void> _toggleReminderEnabled(int index, bool value) async {
    setState(() {
      reminders[index] = reminders[index].copyWith(isEnabled: value);
    });
    await _saveReminders();
  }

  Widget _buildReminderItem(
      PlantReminder reminder, Animation<double> animation, int index) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        child: ExpansionTile(
          leading: Icon(
            Icons.eco,
            color: reminder.isEnabled
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
          ),
          title: Text(
            reminder.plantName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: reminder.isEnabled
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
          ),
          subtitle: Text(
            'Time: ${reminder.time.format(context)}',
            style: TextStyle(
              color: reminder.isEnabled
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.grey,
            ),
          ),
          trailing: Switch(
            value: reminder.isEnabled,
            onChanged: (value) => _toggleReminderEnabled(index, value),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notes:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reminder.notes.isEmpty ? 'No notes added' : reminder.notes,
                    style: TextStyle(
                      fontStyle:
                          reminder.notes.isEmpty ? FontStyle.italic : null,
                      color: reminder.notes.isEmpty ? Colors.grey : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.notifications_active),
                        label: const Text('Test Notification'),
                        onPressed: () => _showTestNotification(reminder),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        onPressed: () => _editReminder(index),
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Delete',
                            style: TextStyle(color: Colors.red)),
                        onPressed: () => _deleteReminder(index),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            localization?.translate('plant_reminders') ?? 'Plant Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            tooltip: 'Test Basic Notification',
            onPressed: () async {
              final result = await BasicNotification.showNow(
                  'Basic Test', 'This is a basic test notification');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result
                      ? 'Basic notification sent!'
                      : 'Failed to send basic notification'),
                  backgroundColor: result ? Colors.green : Colors.red,
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization?.translate('reminder_description') ??
                        'Set up reminders for each of your plants',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  if (errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Expanded(
                    child: reminders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_none,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  localization?.translate('no_reminders') ??
                                      'No plant reminders yet',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  localization
                                          ?.translate('add_reminder_prompt') ??
                                      'Add a reminder for your plants',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          )
                        : AnimatedList(
                            key: _listKey,
                            initialItemCount: reminders.length,
                            padding: const EdgeInsets.only(bottom: 80),
                            itemBuilder: (context, index, animation) {
                              return _buildReminderItem(
                                  reminders[index], animation, index);
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReminder,
        icon: const Icon(Icons.add),
        label: Text(localization?.translate('add_reminder') ?? 'Add Reminder'),
      ),
    );
  }
}

class ReminderDialog extends StatefulWidget {
  final PlantReminder? reminder;

  const ReminderDialog({Key? key, this.reminder}) : super(key: key);

  @override
  State<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  late TextEditingController _plantNameController;
  late TextEditingController _notesController;
  late TimeOfDay _selectedTime;
  bool _isEnabled = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Initialize with existing values if editing, or default values if creating new
    _plantNameController =
        TextEditingController(text: widget.reminder?.plantName ?? '');
    _notesController =
        TextEditingController(text: widget.reminder?.notes ?? '');
    _selectedTime = widget.reminder?.time ?? TimeOfDay.now();
    _isEnabled = widget.reminder?.isEnabled ?? true;
  }

  @override
  void dispose() {
    _plantNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.reminder != null;
    final localization = AppLocalization.of(context);

    return AlertDialog(
      title: Text(isEditing
          ? (localization?.translate('edit_reminder') ?? 'Edit Reminder')
          : (localization?.translate('add_reminder') ?? 'Add Reminder')),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _plantNameController,
                decoration: InputDecoration(
                  labelText:
                      localization?.translate('plant_name') ?? 'Plant Name',
                  hintText: localization?.translate('plant_name_hint') ??
                      'Enter plant name',
                  prefixIcon: const Icon(Icons.eco),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localization?.translate('plant_name_required') ??
                        'Plant name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time),
                title: Text(localization?.translate('reminder_time') ??
                    'Reminder Time'),
                subtitle: Text(_selectedTime.format(context)),
                onTap: _pickTime,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: localization?.translate('notes') ?? 'Notes',
                  hintText: localization?.translate('notes_hint') ??
                      'E.g., Water needs, sunlight preferences, etc.',
                  prefixIcon: const Icon(Icons.notes),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(localization?.translate('enabled') ?? 'Enabled'),
                value: _isEnabled,
                onChanged: (value) {
                  setState(() {
                    _isEnabled = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localization?.translate('cancel') ?? 'Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final reminder = PlantReminder(
                id: widget.reminder?.id ?? const Uuid().v4(),
                plantName: _plantNameController.text.trim(),
                notes: _notesController.text.trim(),
                time: _selectedTime,
                isEnabled: _isEnabled,
              );
              Navigator.of(context).pop(reminder);
            }
          },
          child: Text(isEditing
              ? (localization?.translate('update') ?? 'Update')
              : (localization?.translate('save') ?? 'Save')),
        ),
      ],
    );
  }
}
