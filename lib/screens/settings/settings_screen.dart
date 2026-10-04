import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';

import '../../core/theme/theme_manager.dart';
import '../../core/services/notification_service.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../view_models/app_view_model.dart';
import '../../widgets/common_widgets.dart';

Future<void> showSettingsBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => const SettingsScreen(showHeader: false),
  );
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.showHeader = true});

  final bool showHeader;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _name;
  late final TextEditingController _dream;
  late final TextEditingController _anchor;
  late TimeOfDay _focusTime;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    final UserProfile user = context.read<AppViewModel>().user;
    _name = TextEditingController(text: user.name);
    _dream = TextEditingController(text: user.bigDream ?? '');
    _anchor = TextEditingController(text: user.anchor ?? '');
    _focusTime = _parseFocusTime(user.focusWindow);
    _avatarUrl = user.avatarUrl;
  }

  @override
  void dispose() {
    _name.dispose();
    _dream.dispose();
    _anchor.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_name.text.trim().isEmpty) return;
    await context.read<AppViewModel>().updateProfile(
      name: _name.text,
      dream: _dream.text,
      anchor: _anchor.text,
      focusWindow: _focusTime.format(context),
      avatarUrl: _avatarUrl,
    );
    if (context.read<AppViewModel>().notificationsEnabled) {
      await NotificationService.scheduleDaily(
        hour: _focusTime.hour,
        minute: _focusTime.minute,
        anchor: _anchor.text.trim().isEmpty
            ? 'your purpose'
            : _anchor.text.trim(),
      );
    }
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated.')));
    }
  }

  Future<void> _pickAvatar() async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked == null || !mounted) return;
    final Uint8List bytes = await picked.readAsBytes();
    setState(
      () => _avatarUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}',
    );
    await _saveProfile();
  }

  Future<void> _resetApp() async {
    final bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => ThryveBottomSheet(
        title: 'Reset Thryve?',
        content: const Text(
          'This removes your goals, tasks, wall, and profile from this device. This cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AppViewModel>().resetApp();
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _setNotifications(bool enabled) async {
    await context.read<AppViewModel>().setNotificationsEnabled(enabled);
    if (!enabled) {
      await NotificationService.cancelDaily();
    } else {
      final TimeOfDay time = _parseFocusTime(
        context.read<AppViewModel>().user.focusWindow,
      );
      await NotificationService.scheduleDaily(
        hour: time.hour,
        minute: time.minute,
        anchor: context.read<AppViewModel>().user.anchor ?? 'your purpose',
      );
    }
  }

  TimeOfDay _parseFocusTime(String? value) {
    if (value == null) return const TimeOfDay(hour: 8, minute: 0);
    final RegExpMatch? match = RegExp(
      r'(\d{1,2}):(\d{2})\s*(AM|PM)',
      caseSensitive: false,
    ).firstMatch(value);
    if (match == null) return const TimeOfDay(hour: 8, minute: 0);
    int hour = int.tryParse(match.group(1)!) ?? 8;
    final int minute = int.tryParse(match.group(2)!) ?? 0;
    if (match.group(3)!.toUpperCase() == 'PM' && hour < 12) hour += 12;
    if (match.group(3)!.toUpperCase() == 'AM' && hour == 12) hour = 0;
    return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
  }

  Future<void> _editFocusWindow() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _focusTime,
    );
    if (picked != null && mounted) {
      setState(() => _focusTime = picked);
      await _saveProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeManager theme = context.watch<ThemeManager>();
    final AppViewModel app = context.watch<AppViewModel>();
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Widget settingsContent = SafeArea(
      // The shared sliver header already accounts for the status bar. Applying
      // another top inset here creates the large gap below the header.
      top: false,
      bottom: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Settings', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 4),
            Text(
              'Shape your Thryve experience.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Text(
              'PROFILE',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: colors.primary),
            ),
            const SizedBox(height: 10),
            Center(
              child: Stack(
                children: <Widget>[
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: colors.primaryContainer,
                    backgroundImage: avatarImageProvider(_avatarUrl),
                    child: avatarImageProvider(_avatarUrl) == null
                        ? Icon(Icons.person, size: 42, color: colors.primary)
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: IconButton.filled(
                      tooltip: 'Update avatar',
                      onPressed: _pickAvatar,
                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Your name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dream,
              decoration: const InputDecoration(labelText: 'Big dream'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _anchor,
              decoration: const InputDecoration(labelText: 'Your anchor'),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: _saveProfile,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('Save profile'),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'APPEARANCE',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: colors.primary),
            ),
            const SizedBox(height: 8),
            SegmentedButton<ThemeType>(
              segments: const <ButtonSegment<ThemeType>>[
                ButtonSegment<ThemeType>(
                  value: ThemeType.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment<ThemeType>(
                  value: ThemeType.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_outlined),
                ),
                ButtonSegment<ThemeType>(
                  value: ThemeType.system,
                  label: Text('System'),
                  icon: Icon(Icons.settings_brightness_outlined),
                ),
              ],
              selected: <ThemeType>{theme.currentTheme ?? ThemeType.light},
              onSelectionChanged: (Set<ThemeType> values) =>
                  theme.applyTheme(values.first),
              showSelectedIcon: false,
            ),
            const SizedBox(height: 20),
            Text(
              'PREFERENCES',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: colors.primary),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Daily reminders'),
              subtitle: const Text(
                'Receive your focus nudge at the chosen time.',
              ),
              value: app.notificationsEnabled,
              onChanged: _setNotifications,
              secondary: const Icon(Icons.notifications_outlined),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule_outlined),
              title: const Text('Focus window'),
              subtitle: Text(_focusTime.format(context)),
              trailing: const Icon(Icons.edit_outlined, size: 20),
              onTap: _editFocusWindow,
            ),
            const Divider(height: 24),
            Text(
              'DATA',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: colors.primary),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.restart_alt, color: colors.error),
              title: Text(
                'Reset all local data',
                style: TextStyle(color: colors.error),
              ),
              subtitle: const Text('Start onboarding again on this device.'),
              onTap: _resetApp,
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Thryve • Grow with intention',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
    if (!widget.showHeader) return settingsContent;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: <Widget>[
          ThryveSliverHeader(avatarUrl: app.user.avatarUrl),
          SliverToBoxAdapter(child: settingsContent),
        ],
      ),
    );
  }
}

