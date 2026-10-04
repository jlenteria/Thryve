import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../models/models.dart';
import '../../core/services/notification_service.dart';
import '../../view_models/onboarding_view_model.dart';
import '../../view_models/app_view_model.dart';

class OnboardingFlow extends StatelessWidget {
  const OnboardingFlow({super.key});

  Future<void> _goToMain(BuildContext context, OnboardingViewModel vm) async {
    final String name = vm.nameController.text.trim();
    final String dream = vm.dreamController.text.trim();
    if (name.isEmpty || dream.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add your name and big dream to continue.'),
        ),
      );
      return;
    }
    await NotificationService.scheduleDaily(
      hour: vm.focusTime.hour,
      minute: vm.focusTime.minute,
      anchor: vm.anchor,
    );
    if (!context.mounted) return;
    await context.read<AppViewModel>().completeOnboarding(
      name: name,
      dream: dream,
      anchor: vm.anchorController.text.trim().isEmpty
          ? 'My future'
          : vm.anchorController.text.trim(),
      anchorImageUrl: vm.anchorImageUrl,
      focusWindow: vm.focusTime.format(context),
      trackingType: vm.trackingType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingViewModel(),
      child: Consumer<OnboardingViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                    child: Column(
                      children: [
                        Text(
                          'STEP ${vm.step + 1} OF 3',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 1.5,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ProgressBar(
                          progress: vm.progress,
                          height: 4,
                          fillColor: AppColors.primary,
                          trackColor: AppColors.outlineVariant.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: vm.pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _Step1(
                          nameController: vm.nameController,
                          dreamController: vm.dreamController,
                          trackingType: vm.trackingType,
                          onTrackingTypeChanged: vm.setTrackingType,
                          onContinue: () {
                            if (vm.nameController.text.trim().isEmpty ||
                                vm.dreamController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter your name and big dream.',
                                  ),
                                ),
                              );
                              return;
                            }
                            vm.nextStep();
                          },
                        ),
                        _Step2(
                          anchorController: vm.anchorController,
                          anchorImageUrl: vm.anchorImageUrl,
                          onAnchorImageChanged: vm.setAnchorImageUrl,
                          onContinue: vm.nextStep,
                          onSkip: vm.nextStep,
                        ),
                        _Step3(
                          focusTime: vm.focusTime,
                          onTimeChanged: vm.setFocusTime,
                          onContinue: () => _goToMain(context, vm),
                          onSkip: () => _goToMain(context, vm),
                          name: vm.name,
                          anchor: vm.anchor,
                        ),
                      ],
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
}

class _Step1 extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController dreamController;
  final VoidCallback onContinue;
  final GoalTrackingType trackingType;
  final ValueChanged<GoalTrackingType> onTrackingTypeChanged;

  const _Step1({
    required this.nameController,
    required this.dreamController,
    required this.onContinue,
    required this.trackingType,
    required this.onTrackingTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          ThryveCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      NetworkImageSafe(
                        url: DemoData.forestBanner,
                        height: 160,
                        width: double.infinity,
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            'Thryve',
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  shadows: [
                                    Shadow(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  "What's your name?",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'E.g. Alex',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'How will you track it?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SegmentedButton<GoalTrackingType>(
                  segments: const <ButtonSegment<GoalTrackingType>>[
                    ButtonSegment(
                      value: GoalTrackingType.progress,
                      label: Text('Personal'),
                      icon: Icon(Icons.flag_outlined),
                    ),
                    ButtonSegment(
                      value: GoalTrackingType.money,
                      label: Text('Financial'),
                      icon: Icon(Icons.payments_outlined),
                    ),
                  ],
                  selected: <GoalTrackingType>{trackingType},
                  onSelectionChanged: (Set<GoalTrackingType> values) {
                    onTrackingTypeChanged(values.first);
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'And your big dream?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dreamController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Write down your main goal...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.auto_awesome),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(
                            alpha: 0.4,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.park_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '"The best time to plant a tree was 20 years ago. The second best time is now."',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: AppColors.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Continue',
            icon: Icons.arrow_forward,
            onPressed: onContinue,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (BuildContext context) => ThryveBottomSheet(
                title: 'Why this matters',
                content: const Text(
                  'Naming your goal makes it concrete. Your answer is stored only on this device and can be changed later.',
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Got it'),
                  ),
                ],
              ),
            ),
            child: Text(
              'WHY ARE WE ASKING THIS?',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Step2 extends StatelessWidget {
  final TextEditingController anchorController;
  final String? anchorImageUrl;
  final ValueChanged<String> onAnchorImageChanged;
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const _Step2({
    required this.anchorController,
    required this.anchorImageUrl,
    required this.onAnchorImageChanged,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            'Who are you doing this for?',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.displayMedium?.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'This becomes your anchor — the reason you keep going.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          ThryveCard(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _setAnchorImage(context),
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: anchorImageUrl != null
                        ? NetworkImageSafe(
                            url: anchorImageUrl!,
                            width: double.infinity,
                            height: 160,
                            borderRadius: BorderRadius.circular(12),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer.withValues(
                                    alpha: 0.25,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add_a_photo_outlined,
                                  color: AppColors.primary,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Add an Anchor Image (Optional)',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Write your anchor',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: anchorController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: "e.g. For my daughter's future...",
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.spa_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'ROOTING YOUR PURPOSE',
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(label: 'Continue', onPressed: onContinue),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onSkip,
            child: Text(
              'Skip for now',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setAnchorImage(BuildContext context) async {
    String imageUrl = anchorImageUrl ?? '';
    final bool? saved = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) => ThryveBottomSheet(
        title: 'Anchor image',
        content: TextFormField(
          initialValue: anchorImageUrl,
          autofocus: true,
          onChanged: (String value) => imageUrl = value,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Image URL',
            hintText: 'https://...',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Use image'),
          ),
        ],
      ),
    );
    if (saved == true) onAnchorImageChanged(imageUrl);
  }
}

class _Step3 extends StatelessWidget {
  final TimeOfDay focusTime;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final String name;
  final String anchor;

  const _Step3({
    required this.focusTime,
    required this.onTimeChanged,
    required this.onContinue,
    required this.onSkip,
    required this.name,
    required this.anchor,
  });

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: focusTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onTimeChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final hour = focusTime.hourOfPeriod == 0 ? 12 : focusTime.hourOfPeriod;
    final minute = focusTime.minute.toString().padLeft(2, '0');
    final period = focusTime.period == DayPeriod.am ? 'AM' : 'PM';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thryve',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'STEP 3 OF 3',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 4),
          const ProgressBar(progress: 1.0, height: 4),
          const SizedBox(height: 28),
          Text(
            'When will you grow?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Consistency is the soil where character takes root.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          ThryveCard(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _pickTime(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _TimeDigit(value: hour.toString().padLeft(2, '0')),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          ':',
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                color: AppColors.primary.withValues(alpha: 0.4),
                              ),
                        ),
                      ),
                      _TimeDigit(value: minute),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          _PeriodChip(label: 'AM', selected: period == 'AM'),
                          const SizedBox(height: 6),
                          _PeriodChip(label: 'PM', selected: period == 'PM'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Tap to adjust your focus window',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAILY THRYVE REMINDER',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 2),
                      Text.rich(
                        TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            const TextSpan(text: '"30 minutes today, for '),
                            TextSpan(
                              text: anchor.toLowerCase().contains('for')
                                  ? anchor
                                  : 'your $anchor',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: '."'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Text('Now', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Preview of your daily motivation',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Start Thriving',
            icon: Icons.arrow_forward,
            onPressed: onContinue,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onSkip,
            child: Text(
              "I'll set this later",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '"The best time to plant a tree was 20 years ago. The second best time is now."',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeDigit extends StatelessWidget {
  final String value;
  const _TimeDigit({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        value,
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
          color: AppColors.primary.withValues(alpha: 0.7),
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _PeriodChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primaryContainer.withValues(alpha: 0.4)
            : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: selected
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
