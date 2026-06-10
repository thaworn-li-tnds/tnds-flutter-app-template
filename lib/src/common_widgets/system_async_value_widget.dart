// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_circular_progress_widget.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_error_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A reusable widget to provide default loading and error widgets when working
/// with AsyncValue.
/// More info here:
/// https://codewithandrea.com/articles/async-value-widget-riverpod/
class SystemAsyncValueWidget<T> extends ConsumerWidget {
  const SystemAsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.onRefresh,
    this.skipLoadingOnReload = false,
    this.skipLoadingOnRefresh = true,
    this.skipError = false,
  });
  final AsyncValue<T> value;
  final Widget Function(T) data;
  final Widget? loading;
  final Widget Function(Object e, StackTrace st)? error;
  final Future<void> Function()? onRefresh;
  final bool skipLoadingOnReload;
  final bool skipLoadingOnRefresh;
  final bool skipError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = value.when(
      skipLoadingOnReload: skipLoadingOnReload,
      skipLoadingOnRefresh: skipLoadingOnRefresh,
      skipError: skipError,
      data: (dataValue) {
        return data(dataValue);
      },
      error: (e, st) {
        if (error != null) {
          return error!(e, st);
        }
        return CustomScrollView(
          physics: onRefresh != null
              ? const AlwaysScrollableScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              child: CommonErrorWidget(exception: e, stackTrace: st),
            ),
          ],
        );
      },
      loading: () {
        return loading ?? CommonCircularProgressWidget();
      },
    );

    if (onRefresh != null) {
      return RefreshIndicator(onRefresh: onRefresh!, child: content);
    }
    return content;
  }
}
