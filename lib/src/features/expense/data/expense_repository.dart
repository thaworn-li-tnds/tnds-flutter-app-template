import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tnds_flutter_app/src/exceptions/app_exception.dart';
import 'package:tnds_flutter_app/src/features/expense/data/dto/request/create_expense_request.dart';
import 'package:tnds_flutter_app/src/features/expense/data/dto/response/create_expense_response.dart';
import 'package:tnds_flutter_app/src/features/expense/data/dto/response/get_expense_response.dart';
import 'package:tnds_flutter_app/src/features/expense/data/dto/response/get_expenses_response.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense.dart';

part 'expense_repository.g.dart';

/// Concrete repository (no abstract interface — the Riverpod provider
/// override is the only test/fake seam). Does I/O mapping ONLY: build request
/// → "network" → parse response DTO → return a domain noun. Business logic
/// belongs in `ExpenseService`.
///
/// TEMPLATE: simulated network. A real app extends the shared base repository
/// with an injected Dio client — which client is a backend crypto contract
/// that must be confirmed with the user (see
/// `.claude/skills/tnds-flutter-app/references/dio-clients.md`) — and each
/// method becomes `postOp('<op>', data: ...)` instead of reading [_records].
class ExpenseRepository {
  ExpenseRepository();

  /// In-memory stand-in for the backend's data store; wire-shaped maps so the
  /// DTO `fromJson` path runs exactly as it would against a real response.
  final List<Map<String, dynamic>> _records = [..._seedExpenseRecords];

  Future<void> _simulateNetwork() =>
      Future<void>.delayed(const Duration(milliseconds: 400));

  Future<List<Expense>> getExpenses() async {
    await _simulateNetwork();
    final response = GetExpensesResponse.fromJson({'items': _records});
    return response.toExpenses;
  }

  Future<Expense> getExpense(String id) async {
    await _simulateNetwork();
    final record = _records.where((r) => r['id'] == id).firstOrNull;
    // Typed exception, not a raw throw — callers can type-check the failure
    // mode and CommonErrorWidget renders its localized title/description.
    if (record == null) throw ExpenseNotFoundException();
    return GetExpenseResponse.fromJson({'item': record}).toExpense;
  }

  Future<Expense> createExpense(CreateExpenseRequest request) async {
    await _simulateNetwork();
    final record = <String, dynamic>{
      ...request.toJson(),
      'id': 'exp-${_records.length + 1}',
    };
    _records.add(record);
    return CreateExpenseResponse.fromJson({'item': record}).toExpense;
  }
}

@Riverpod(keepAlive: true)
ExpenseRepository expenseRepository(Ref ref) => ExpenseRepository();

const _seedExpenseRecords = <Map<String, dynamic>>[
  {
    'id': 'exp-1',
    'title': 'Lunch with the team',
    'category': 'FOOD',
    'amount': '320.50',
    'currency': 'THB',
    'date': '2026-06-08',
  },
  {
    'id': 'exp-2',
    'title': 'BTS to the office',
    'category': 'TRANSPORT',
    'amount': '62.00',
    'currency': 'THB',
    'date': '2026-06-09',
  },
  {
    'id': 'exp-3',
    'title': 'Movie night',
    'category': 'ENTERTAINMENT',
    'amount': '280.00',
    'currency': 'THB',
    'date': '2026-06-09',
  },
  {
    'id': 'exp-4',
    'title': 'Groceries',
    'category': 'SHOPPING',
    'amount': '1250.75',
    'currency': 'THB',
    'date': '2026-06-10',
  },
  // Previous month on purpose — the budget overview's month filter must
  // visibly exclude it.
  {
    'id': 'exp-5',
    'title': 'Last month dinner',
    'category': 'FOOD',
    'amount': '999.00',
    'currency': 'THB',
    'date': '2026-05-28',
  },
];
