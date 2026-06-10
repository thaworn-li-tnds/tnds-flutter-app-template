/// Input the sample module needs to start. A plain value object — no auth, no
/// platform types — so the module stays portable.
class SampleLaunchParams {
  const SampleLaunchParams({
    this.title = '',
    this.id = '',
    this.forceFail = false,
  });

  final String title;

  /// Identifier the first screen uses to load its content.
  final String id;

  /// DEV-ONLY: when true, the module's `openSession` throws so the failure path
  /// (auto-report `failed` + escapable `ModuleErrorView`) can be tested from the
  /// launchable demo. Remove together with the dev demo buttons before merge.
  final bool forceFail;
}
