import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';

final autoSyncListenerProvider = Provider<AutoSyncListener>((ref) {
  final listener = AutoSyncListener(ref: ref);
  ref.onDispose(listener.dispose);
  listener.start();
  return listener;
});

final class AutoSyncListener {
  AutoSyncListener({required this.ref, Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Ref ref;
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _isSyncing = false;

  void start() {
    unawaited(_triggerSilentSync());
    _sub = _connectivity.onConnectivityChanged.listen(_onConnectivity);
  }

  void dispose() {
    _sub?.cancel();
  }

  void _onConnectivity(List<ConnectivityResult> results) {
    final hasNet = results.any((r) => r != ConnectivityResult.none);
    if (hasNet) unawaited(_triggerSilentSync());
  }

  Future<void> _triggerSilentSync() async {
    if (_isSyncing) return;
    final account = ref.read(currentSessionProvider);
    if (account == null) return;

    final actor = ActorContext(userId: account.id, role: account.role);
    final scope = ScopeSnapshot(
      teamIds: account.teamIds.toSet(),
      housingIds: account.housingIds.toSet(),
    );

    _isSyncing = true;
    try {
      final engine = ref.read(syncEngineProvider);
      await engine.synchronize(actor: actor, scope: scope);
    } on Object catch (error) {
      debugPrint('AutoSync silent fallback (${error.runtimeType}).');
    } finally {
      _isSyncing = false;
    }
  }
}
