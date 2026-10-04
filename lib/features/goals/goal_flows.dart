import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/app_view_model.dart';
import '../../data/models/goal.dart';
import 'screens/goal_achieved_screen.dart';
import 'screens/goal_detail_screen.dart';
import 'widgets/goal_form_sheet.dart';

/// Navigation flows shared by Home, the Goals hub and the detail screens.
abstract final class GoalFlows {
  static Future<void> openDetail(BuildContext context, String goalId) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => GoalDetailScreen(goalId: goalId),
        ),
      );

  static Future<void> openAchieved(BuildContext context, String goalId) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => GoalAchievedScreen(goalId: goalId),
        ),
      );

  /// Shows the celebration screen when an action just completed a goal.
  static Future<void> celebrateIf(
    BuildContext context, {
    required bool achieved,
    required String goalId,
  }) async {
    if (achieved && context.mounted) {
      await openAchieved(context, goalId);
    }
  }

  /// Asks for goal details and creates it. Returns the new goal, if any.
  static Future<Goal?> create(BuildContext context) async {
    final GoalDraft? draft = await showGoalForm(context);
    if (draft == null || !context.mounted) {
      return null;
    }
    return context.read<AppViewModel>().createGoal(
      title: draft.title,
      trackingType: draft.trackingType,
      targetAmount: draft.targetAmount,
      why: draft.why,
    );
  }
}
