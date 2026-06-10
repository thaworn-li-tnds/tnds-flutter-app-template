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

| ไฟล์ | สอนเรื่อง |
|---|---|
| [domain/money.dart](domain/money.dart) | **Value object** — เท่ากันด้วยค่า (`==`/`hashCode`), พก behavior ของตัวเอง (`operator +`, `defaultCurrency`) แทนการส่ง `double` ดิบไปทั่วแอป; การ format แสดงผล (ใช้ `NumberFormat` จาก intl) ไม่อยู่ใน domain |
| [domain/expense_category.dart](domain/expense_category.dart) | **Enum with behavior** — `wireValue`/`labelKey` อยู่บน enum, parse แบบ tolerant (`from()` ไม่รู้จัก → `other`); **ไม่มี IconData** เพราะ Flutter type ห้ามเข้า domain |
| [domain/expense.dart](domain/expense.dart) | **Entity + composition** — มีตัวตนด้วย `id`, ประกอบจาก `Money` + `ExpenseCategory` |
| [domain/expense_summary.dart](domain/expense_summary.dart) | **Aggregate** — เก็บผลลัพธ์อย่างเดียว การคำนวณอยู่ที่ `ExpenseService.summarize` |
| [presentation/widgets/expense_category_icon.dart](presentation/widgets/expense_category_icon.dart) | คู่ตรงข้ามของ enum: behavior ที่เป็น Flutter type (`IconData`) อยู่ฝั่ง presentation |
| [presentation/widgets/money_format.dart](presentation/widgets/money_format.dart) | คู่ตรงข้ามของ `Money`: `formatted` ใช้ `NumberFormat` (intl) ซึ่งเป็น dependency ฝั่งแสดงผล จึงเป็น extension ใน presentation |

กติกา domain: ชื่อเป็น **คำนาม**, `const` constructor, field non-nullable มี default, ห้าม import
flutter/riverpod/dio

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

## Riverpod patterns ที่เห็นในฟีเจอร์นี้

| Pattern | ไฟล์ | ใช้เมื่อ |
|---|---|---|
| Read controller (โหลดใน `build()`) | `expense_list_controller.dart` | หน้าจอโหลดข้อมูลทันทีที่เข้า |
| Read + family param | `expense_detail_controller.dart` | state แยกชุดต่อ 1 ค่า param (`expenseId`) |
| Submit controller (idle `null` + guard) | `create_expense_controller.dart` | ฟอร์ม/ปุ่มที่ user สั่ง action |
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
