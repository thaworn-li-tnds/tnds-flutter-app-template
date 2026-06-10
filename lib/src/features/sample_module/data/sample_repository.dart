import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sample_repository.g.dart';

/// Sample module data access.
///
/// MOCK: returns canned data and stays free of any sibling-feature import so
/// the module is portable. A real module would extend the project's base
/// repository and call its own backend here.
class SampleRepository {
  const SampleRepository();

  Future<String> startSample(String title) async {
    // TODO(team): real startSample API — exchange the launch params for the
    // module/session token. Mirrors startFR/startOTP.
    return 'sample-token';
  }

  Future<String> loadData(String id) async {
    // TODO(team): replace with a real backend call for the actual feature.
    return 'Loaded data for id="$id" (mock)';
  }

  Future<String> doAction(String token) async {
    // TODO(team): แทนด้วย backend call จริง โดยส่ง token ไปกับ request.
    return 'action ok ด้วย token="$token" (mock)';
  }

  Future<String> finish() async {
    // TODO(team): real finish call returning whatever the feature produces.
    return 'sample-result-value';
  }
}

@Riverpod(keepAlive: true)
SampleRepository sampleRepository(Ref ref) => const SampleRepository();
