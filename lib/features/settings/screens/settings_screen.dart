import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_ext.dart';
import '../../../core/services/image_store.dart';
import '../../../core/state/app_view_model.dart';
import '../../../core/theme/theme_manager.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/sheets.dart';
import '../../../core/widgets/thryve_page.dart';
import '../../../data/models/user_profile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _dream;
  late final TextEditingController _anchor;

  AppViewModel get _app => context.read<AppViewModel>();

  @override
  void initState() {
    super.initState();
    final UserProfile user = _app.user;
    _name = TextEditingController(text: user.name);
    _dream = TextEditingController(text: user.bigDream ?? '');
    _anchor = TextEditingController(text: user.anchor ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _dream.dispose();
    _anchor.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_form.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    await _app.updateProfile(
      name: _name.text,
      dream: _dream.text,
      anchor: _anchor.text,
    );
    if (mounted) {
      context.showSnack('Profile updated.');
    }
  }

  Future<void> _pickAvatar() async {
    try {
      final String? ref = await ImageStore.pickFromGallery(maxDimension: 600);
      if (ref != null) {
        _app.setAvatar(ref);
      }
    } on Object {
      if (mounted) {
        context.showSnack('Could not open the photo library.');
      }
    }
  }

  Future<void> _editReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _app.user.reminderTime,
    );
    if (picked != null) {
      await _app.setReminderTime(picked);
    }
  }

  Future<void> _setReminders(bool enabled) async {
    final bool ok = await _app.setNotificationsEnabled(enabled);
    if (!ok && mounted) {
      context.showSnack(
        'Reminders are off in system settings. Allow notifications for '
        'Thryve to receive them.',
      );
    }
  }

  Future<void> _reset() async {
    final bool confirmed = await confirmDestructive(
      context,
      title: 'Reset Thryve?',
      message:
          'This removes your goals, practices, Wall, reviews and profile '
          'from this device. This cannot be undone.',
      confirmLabel: 'Reset',
    );
    if (confirmed) {
      // The app root switches back to onboarding once state is cleared.
      await _app.resetApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppViewModel app = context.watch<AppViewModel>();
    final ThemeManager theme = context.watch<ThemeManager>();
    final ColorScheme colors = context.colors;

    return ThryveTabPage(
      children: <Widget>[
        const PageHeading(
          title: 'Settings',
          subtitle: 'Shape your Thryve experience.',
        ),
        const SizedBox(height: 24),
        SectionLabel('Profile', color: colors.primary),
        const SizedBox(height: 12),
        Center(
          child: Stack(
            children: <Widget>[
              Avatar(source: app.user.avatar, radius: 42),
              Positioned(
                right: -4,
                bottom: -4,
                child: IconButton.filled(
                  tooltip: 'Change photo',
                  onPressed: _pickAvatar,
                  icon: const Icon(Icons.camera_alt_outlined, size: 18),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Form(
          key: _form,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Your name'),
                validator: (String? value) =>
                    value == null || value.trim().isEmpty
                    ? 'Please enter your name'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dream,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Big dream'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _anchor,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Your anchor',
                  helperText: 'Who or what you are doing this for',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _saveProfile,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Save profile'),
          ),
        ),
        const SizedBox(height: 24),
        SectionLabel('Appearance', color: colors.primary),
        const SizedBox(height: 10),
        SegmentedButton<ThemeMode>(
          segments: const <ButtonSegment<ThemeMode>>[
            ButtonSegment<ThemeMode>(
              value: ThemeMode.light,
              label: Text('Light'),
              icon: Icon(Icons.light_mode_outlined),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.dark,
              label: Text('Dark'),
              icon: Icon(Icons.dark_mode_outlined),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.system,
              label: Text('System'),
              icon: Icon(Icons.settings_brightness_outlined),
            ),
          ],
          selected: <ThemeMode>{theme.themeMode},
          onSelectionChanged: (Set<ThemeMode> values) =>
              theme.setThemeMode(values.first),
          showSelectedIcon: false,
        ),
        const SizedBox(height: 24),
        SectionLabel('Reminders', color: colors.primary),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.notifications_outlined),
          title: const Text('Daily reminder'),
          subtitle: const Text('A gentle nudge at your focus time.'),
          value: app.notificationsEnabled,
          onChanged: _setReminders,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          enabled: app.notificationsEnabled,
          leading: const Icon(Icons.schedule_outlined),
          title: const Text('Focus time'),
          subtitle: Text(Formatters.timeOfDay(app.user.reminderTime)),
          trailing: const Icon(Icons.edit_outlined, size: 20),
          onTap: _editReminderTime,
        ),
        const Divider(height: 32),
        SectionLabel('Data', color: colors.primary),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.restart_alt, color: colors.error),
          title: Text(
            'Reset all local data',
            style: TextStyle(color: colors.error),
          ),
          subtitle: const Text('Start onboarding again on this device.'),
          onTap: _reset,
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Thryve · Grow with intention',
            style: context.text.bodySmall,
          ),
        ),
      ],
    );
  }
}
