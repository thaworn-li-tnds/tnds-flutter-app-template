import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock.g.dart';

/// Injectable time source. Application code reads [clockProvider] instead of
/// calling `DateTime.now()` directly, so "now" stays deterministic in tests —
/// override the provider with a fixed clock.
class Clock {
  const Clock();

  DateTime now() => DateTime.now();
}

@Riverpod(keepAlive: true)
Clock clock(Ref ref) => const Clock();
