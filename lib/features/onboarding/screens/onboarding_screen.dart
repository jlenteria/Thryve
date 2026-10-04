import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_ext.dart';
import '../../../core/services/image_store.dart';
import '../../../core/state/app_view_model.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/fields/custom_text_form_field.dart';
import '../../../core/widgets/sheets.dart';
import '../view_models/onboarding_view_model.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OnboardingViewModel>(
      create: (BuildContext context) =>
          OnboardingViewModel(context.read<AppViewModel>()),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView();

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingViewModel>(
      builder: (_, OnboardingViewModel vm, _) {
        return PopScope(
          // System back steps backward through onboarding.
          canPop: vm.currentStep == 0,
          onPopInvokedWithResult: (bool didPop, _) {
            if (!didPop) {
              vm.prevStep();
            }
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: vm.currentStep > 0
                ? AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      tooltip: 'Back',
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      onPressed: vm.prevStep,
                    ),
                  )
                : null,
            body: PageView(
              controller: vm.pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const <Widget>[_StepOne(), _StepTwo(), _StepThree()],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'STEP $step OF $total',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: cs.primary,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: step / total,
            minHeight: 6,
            backgroundColor: cs.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
          ),
        ),
      ],
    );
  }
}

class _StepOne extends StatelessWidget {
  const _StepOne();

  Future<void> _explainWhy(BuildContext context) => showThryveSheet<void>(
    context,
    (BuildContext context) => ThryveBottomSheet(
      title: 'Why we ask',
      content: const Text(
        'Your name personalises your reminders. Your big dream becomes your '
        'first goal, so Thryve can show your progress from day one.\n\n'
        'Everything stays on this device.',
      ),
      actions: <Widget>[
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Consumer<OnboardingViewModel>(
      builder: (_, OnboardingViewModel vm, _) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _StepHeader(step: 1, total: 3),
                const SizedBox(height: 12),
                // Wordmark
                Center(
                  child: Text(
                    'Thryve',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: cs.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Hero Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: 160,
                        color: const Color(0xFF1A2E1A),
                        child: Image.asset(
                          'assets/images/step_1_banner.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: cs.surfaceContainer,
                            child: Icon(
                              Icons.landscape_outlined,
                              size: 48,
                              color: cs.outline,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.35),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              color: cs.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            'THE JOURNEY BEGINS',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: cs.primary,
                                  letterSpacing: 0.1,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Glass card
                Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.outlineVariant),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "What's your name?",
                        style: Theme.of(
                          context,
                        ).textTheme.displaySmall?.copyWith(color: cs.primary),
                      ),
                      const SizedBox(height: 10),
                      CustomTextFormField(
                        controller: vm.nameController,
                        onChanged: vm.onNameChanged,
                        hint: 'e.g. Juan Dela Cruz',
                        prefix: Padding(
                          padding: const EdgeInsets.only(left: 12, right: 8),
                          child: Icon(
                            Icons.person_outline,
                            color: cs.outline,
                            size: 22,
                          ),
                        ),
                        errorText: vm.showNameError
                            ? 'Please enter your name'
                            : null,
                        textStyle: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'And your big dream?',
                        style: Theme.of(
                          context,
                        ).textTheme.displaySmall?.copyWith(color: cs.primary),
                      ),
                      const SizedBox(height: 10),
                      CustomTextFormField(
                        controller: vm.dreamController,
                        onChanged: vm.onDreamChanged,
                        hint: 'Write down your main goal...',
                        prefix: Padding(
                          padding: const EdgeInsets.only(
                            left: 12,
                            right: 8,
                            bottom: 42,
                          ),
                          child: Icon(
                            Icons.auto_awesome_outlined,
                            color: cs.outline,
                            size: 22,
                          ),
                        ),
                        minLines: 3,
                        maxLines: 3,
                        errorText: vm.showDreamError
                            ? 'Please write your dream'
                            : null,
                        textStyle: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),

                      // Quote banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.secondaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: cs.secondaryContainer.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: cs.secondaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.park_outlined,
                                size: 18,
                                color: cs.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '"The best time to plant a tree was 20 years ago. The second best time is now."',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 13,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'Continue',
                        icon: Icons.arrow_forward,
                        onPressed: vm.continueFromStep1,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton.icon(
                          onPressed: () => _explainWhy(context),
                          icon: Icon(
                            Icons.help_outline,
                            size: 14,
                            color: cs.outline,
                          ),
                          label: Text(
                            'WHY ARE WE ASKING THIS?',
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(color: cs.outline),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  STEP 2 — Who are you doing this for?
// ─────────────────────────────────────────────────────────────────

class _StepTwo extends StatelessWidget {
  const _StepTwo();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Consumer<OnboardingViewModel>(
      builder: (_, OnboardingViewModel vm, _) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              children: <Widget>[
                const _StepHeader(step: 2, total: 3),
                const SizedBox(height: 32),
                Text(
                  'Who are you doing\nthis for?',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge?.copyWith(color: cs.onSurface),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'This becomes your anchor - the reason\nyou keep going.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Card
                Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: cs.outlineVariant),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Photo Picker
                      GestureDetector(
                        onTap: () async {
                          final bool ok = await vm.pickAnchorImage();
                          if (!ok && context.mounted) {
                            context.showSnack(
                              'Could not open the photo library.',
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          height: 160,
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: vm.anchorImage != null
                                  ? cs.primary
                                  : cs.outlineVariant,
                              width: vm.anchorImage != null ? 2 : 1,
                            ),
                            image: vm.anchorImage != null
                                ? DecorationImage(
                                    image: ImageStore.provider(vm.anchorImage)!,
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: vm.anchorImage == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: cs.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.add_a_photo_outlined,
                                        color: cs.primary,
                                        size: 26,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Add an Anchor Image (Optional)',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: cs.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cs.primary,
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const Icon(
                                          Icons.check_circle_outline,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Anchor Set',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      if (vm.anchorImage != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: vm.removeAnchorImage,
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Remove image'),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Text(
                        'Write your anchor',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        controller: vm.anchorController,
                        onChanged: vm.onAnchorChanged,
                        minLines: 4,
                        maxLines: 4,
                        textStyle: Theme.of(context).textTheme.bodyMedium,
                        hint: "e.g. For my daughter's future...",
                        errorText: vm.showAnchorError
                            ? 'Please write your anchor'
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Rooting pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.eco, size: 14, color: cs.primary),
                      const SizedBox(width: 6),
                      Text(
                        'ROOTING YOUR PURPOSE',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.primary,
                          letterSpacing: 0.08,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Continue',
                  icon: Icons.arrow_forward,
                  onPressed: vm.continueFromStep2,
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => vm.nextStep(),
                  child: Text(
                    'Skip for now',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                      decoration: TextDecoration.underline,
                      decorationColor: cs.primary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  STEP 3 — When will you grow? (Reminder time)
// ─────────────────────────────────────────────────────────────────

class _StepThree extends StatelessWidget {
  const _StepThree();

  Future<void> _onStart(
    BuildContext context, {
    required bool enableReminders,
  }) async {
    final OnboardingViewModel vm = context.read<OnboardingViewModel>();
    try {
      await vm.complete(enableReminders: enableReminders);
    } on Object {
      if (context.mounted) {
        context.showSnack('Something went wrong. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Consumer<OnboardingViewModel>(
      builder: (_, OnboardingViewModel vm, _) {
        final String body = vm.reminderCopy.body;
        final String highlight = vm.reminderCopy.highlight;
        final int splitIndex = body.indexOf(highlight);
        final String before = splitIndex >= 0
            ? body.substring(0, splitIndex)
            : body;
        final String after = splitIndex >= 0
            ? body.substring(splitIndex + highlight.length)
            : '';

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              children: <Widget>[
                // Step + 100%
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'STEP 3 OF 3',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '100%',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: 1.0,
                    minHeight: 6,
                    backgroundColor: cs.surfaceContainerHigh,
                    valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                  ),
                ),
                const SizedBox(height: 28),

                Text(
                  'When will you grow?',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge?.copyWith(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Consistency is the soil where\ncharacter takes root.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Time picker card
                Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: cs.outlineVariant),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _DrumPicker(
                            value: vm.reminderHour,
                            min: 1,
                            max: 12,
                            onChanged: (int h) => vm.setReminderHour(h),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              ':',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w600,
                                color: cs.primary,
                              ),
                            ),
                          ),
                          _DrumPicker(
                            value: vm.reminderMinute,
                            min: 0,
                            max: 59,
                            onChanged: (int m) => vm.setReminderMinute(m),
                            pad: true,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            children: <Widget>[
                              _AmPmButton(
                                label: 'AM',
                                selected: vm.isAm,
                                onTap: () => vm.setAmPm(isAm: true),
                              ),
                              const SizedBox(height: 6),
                              _AmPmButton(
                                label: 'PM',
                                selected: !vm.isAm,
                                onTap: () => vm.setAmPm(isAm: false),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: cs.outlineVariant.withValues(alpha: 0.4)),
                      const SizedBox(height: 8),
                      Text(
                        "We'll nudge you here, every single day",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Notification preview
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.2),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: cs.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    'DAILY THRYVE REMINDER',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: cs.onSurfaceVariant,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.6,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  vm.formattedTime,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: cs.onSurfaceVariant.withValues(
                                          alpha: 0.6,
                                        ),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Notification title
                            Text(
                              vm.reminderCopy.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.w700,
                                    height: 1.3,
                                  ),
                            ),
                            const SizedBox(height: 3),

                            // Notification body with highlighted anchor in green
                            RichText(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      height: 1.4,
                                    ),
                                children: <InlineSpan>[
                                  TextSpan(text: before),
                                  TextSpan(
                                    text: highlight,
                                    style: TextStyle(
                                      color: cs.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (after.isNotEmpty) TextSpan(text: after),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Preview of your daily motivation',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),

                PrimaryButton(
                  label: 'Start Thriving',
                  icon: Icons.arrow_forward,
                  isLoading: vm.isLoading,
                  onPressed: () => _onStart(context, enableReminders: true),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: vm.isLoading
                      ? null
                      : () => _onStart(context, enableReminders: false),
                  child: Text(
                    "I'll set this later",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Footer quote
                Column(
                  children: <Widget>[
                    Container(
                      width: 1,
                      height: 48,
                      color: cs.primary.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '"The best time to plant a tree was 20 years ago. The second best time is now."',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                        color: cs.onSurface.withValues(alpha: 0.4),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  DRUM PICKER
// ─────────────────────────────────────────────────────────────────

class _DrumPicker extends StatefulWidget {
  const _DrumPicker({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.pad = false,
  });
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final bool pad;

  @override
  State<_DrumPicker> createState() => _DrumPickerState();
}

class _DrumPickerState extends State<_DrumPicker> {
  static const double _itemExtent = 46;
  static const Duration _animDuration = Duration(milliseconds: 250);

  late final FixedExtentScrollController _controller;

  int get _count => widget.max - widget.min + 1;

  /// Wraps a raw (possibly negative or overflowing) wheel index into range.
  int _normalize(int rawIndex) => ((rawIndex % _count) + _count) % _count;

  String _fmt(int v) =>
      widget.pad ? v.toString().padLeft(2, '0') : v.toString();

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(
      initialItem: widget.value - widget.min,
    );
  }

  @override
  void didUpdateWidget(covariant _DrumPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only react to changes coming from outside the wheel.
    if (widget.value == oldWidget.value || !_controller.hasClients) {
      return;
    }
    final int current = _normalize(_controller.selectedItem);
    final int target = widget.value - widget.min;
    if (current == target) {
      return;
    }
    // Take the shortest path around the loop.
    int delta = target - current;
    if (delta > _count ~/ 2) {
      delta -= _count;
    } else if (delta < -(_count ~/ 2)) {
      delta += _count;
    }
    _controller.animateToItem(
      _controller.selectedItem + delta,
      duration: _animDuration,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 64,
      height: _itemExtent * 3,
      child: ListWheelScrollView.useDelegate(
        controller: _controller,
        itemExtent: _itemExtent,
        diameterRatio: 1.4,
        perspective: 0.004,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (int index) =>
            widget.onChanged(widget.min + _normalize(index)),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (BuildContext context, int index) {
            final int slot = _normalize(index);
            final bool isSelected = slot == widget.value - widget.min;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _controller.animateToItem(
                index,
                duration: _animDuration,
                curve: Curves.easeOut,
              ),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: _animDuration,
                  curve: Curves.easeOut,
                  style: TextStyle(
                    fontSize: isSelected ? 40 : 28,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? cs.primary
                        : cs.onSurface.withValues(alpha: 0.2),
                  ),
                  child: Text(_fmt(widget.min + slot)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  AM/PM TOGGLE
// ─────────────────────────────────────────────────────────────────

class _AmPmButton extends StatelessWidget {
  const _AmPmButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? cs.primaryContainer.withValues(alpha: 0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? cs.primary.withValues(alpha: 0.4)
                : cs.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: selected
                ? cs.primary
                : cs.onSurfaceVariant.withValues(alpha: 0.5),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
