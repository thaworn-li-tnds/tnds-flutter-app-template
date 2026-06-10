# Widgets & Theming

## Trigger

Signals: any widget code, Scaffold, padding, spacing, color, TextStyle, theme, SizedBox, new screen, common widget
Before generating code in this area, output verbatim: `Reading: widgets-theming.md`

## Rules — NEVER Violate

1. **Extract sub-widgets as widget classes, never `Widget _buildXxx()` methods** (method extraction forces full-parent rebuilds). Private sections use `_PascalCase` names (`_HeaderSection`).
2. **Reuse first**: check `lib/src/common_widgets/` (70+ widgets) before writing a new generic widget. A widget used by 2+ features moves to `common_widgets/`.
3. **No magic numbers for spacing/radius**: use `Sizes.kP*`, `kGapW*`/`kGapH*`, `kRadius*`, `kShadow*` from `lib/src/constants/app_sizes.dart`.
4. **No raw colors or text styles**: colors via `Theme.of(context).appColors`, typography via `Theme.of(context).appTexts` (extensions in `lib/src/themes/app_theme.dart`). Never `Color(0xFF...)` or inline `TextStyle(...)` in feature widgets.
5. **Conditional rendering**: `if (cond) Widget()` inside children lists — never `cond ? Widget() : const SizedBox()`.
6. **Spacing widgets**: `const SizedBox(...)`/`kGap*` over empty `Container`; `Spacer()` over `Expanded(child: SizedBox())`.
7. **Interactive/asserted widgets get a `Key`** (`Key('logout_row')`) so the Robot can find them — see [testing.md](testing.md).
8. Style: single quotes, trailing commas everywhere, package imports only (no relative imports crossing `lib/`), no reaching into another package's `src/`.

## Screen structure

```dart
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(...),
      body: Column(
        children: [
          const _Header(),          // ✅ class extraction
          kGapH16,                  // ✅ token spacing
          if (showBanner) const _Banner(),  // ✅ conditional
          const Spacer(),
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) { ... }
}
```

Use `ConsumerWidget` unless the screen genuinely needs `State` lifecycle. Server-derived state never lives in `State` fields — see [riverpod-state.md](riverpod-state.md).

## Design tokens

```dart
// spacing scale (lib/src/constants/app_sizes.dart)
Padding(padding: const EdgeInsets.all(Sizes.kP16), ...)
kGapH16   // const SizedBox(height: Sizes.kP16)
kGapW8    // const SizedBox(width: Sizes.kP8)

// radius / shadows
BorderRadius.all(kRadius8)
boxShadow: kShadowSm

// colors & typography (theme extensions)
final colors = Theme.of(context).appColors;   // AppColorsExtension
final texts = Theme.of(context).appTexts;     // AppTextExtension
Text('...', style: texts.bodyMdRegular.copyWith(color: colors.gray.shade600))
```

`appColors` resolves `LightThemeExtension`/`DarkThemeExtension`; `appTexts` resolves `MymoAppTextExtension` (display/body × xs–xl × regular/medium/bold). Adding a one-off shade or TextStyle in a feature widget is a violation — extend the theme extension instead.

## Hardcoded size detection (review rule)

When reviewing/writing widgets, scan for raw numeric literals in:
`SizedBox`, `EdgeInsets`, `Padding`, `Container`, `BoxConstraints`, `BorderRadius`, `Radius.circular`, `width:`, `height:`, `minWidth:`, `minHeight:`, `maxWidth:`, `maxHeight:`

Each literal must map to a constant: `Sizes.kP*` (values) · `kGapH*` / `kGapW*` (gap SizedBoxes) · `kRadius*` (radii). A value with no matching constant (e.g. `17`) is a design question, not an excuse for a literal.

**Exempt** (literals allowed): `opacity`, `flex`, `maxLines`, `duration`, `aspectRatio`, `elevation`.

## High-traffic common widgets

| Widget | Use |
|---|---|
| `SystemAsyncValueWidget` | AsyncValue rendering with default loading/error/refresh |
| `CommonAppBar` | Standard app bar |
| `CommonButtonWidget` / `CommonDoubleButtonWidget` | Primary actions |
| `CommonErrorWidget` / `CommonEmptyWidget` | Error / empty states (AppException-aware) |
| `CommonCircularProgressWidget` | Loading spinner |
| `CommonTextFieldWidget` / `CommonInputAmount` | Inputs |
| `CommonPinCodeWidget` / `CommonPinOtp` | PIN / OTP entry |
| `CommonAccountCardWidget` | Account display card |
| `ModuleScaffold` (`shared/presentation/`) | Module entry screens only — see [module-launcher.md](module-launcher.md) |

## Anti-patterns

- ❌ `Widget _buildHeader() => ...` — extract a class.
- ❌ `isVisible ? MyWidget() : const SizedBox()` — use `if`.
- ❌ `EdgeInsets.all(17)`, `SizedBox(height: 13)` — nonstandard values need a design decision, not an inline literal.
- ❌ `Color(0xFFEB0029)`, `TextStyle(fontSize: 14)` in feature widgets.
- ❌ Duplicating an existing `common_widgets/` component with small tweaks — parameterize the shared one.

## Recap

1. Class extraction, reuse `common_widgets/`, Keys on testable elements.
2. Tokens for every size/color/style; theme extensions are the only styling source.
3. `if (cond) Widget()`, `kGap*`, `Spacer()`.
