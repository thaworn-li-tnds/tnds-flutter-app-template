import 'package:tnds_flutter_app/src/features/sample_module/data/sample_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sample_screen_service.g.dart';

/// **Feature** service for the sample module's screens — the feature's own
/// business (screen content, feature actions). Plain name, no `Module`, because
/// these functions are feature work, not module-control (rule 09). Module
/// session lifecycle lives in `SampleModuleService`.
class SampleScreenService {
  SampleScreenService(this.ref);

  final Ref ref;

  SampleRepository get _repo => ref.read(sampleRepositoryProvider);

  /// Loads the first screen's content for the given [id].
  Future<String> loadData(String id) => _repo.loadData(id);

  /// Runs a feature action using the session token (mock) — example of a later
  /// screen that uses the token when firing an API instead of loading on entry.
  Future<String> doAction(String token) => _repo.doAction(token);
}

@riverpod
SampleScreenService sampleScreenService(Ref ref) => SampleScreenService(ref);
