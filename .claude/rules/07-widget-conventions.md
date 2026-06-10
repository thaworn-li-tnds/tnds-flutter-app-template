# Widget Conventions

> Full rules: [.claude/skills/tnds-flutter-app/references/widgets-theming.md](../skills/tnds-flutter-app/references/widgets-theming.md) — read before writing any widget.

Non-negotiables:

- Extract sub-widgets as widget classes (`_FooSection`), never `Widget _buildX()` methods.
- `if (cond) Widget()` over ternary-`SizedBox`; `SizedBox`/`kGap*` over empty `Container`; `Spacer` over `Expanded(child: SizedBox())`.
- No hardcoded sizes/colors/text styles: `Sizes.kP*` / `kGap*` / `kRadius*` tokens and `Theme.of(context).appColors` / `.appTexts` only. Reuse `lib/src/common_widgets/` before writing new generic widgets.
- Single quotes, trailing commas everywhere, no relative imports crossing `lib/`.
