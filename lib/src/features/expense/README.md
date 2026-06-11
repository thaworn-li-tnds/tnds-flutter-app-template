# Expense — ฟีเจอร์ตัวอย่างสำหรับเรียนรู้การเขียน feature ตั้งแต่ต้นจนจบ

ฟีเจอร์นี้คือ **ตัวอย่างอ้างอิงของ feature ธรรมดา** (ไม่ใช่ launchable module) ตามมาตรฐาน
`.claude/skills/tnds-flutter-app/` — ใช้ไล่อ่านเพื่อเข้าใจว่าโค้ดแต่ละชั้นวางตรงไหน คุยกันอย่างไร
และเขียน test อย่างไร ก่อนเริ่มเขียน feature จริงของตัวเอง

## Call chain: ทุก request วิ่งครบ 3 hop เสมอ

```
presentation/expense_list_controller.dart   ExpenseListController (@riverpod, auto-dispose)
        │  ref.read(expenseServiceProvider)
        ▼
application/expense_service.dart            ExpenseService (plain class + Ref)
        │  _repo getter → ref.read(expenseRepositoryProvider)
        ▼
data/expense_repository.dart                ExpenseRepository (@Riverpod(keepAlive: true))
        │  "network" → DTO.fromJson → toExpense (DTO → domain)
        ▼
domain/expense.dart                         Expense (pure Dart noun)
```

- Presentation **ห้าม** import `data/` หรืออ่าน `*RepositoryProvider` — ต้องผ่าน Service เท่านั้น
- `@riverpod Future<T> getXxx(Ref ref)` ที่เรียก repository = **ต้องห้าม** (ดู service-layer.md)

## Domain: ออกแบบ data model แบบ OOP

โมเดลใน `domain/` มี **2 บทบาท** — อยู่โฟลเดอร์เดียวกัน แต่ชื่อ + doc comment บอกบทบาทเสมอ:

- **Entity / Value object** = ความจริงของ business มีตัวตน/ค่าของตัวเอง ไม่ขึ้นกับหน้าจอไหน
- **Read model** (suffix `*Overview` / `*Summary` / `*Status`) = "คำตอบของ 1 คำถาม" ที่ Service
  ประกอบขึ้น — ไม่มี identity, ไม่ถูก persist, ไม่ขึ้น wire
- ส่วน **UI state จริง ๆ** (filter ที่เลือก, ค่าในฟอร์ม) ไม่ใช่ทั้งสองอย่าง — อยู่ใน controller เท่านั้น

| ไฟล์ | บทบาท | สอนเรื่อง |
|---|---|---|
| [domain/money.dart](domain/money.dart) | Value object | เท่ากันด้วยค่า (`==`/`hashCode`), พก behavior ของตัวเอง (`operator +`/`-`, `defaultCurrency`) แทนการส่ง `double` ดิบไปทั่วแอป; การ format แสดงผล (ใช้ `NumberFormat` จาก intl) ไม่อยู่ใน domain |
| [domain/expense_category.dart](domain/expense_category.dart) | Value object | **Enum with behavior** — `wireValue`/`labelKey` อยู่บน enum, parse แบบ tolerant (`from()` ไม่รู้จัก → `other`); **ไม่มี IconData** เพราะ Flutter type ห้ามเข้า domain |
| [domain/expense.dart](domain/expense.dart) | Entity | มีตัวตนด้วย `id`, ประกอบจาก `Money` + `ExpenseCategory` |
| [domain/budget.dart](domain/budget.dart) | Entity | แผนงบ 1 หมวด/เดือน (identity = `category`+`month`) — สังเกตว่า `month` ถูก mapper flatten ลงมาจาก root ของ response (wire ไม่ได้หน้าตาแบบนี้) |
| [domain/expense_summary.dart](domain/expense_summary.dart) | Read model | **Aggregate** — เก็บผลลัพธ์อย่างเดียว การคำนวณอยู่ที่ `ExpenseService.summarize` |
| [domain/expense_overview.dart](domain/expense_overview.dart) | Read model | คำตอบของหน้า list — expenses + summary เป็น noun เดียวที่ controller expose |
| [domain/category_budget_status.dart](domain/category_budget_status.dart) | Read model | **Node ใน object graph** — ถือ `Budget?` + `List<Expense>` ตัวจริง (ไม่ใช่ id/code); getter `remaining`/`utilization`/`isOverBudget` เป็น **derived** ไม่มีบน wire; `budget == null` คือ semantic null ("ใช้เงินโดยไม่มีแผน") |
| [domain/budget_overview.dart](domain/budget_overview.dart) | Read model | ผลลัพธ์ของการ **join 2 endpoints** — ไม่มี response ตัวไหนหน้าตาเหมือน object นี้ |
| [presentation/widgets/expense_category_icon.dart](presentation/widgets/expense_category_icon.dart) | — | คู่ตรงข้ามของ enum: behavior ที่เป็น Flutter type (`IconData`) อยู่ฝั่ง presentation |
| [presentation/widgets/money_format.dart](presentation/widgets/money_format.dart) | — | คู่ตรงข้ามของ `Money`: `formatted` ใช้ `NumberFormat` (intl) ซึ่งเป็น dependency ฝั่งแสดงผล จึงเป็น extension ใน presentation |

กติกา domain: ชื่อเป็น **คำนาม**, `const` constructor, field non-nullable มี default, ห้าม import
flutter/riverpod/dio

## Budget: domain คือ object graph ไม่ใช่เงาของ response

Slice นี้มีไว้สอนว่า**ห้าม map response จาก datasource มาตรง ๆ** — ไล่อ่านตามนี้:

1. **Wire เป็น normalized data** —
   [get_budgets_response.dart](data/dto/response/get_budgets_response.dart): `month` อยู่ระดับ
   root ของ response (ไม่อยู่ใน item) และแต่ละ item อ้างหมวดด้วย code string; mapper `toBudgets`
   flatten month ลงทุก `Budget` + resolve code → enum **อย่าสร้าง domain `Budgets {month, items}`
   ที่ mirror wire** — นั่นคือ response ที่เปลี่ยนชื่อเฉย ๆ
2. **Join เกิดที่ Service** — [budget_service.dart](application/budget_service.dart):
   `BudgetRepository` กับ `ExpenseRepository` ต่างคนต่างคืน list แบน ๆ; `BudgetService` คือคนเดียว
   ที่รู้ความสัมพันธ์ — จับคู่ budget↔expenses ต่อหมวด, กรอง expense ตามเดือน (ISO-8601 prefix),
   fold ยอด spent, แล้วสร้าง status จาก **union** ของสองฝั่ง (งบที่ไม่มีการใช้ และการใช้ที่ไม่มีงบ
   ต้องโผล่ทั้งคู่ — inner join จะทำข้อมูลหายเงียบ ๆ)
3. **ตัวเลขบนจอเป็น derived ทั้งหมด** — `spent`/`remaining`/`utilization`/`isOverBudget`
   ไม่มีอยู่บน wire เลยสักตัว; เส้นแบ่งคือ "fold ข้าม collection = Service, derive จาก field
   ตัวเอง = domain getter" (อ่าน doc ใน `category_budget_status.dart`)
4. **Bonus 2 บทเรียนใน `_fetchBoth`** — ยิง 2 endpoints ขนานด้วย record `.wait` แล้วต้อง unwrap
   `ParallelWaitError` ไม่งั้น typed `AppException` จะกลายเป็น `UnknownException` บนจอ; และ
   `dart:async` ต้อง import แบบ prefix เพราะ `AsyncError` ของ Riverpod shadow ของ SDK —
   catch clause ที่ไม่ prefix จะ match ผิด type แบบเงียบ ๆ

ดู test ประกอบ: [budget_service_test.dart](../../../../test/src/features/expense/application/budget_service_test.dart)
(union/month-filter/ordering/typed-error) และ
[get_budgets_response_test.dart](../../../../test/src/features/expense/data/dto/response/get_budgets_response_test.dart)
(การ flatten month)

## ไล่ 1 tap: กด Save ในหน้า Create

1. [create_expense_screen.dart](presentation/create_expense_screen.dart) — validate form แล้วเรียก
   `ref.read(createExpenseControllerProvider.notifier).submit(...)` (**ref.read ใน callback**)
2. [create_expense_controller.dart](presentation/create_expense_controller.dart) —
   `state = AsyncValue.loading()` → `state = await AsyncValue.guard(...)` error ใด ๆ กลายเป็น
   `AsyncError` ไม่มีการกลืน
3. [expense_service.dart](application/expense_service.dart) — ประกอบ `CreateExpenseRequest`
   จาก param แบบ domain (หน้าจอไม่เคยเห็น DTO); วันที่ default อ่านจาก `clockProvider`
   (`lib/src/shared/application/clock.dart`) **ไม่เรียก `DateTime.now()` ตรง ๆ** — test จึง pin
   เวลาได้ (ดู `createExpense defaults the date to the injected clock's today`)
4. [expense_repository.dart](data/expense_repository.dart) — ยิง "network" → parse
   `CreateExpenseResponse.fromJson` → คืน `Expense` (domain noun)
5. กลับมาที่หน้าจอ: `ref.listen` เห็นผลสำเร็จ → `ref.invalidate(expenseListControllerProvider)` +
   `context.pop()` — หน้า list โหลดใหม่เองเพราะ watch provider เดิมอยู่

## Update / Delete: write action ที่อ่านข้อมูลก่อน

ทั้ง 2 action นี้ต่อยอด pattern เดิมแบบเป๊ะ ๆ — สังเกตว่า **ไม่มี domain ใหม่** เกิดขึ้นเลย
(แก้/ลบ คือ use case บน entity เดิม) มีแค่ DTO + method + controller + screen เพิ่ม:

- **Edit** — [edit_expense_screen.dart](presentation/edit_expense_screen.dart) **อ่านก่อนเขียน**:
  หน้าจอ gate ด้วย `expenseDetailControllerProvider(id)` (re-use read path เดิม ไม่ส่ง entity ผ่าน
  `extra`) แล้ว prefill ฟอร์มจากค่าที่โหลดมา; กด Save → [edit_expense_controller.dart](presentation/edit_expense_controller.dart)
  (submit controller เหมือน create) → `ExpenseService.updateExpense` ประกอบ
  [UpdateExpenseRequest](data/dto/request/update_expense_request.dart) (id เป็น argument ของ
  repository call **ไม่ใช่ field ใน body**) → สำเร็จแล้ว invalidate ทั้ง list และ detail(id) + pop
- **Delete** — ปุ่มใน [expense_detail_screen.dart](presentation/expense_detail_screen.dart) เปิด
  confirm dialog (ปิด dialog ด้วย `Navigator.of(dialogContext).pop(...)` ไม่ใช่ go_router) →
  [delete_expense_controller.dart](presentation/delete_expense_controller.dart) ใช้ state `bool?`
  (`null` = idle, `true` = ลบแล้ว — convention null-is-idle เดียวกับ create) เพื่อให้ `ref.listen`
  แยก "ลบสำเร็จจริง" ออกจาก build แรกได้ → `ExpenseService.deleteExpense` → invalidate list + pop
- ทั้งคู่ใช้ `AsyncValue.guard` → error เด้งเป็น inline error ผ่าน `AppException.parse`; repository
  โยน `ExpenseNotFoundException` แบบ typed เมื่อ id ไม่มีจริง (สัญญาเดียวกับ `getExpense`)
- ฟอร์ม create/edit ใช้ widget เดียวกัน [widgets/expense_form_fields.dart](presentation/widgets/expense_form_fields.dart)
  (key + validator ชุดเดียว) — แต่ละหน้าถือแค่ `Form` key / controller / ปุ่ม / submit target ของตัวเอง

## Riverpod patterns ที่เห็นในฟีเจอร์นี้

| Pattern | ไฟล์ | ใช้เมื่อ |
|---|---|---|
| Read controller (โหลดใน `build()`) | `expense_list_controller.dart` | หน้าจอโหลดข้อมูลทันทีที่เข้า |
| Read + family param | `expense_detail_controller.dart` | state แยกชุดต่อ 1 ค่า param (`expenseId`) |
| Submit controller (idle `null` + guard) | `create_expense_controller.dart`, `edit_expense_controller.dart` | ฟอร์ม/ปุ่มที่ user สั่ง action |
| Submit controller แบบ void (`bool?` idle/done) | `delete_expense_controller.dart` | action ที่ไม่คืนค่า แต่ต้องแยก idle ออกจาก "สำเร็จ" |
| Sync state controller | `expense_filter_controller.dart` | UI state ล้วน ๆ (filter ที่เลือก) |
| **Derived provider** (`ref.watch` compose) | `filteredExpenseOverview` ใน `expense_list_controller.dart` | คำนวณค่าจาก provider อื่น ไม่แตะ repository |

**จุดสำคัญที่สุด — single source of truth:** ใน
[expense_list_screen.dart](presentation/expense_list_screen.dart) ทั้ง `_SummaryHeader` (ยอดรวม)
และ `_ExpenseListView` (รายการ) ต่างคนต่าง `ref.watch(filteredExpenseOverviewProvider)`
พอกด filter chip หนึ่งครั้ง (`select()` เขียน state ที่เดียว) **ทั้งสอง widget อัปเดตพร้อมกันเอง**
ไม่ต้องเขียนโค้ด sync สองที่ — ดู test
`one filter tap updates the list AND the total together` ประกอบ

สรุปการใช้ `ref`: `watch` ใน `build()` เท่านั้น · `read` ใน callback · `listen` สำหรับ side effect
(navigate/pop) · `invalidate` หลัง mutation สำเร็จ

## การ handle exception

| กติกา | จุดที่อยู่ในโค้ด |
|---|---|
| Failure mode ที่ต้อง handle ต่างกัน = subclass ของ `AppException` พร้อม `LocaleKeys` ของตัวเอง | `ExpenseNotFoundException` ใน `lib/src/exceptions/app_exception.dart` — **ต้องอยู่ไฟล์นั้น** เพราะ `AppException` เป็น `sealed`; call site เช็คด้วย type (`is ExpenseNotFoundException`) ห้าม string-match ข้อความ |
| Repository โยน exception แบบ typed | `getExpense` หา id ไม่เจอ → `throw ExpenseNotFoundException()` (fake โยนตัวเดียวกัน — สัญญาเดียวกับของจริง) |
| Controller ใช้ `AsyncValue.guard` เท่านั้น ห้าม try/catch กลืน | `create_expense_controller.dart` — error ทุกตัวไหลไป `AsyncError` ให้ UI/logger เห็น |
| UI แสดง error แบบ localized ผ่าน `AppException.parse` | โหลดพัง → `SystemAsyncValueWidget` → `CommonErrorWidget` (render title/description ของ exception); submit พัง → inline error ใน `create_expense_screen.dart` |
| ไม่ต้อง log เอง | `AsyncErrorLogger` (ProviderObserver ใน `lib/src/exceptions/`) log ทุก provider ที่เป็น `AsyncError` ผ่าน `ErrorLogger` อัตโนมัติ |

ดู test ประกอบ: `an unknown id degrades to the typed not-found error` (widget) และ
`getExpense of an unknown id throws the typed exception` (service)

## จุดที่ "ของจำลอง" จะกลายเป็นของจริง

`ExpenseRepository` จำลอง network ด้วย in-memory records + delay เพื่อให้ template รันได้โดยไม่มี
backend — แต่ข้อมูลยังไหลผ่าน `fromJson → toDomain` เหมือนของจริงทุกประการ เมื่อสร้างแอปจริง:

1. เลือก Dio client — **ต้องถามทีม/ผู้ใช้เสมอ** เพราะเป็น crypto contract ของ backend
   (อ่าน `references/dio-clients.md` ก่อน)
2. แทน `_simulateNetwork()` + `_records` ด้วย `postOp('<op>', data: request.toJson())`
3. หน้าจอ/controller/service **ไม่ต้องแก้เลย** — นี่คือประโยชน์ของการแยกชั้น

## Tests ([test/src/features/expense/](../../../../test/src/features/expense/))

- Widget test เป็น **Robot-only**: test body เรียกได้แค่ [ExpenseRobot](../../../../test/src/features/expense/expense_robot.dart)
  (compose `Robot` กลาง) — ห้าม `tester.*`/`find.*` ตรง ๆ; helper ขาดให้เพิ่มที่ Robot
- ฉีดข้อมูลผ่าน `overrideRepos: [expenseRepositoryProvider.overrideWith((ref) => FakeExpenseRepository())]`
  — fake อยู่ที่ [data/fake/](data/fake/fake_expense_repository.dart) มี `createdRequests` ไว้ spy
  request และ `errorToThrow` ไว้ test error state
- Controller/service test ใช้ `ProviderContainer` + `addTearDown(container.dispose)`
- Domain test เป็น `test()` ธรรมดา ไม่ต้องมี Robot

## อ่านต่อ

กติกาฉบับเต็มอยู่ที่ `.claude/skills/tnds-flutter-app/references/` — architecture-layers, service-layer,
data-layer, riverpod-state, navigation, widgets-theming, localization, testing
(สั่ง scaffold stack ใหม่อัตโนมัติได้ด้วย skill `generate-api`)
