import 'package:tnds_flutter_app/src/exceptions/app_exception.dart';
import 'package:tnds_flutter_app/src/features/expense/data/dto/request/create_expense_request.dart';
import 'package:tnds_flutter_app/src/features/expense/data/dto/request/update_expense_request.dart';
import 'package:tnds_flutter_app/src/features/expense/data/expense_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/money.dart';

/// Deterministic fixture shared by the fake and test assertions.
const kFakeExpenses = <Expense>[
  Expense(
    id: 'exp-1',
    title: 'Lunch with the team',
    category: ExpenseCategory.food,
    money: Money(amount: 320.50),
    date: '2026-06-08',
  ),
  Expense(
    id: 'exp-2',
    title: 'BTS to the office',
    category: ExpenseCategory.transport,
    money: Money(amount: 62.00),
    date: '2026-06-09',
  ),
  Expense(
    id: 'exp-3',
    title: 'Movie night',
    category: ExpenseCategory.entertainment,
    money: Money(amount: 280.00),
    date: '2026-06-09',
  ),
];

/// `implements` (never `extends`) the concrete repository — same public
/// surface, canned data. Injected in tests via
/// `overrideRepos: [expenseRepositoryProvider.overrideWith(...)]`.
/// Widget tests keep [addDelay] false so `pumpAndSettle` terminates.
class FakeExpenseRepository implements ExpenseRepository {
  FakeExpenseRepository({
    this.addDelay = false,
    List<Expense>? expenses,
    this.errorToThrow,
    this.writeError,
  }) : _expenses = expenses ?? kFakeExpenses;

  final bool addDelay;
  final List<Expense> _expenses;

  /// When set, every method throws it — for whole-screen error-state tests.
  final Object? errorToThrow;

  /// When set, only the WRITE methods (create/update/delete) throw it — so a
  /// screen can load its data and then fail the mutation (inline-error tests).
  final Object? writeError;

  /// Spy: requests passed to [createExpense], for test assertions.
  final List<CreateExpenseRequest> createdRequests = [];

  /// Spy: `(id, request)` pairs passed to [updateExpense].
  final List<({String id, UpdateExpenseRequest request})> updatedRequests = [];

  /// Spy: ids passed to [deleteExpense].
  final List<String> deletedIds = [];

  Future<void> _delay() async {
    if (addDelay) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
  }

  Future<void> _maybeThrow() async {
    await _delay();
    if (errorToThrow != null) throw errorToThrow!;
  }

  Future<void> _maybeThrowWrite() async {
    await _maybeThrow();
    if (writeError != null) throw writeError!;
  }

  @override
  Future<List<Expense>> getExpenses() async {
    await _maybeThrow();
    return _expenses;
  }

  @override
  Future<Expense> getExpense(String id) async {
    await _maybeThrow();
    // Mirrors the real repository's failure contract.
    final expense = _expenses.where((expense) => expense.id == id).firstOrNull;
    if (expense == null) throw ExpenseNotFoundException();
    return expense;
  }

  @override
  Future<Expense> createExpense(CreateExpenseRequest request) async {
    await _maybeThrowWrite();
    createdRequests.add(request);
    return Expense(
      id: 'exp-created',
      title: request.title ?? '',
      category: ExpenseCategory.from(request.category),
      money: Money(amount: double.tryParse(request.amount ?? '') ?? 0),
      date: request.date ?? '',
    );
  }

  @override
  Future<Expense> updateExpense(String id, UpdateExpenseRequest request) async {
    await _maybeThrowWrite();
    updatedRequests.add((id: id, request: request));
    // Mirror the real repository's not-found contract.
    if (_expenses.every((expense) => expense.id != id)) {
      throw ExpenseNotFoundException();
    }
    return Expense(
      id: id,
      title: request.title ?? '',
      category: ExpenseCategory.from(request.category),
      money: Money(amount: double.tryParse(request.amount ?? '') ?? 0),
      date: request.date ?? '',
    );
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _maybeThrowWrite();
    if (_expenses.every((expense) => expense.id != id)) {
      throw ExpenseNotFoundException();
    }
    deletedIds.add(id);
  }
}
