---
name: review-uncommitted
description: >
  Review uncommitted code changes against the tnds-flutter-app
  standard (references/). Triggers on: review uncommitted, review changes,
  check my code, review diff, review before commit, ตรวจ code, review code
allowed-tools: Bash, Read, Edit
---

# Skill: Review Uncommitted Code

ตรวจ uncommitted changes ทั้งหมดเทียบกับ standard ใน [references/](../../references/) ของแพ็กเกจนี้

---

## Step 1 — Gather Changed Files

รัน **parallel**:

```bash
git diff --name-only
git diff --staged --name-only
git status --short
```

กรองเฉพาะไฟล์ `.dart` ที่อยู่ใน `lib/` หรือ `test/` และไม่ใช่ `*.g.dart`

ถ้าไม่มีการเปลี่ยนแปลงเลย → แจ้งผู้ใช้และหยุด

---

## Step 2 — Read Changed Files

อ่านทุกไฟล์ที่เปลี่ยนแปลง (ทั้ง staged และ unstaged) รวมกับ `git diff` เพื่อดูเฉพาะบรรทัดที่เปลี่ยน:

```bash
git diff HEAD -- <file>
```

อ่านไฟล์ต้นฉบับเต็มสำหรับไฟล์ที่ต้องวิเคราะห์ context (เช่น imports, class structure)

---

## Step 3 — Review Against Rules

ตรวจแต่ละ rule ตามนี้ — **ตรวจเฉพาะบรรทัดที่เปลี่ยนแปลงหรือได้รับผลกระทบ**:

### R1 · Layer Placement ([architecture-layers.md](../../references/architecture-layers.md))

| ตรวจ | Violation เมื่อ |
|---|---|
| Controller อยู่ในโฟลเดอร์ถูกต้อง | `*_controller.dart` อยู่นอก `presentation/` |
| Service อยู่ในโฟลเดอร์ถูกต้อง | `*_service.dart` อยู่นอก `application/` |
| Screen อยู่ในโฟลเดอร์ถูกต้อง | `*_screen.dart` อยู่นอก `presentation/` |
| Application layer ไม่ import Flutter widgets | พบ `import 'package:flutter/` ใน `application/` |
| Presentation ไม่เรียก Dio โดยตรง | พบ `dio.get/post/put` ใน `*_screen.dart` หรือ widget |

### R2 · Domain Purity ([architecture-layers.md](../../references/architecture-layers.md))

ไฟล์ใน `lib/src/features/<feature>/domain/` หรือ `lib/src/shared/domain/`:

| ตรวจ | Violation เมื่อ |
|---|---|
| ไม่มี Flutter import | พบ `import 'package:flutter/` |
| ไม่มี Riverpod import | พบ `import 'package:flutter_riverpod/` หรือ `riverpod_annotation` |
| ไม่มี Dio import | พบ `import 'package:dio/` |
| ไม่ import package อื่นนอก Dart core | พบ import ที่ไม่ใช่ `dart:` หรือ domain model อื่น |

### R3 · Cross-Feature Imports ([architecture-layers.md](../../references/architecture-layers.md))

ไฟล์ใน `lib/src/features/<featureA>/`:

| ตรวจ | Violation เมื่อ |
|---|---|
| ไม่ import จาก feature อื่น | พบ import path `features/<featureB>/presentation/` หรือ `features/<featureB>/application/` |

ยกเว้น: `lib/src/shared/` และ `lib/src/common_widgets/` อนุญาต

### R4 · File Naming ([naming-conventions.md](../../references/naming-conventions.md))

| ตรวจ | Violation เมื่อ |
|---|---|
| Suffix ถูกต้อง | ชื่อไฟล์ไม่ตรง pattern ตาม layer ที่อยู่ |
| Controller ใน `presentation/` | `*_controller.dart` อยู่ใน `application/` |

### R5 · Riverpod ([riverpod-state.md](../../references/riverpod-state.md))

| ตรวจ | Violation เมื่อ |
|---|---|
| Annotation ถูกต้อง | Repository/Service ใช้ `@riverpod` แทน `@Riverpod(keepAlive: true)` |
| Per-screen controller ไม่ keepAlive | Controller ใช้ `@Riverpod(keepAlive: true)` โดยไม่มีเหตุผล |
| `ref.watch` ใช้ใน `build()` เท่านั้น | พบ `ref.watch` ใน callback เช่น `onPressed`, `onTap` |
| `ref.read` ใช้ใน callback | พบ `ref.read` ใน `build()` return value |
| Async screen ใช้ `AsyncValue.when` | พบการ access `.value!` หรือ `.requireValue` โดยไม่มี guard |

### R6 · Navigation ([navigation.md](../../references/navigation.md))

| ตรวจ | Violation เมื่อ |
|---|---|
| ไม่ใช้ raw string path | พบ `context.go('/'`, `context.push('/'`, `router.go('/'` |
| ใช้ enum-based navigation | พบ `goNamed` หรือ `pushNamed` ที่ส่ง raw string แทน `EnumName.value.name` |

### R7 · Serialization ([data-layer.md](../../references/data-layer.md))

| ตรวจ | Violation เมื่อ |
|---|---|
| ไม่ใช้ freezed | พบ `@freezed`, `import 'package:freezed_annotation/` |
| DTO มี `fromJson` และ `toJson` | class มี `@JsonSerializable` แต่ขาด factory `fromJson` หรือ method `toJson` |
| Nested DTO ใช้ `explicitToJson` | class มี field เป็น object อื่นแต่ไม่มี `explicitToJson: true` |

### R8 · Error Handling ([error-handling.md](../../references/error-handling.md))

| ตรวจ | Violation เมื่อ |
|---|---|
| ไม่มี `print()` | พบ `print(` ใน `lib/src/` |
| ใช้ `AppException` | `throw Exception(` หรือ `throw Error(` ที่ไม่ใช่ AppException subclass |

### R9 · Widget Conventions ([widgets-theming.md](../../references/widgets-theming.md))

| ตรวจ | Violation เมื่อ |
|---|---|
| ไม่มี `Widget _buildX()` method | พบ `Widget _build` ใน class body |
| ไม่ใช้ SizedBox ใน ternary | พบ `? SizedBox()` หรือ `? const SizedBox()` เป็น empty fallback |
| ใช้ `SizedBox` แทน `Container()` ว่าง | พบ `Container()` หรือ `Container(child: null)` เป็น spacer |

### R10 · Testing ([testing.md](../../references/testing.md))

สำหรับไฟล์ใน `test/`:

| ตรวจ | Violation เมื่อ |
|---|---|
| ใช้ Robot pattern | พบ `tester.pump` หรือ `tester.tap` โดยตรงใน test body แทนการใช้ `robot.` |
| Inject fakes ผ่าน `overrideRepos` | พบ `ProviderContainer` ที่สร้างเองและ override provider โดยตรง |
| CachedNetworkImage มี sqflite-ffi setup | widget ที่ใช้ `CachedNetworkImage` แต่ไม่มี `sqfliteFfiInit()` ใน `setUp` |
| ไม่มี `deleteDatabase` ใน `tearDown` | พบ `databaseFactory.deleteDatabase` ใน `tearDown` |

### R11 · Service Layer ([service-layer.md](../../references/service-layer.md))

| ตรวจ | Violation เมื่อ |
|---|---|
| Presentation ไม่แตะ repository | พบ `ref.read(*RepositoryProvider)` หรือ `import '...data/...'` ในไฟล์ใต้ `presentation/` |
| ไม่มี function provider เรียก repo | พบ `@riverpod` top-level function ใน `application/` ที่ body เรียก `*RepositoryProvider` (ต้องเป็น method บน Service class) |
| Controller เรียกผ่าน Service | mutation/load ใน controller เรียก `*ServiceProvider` ไม่ใช่ repo หรือ function provider |

> ข้อยกเว้น: ไฟล์ legacy ที่อยู่ในรายการ [MIGRATION.md](../../MIGRATION.md) แล้ว — รายงานเป็น note ไม่ใช่ violation ใหม่ แต่**ห้ามเพิ่ม pattern เดิมลงไฟล์เหล่านั้นอีก**

---

## Step 4 — Output Report

```
## Code Review: Uncommitted Changes

**Files reviewed:** {n} files ({list ชื่อไฟล์})

---

### Violations

| # | Rule | Severity | File | Issue | Fix |
|---|------|----------|------|-------|-----|
| 1 | R1 Layer | High | `path/to/file.dart:42` | Controller อยู่ใน `application/` | ย้ายไป `presentation/` |
| 2 | R8 Error | Medium | `path/to/file.dart:88` | `print(...)` ใน production code | ลบออกหรือใช้ `ErrorLogger` |

*ถ้าไม่มี violation: แสดง "✅ ไม่พบ violation" แล้วหยุด*

---

### Checklist

- [x/❌] R1 · Layer placement
- [x/❌] R2 · Domain purity
- [x/❌] R3 · Cross-feature imports
- [x/❌] R4 · File naming
- [x/❌] R5 · Riverpod annotation & ref usage
- [x/❌] R6 · Navigation (enum-based)
- [x/❌] R7 · Serialization (@JsonSerializable, no freezed)
- [x/❌] R8 · Error handling (AppException, no print)
- [x/❌] R9 · Widget conventions (no _buildX, no SizedBox ternary)
- [x/❌] R10 · Testing (Robot, overrideRepos, sqflite-ffi)
- [x/❌] R11 · Service layer (Controller → Service → Repository, no function providers)

---

**{n} violation(s) found**
```

Severity:
- **High** — layer violation, domain purity, cross-feature import (อาจทำให้ architecture พัง)
- **Medium** — naming, wrong Riverpod annotation, raw navigation, missing fromJson/toJson, print()
- **Low** — widget convention, minor inconsistency

---

## Step 5 — Fix Selection

หลังแสดง report แล้ว ให้แสดงตารางสรุปแยกต่างหาก และถามผู้ใช้ว่าจะแก้ข้อไหนบ้าง:

```
### สรุปสิ่งที่ต้องแก้

| # | ปัญหา | วิธีแก้ | ไฟล์ที่ต้องแก้ |
|---|-------|---------|----------------|
| 1 | [ชื่อปัญหาสั้น ๆ] | [วิธีแก้ 1 บรรทัด] | `file1.dart`, `file2.dart` |
| 2 | [ชื่อปัญหาสั้น ๆ] | [วิธีแก้ 1 บรรทัด] | `file3.dart` |

ต้องการให้แก้ข้อไหนบ้าง? (ระบุหมายเลข เช่น "1,2" หรือ "ทั้งหมด")
```

กฎการแสดงตาราง:
- **ปัญหา**: ชื่อสั้น ๆ ไม่เกิน 5 คำ
- **วิธีแก้**: action ที่ต้องทำ 1 บรรทัด (เช่น "เปลี่ยนชื่อ class", "ย้ายไฟล์ไป presentation/")
- **ไฟล์ที่ต้องแก้**: รวม cascade files ด้วย ถ้า violation นั้นมีผลกระทบหลายไฟล์
- ถ้า violation มี cascade (แก้ต้นทางแล้วต้องแก้ปลายทางด้วย) ให้รวมไฟล์ทั้งหมดในแถวเดียว

เมื่อผู้ใช้ระบุข้อที่ต้องการแก้ → ดำเนินการแก้ไขทันทีโดยใช้ Edit tool

---

## Notes

- ตรวจเฉพาะ changed lines + context ที่จำเป็น ไม่ตรวจทั้ง file ที่ไม่เปลี่ยน
- Rules เต็มอยู่ที่ [../../references/](../../references/) — อ่านเมื่อต้องการ detail เพิ่มเติม
- ไม่ suggest refactor นอก scope ของ changed files
- ทุก violation ต้องระบุ `:line` ใน File column
