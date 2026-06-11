import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tnds_flutter_app/src/features/expense/data/dto/response/get_budgets_response.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/budget.dart';

part 'budget_repository.g.dart';

/// Second repository of the feature — budgets are a different backend
/// resource than expenses, and keeping it separate makes the point that the
/// JOIN between the two happens in `BudgetService`, never down here.
/// I/O mapping ONLY, like `ExpenseRepository`.
///
/// TEMPLATE: simulated network. A real app extends the shared base repository
/// with an injected Dio client — which client is a backend crypto contract
/// that must be confirmed with the user (see
/// `.claude/skills/tnds-flutter-app/references/dio-clients.md`) — and
/// [getBudgets] becomes `postOp('getBudgets')` instead of reading [_record].
class BudgetRepository {
  BudgetRepository();

  /// Wire-shaped payload: note `month` at the root (NOT per item) and the
  /// category code strings — the DTO mapper undoes this normalization.
  final Map<String, dynamic> _record = _seedBudgetRecord;

  Future<void> _simulateNetwork() =>
      Future<void>.delayed(const Duration(milliseconds: 400));

  Future<List<Budget>> getBudgets() async {
    await _simulateNetwork();
    return GetBudgetsResponse.fromJson(_record).toBudgets;
  }
}

@Riverpod(keepAlive: true)
BudgetRepository budgetRepository(Ref ref) => BudgetRepository();

const _seedBudgetRecord = <String, dynamic>{
  'month': '2026-06',
  'items': [
    {'category': 'FOOD', 'limit': '1500.00', 'currency': 'THB'},
    {'category': 'TRANSPORT', 'limit': '50.00', 'currency': 'THB'},
    {'category': 'SHOPPING', 'limit': '2000.00', 'currency': 'THB'},
  ],
};
