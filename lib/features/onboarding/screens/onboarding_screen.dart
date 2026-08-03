import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'onboard_screen_view_model.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardScreenViewModel>(
      builder: (_, OnboardScreenViewModel vm, __) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: vm.currentStep > 0 ? AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: vm.prevStep,
            ),
          ) : null,
          body: PageView(
            controller: vm.pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: const <Widget>[
              _StepOne(),
            ],
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
  const _StepHeader({
    required this.step,
    required this.total
  });

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
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: cs.primary, letterSpacing: 0.1),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: step / total,
            minHeight: 6,
            backgroundColor: cs.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation(cs.primary),
          ),
        ),
      ],
    );
  }}

class _PrimaryButton extends StatelessWidget {
 
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.isLoading = false,
  });
  final String label;
  final IconData? icon;
  final bool isLoading;
  final VoidCallback? onTap;
 
  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          disabledBackgroundColor: cs.primary.withValues(alpha: 0.6),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 4,
          shadowColor: cs.primary.withValues(alpha: 0.3),
        ),
        child: isLoading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: cs.onPrimary),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    label,
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: cs.onPrimary),
                  ),
                  if (icon != null) ...<Widget>[
                    const SizedBox(width: 8),
                    Icon(icon, size: 22, color: cs.onPrimary),
                  ],
                ],
              ),
      ),
    );
  }
}
 
class _InputField extends StatelessWidget {
 
  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.errorText,
  });
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final String? errorText;
 
  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        prefixIcon: Padding(
          padding: EdgeInsets.only(
              left: 12, right: 8, top: maxLines > 1 ? 14 : 0),
          child: Icon(icon, color: cs.outline, size: 22),
        ),
        prefixIconConstraints:
            const BoxConstraints(),
      ),
    );
  }
}

class _StepOne extends StatefulWidget {
  const _StepOne();

  @override
  State<_StepOne> createState() => _StepOneState();
}

class _StepOneState extends State<_StepOne> {
  bool _showError = false;

  void _onContinue(OnboardScreenViewModel vm) {
    if (!vm.isStep1Valid) {
      setState(() => _showError = true);
      return;
    }

    setState(() => _showError = false);
    vm.nextStep();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Consumer<OnboardScreenViewModel>(
      builder: (_, OnboardScreenViewModel vm, __) {
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
              child: Text('Thryve',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                  letterSpacing: -0.5),
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
                    child: Image.network(
                      'https://images.unsplash.com/photo-1448375240586-882707db888b?w=800',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: cs.surfaceContainer,
                        child: Icon(Icons.landscape_outlined,
                            size: 48, color: cs.outline),
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
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                            color: cs.primary.withValues(alpha: 0.2)),
                      ),
                      child: Text('THE JOURNEY BEGINS',
                        style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                            color: cs.primary,
                            letterSpacing: 0.1),
                          ),
                    ),
                  )
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
                      offset: const Offset(0, 4))
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("What's your name?",
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(color: cs.primary)),
                  const SizedBox(height: 10),
                  _InputField(
                    controller: vm.nameController,
                    hint: 'E.g. Alex',
                    icon: Icons.person_outline,
                    errorText: _showError && vm.name.isEmpty
                        ? 'Please enter your name'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  Text('And your big dream?',
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(color: cs.primary)),
                  const SizedBox(height: 10),
                  _InputField(
                    controller: vm.dreamController,
                    hint: 'Write down your main goal...',
                    icon: Icons.auto_awesome_outlined,
                    maxLines: 3,
                    errorText: _showError && vm.dream.isEmpty
                        ? 'Please write your dream'
                        : null,
                  ),
                  const SizedBox(height: 20),
 
                  // Quote banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: cs.secondaryContainer.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                              color: cs.secondaryContainer,
                              shape: BoxShape.circle),
                          child: Icon(Icons.park_outlined,
                              size: 18, color: cs.primary),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '"The best time to plant a tree was 20 years ago. The second best time is now."',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _PrimaryButton(
                      label: 'Continue',
                      icon: Icons.arrow_forward,
                      onTap: () {
                        _onContinue(vm);
                      },
                ),
                const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.help_outline, size: 14, color: cs.outline),
                      label: Text('WHY ARE WE ASKING THIS?',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: cs.outline)),
                    ),
                  ),
                ],
              ),
            ),
          ]
        )
      )
    );
      },
    ); 
  }
}
