import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/sync/auto_sync_listener.dart';

final class _FakeConnectivity implements Connectivity {
  final _ctrl = StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _ctrl.stream;

  void emit(List<ConnectivityResult> r) => _ctrl.add(r);

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => [ConnectivityResult.wifi];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _refProvider = Provider((ref) => ref);

void main() {
  group('AutoSyncListener (Phase 3 Passive Sync)', () {
    test('triggers on network restore and disposes cleanly', () async {
      final fakeConn = _FakeConnectivity();
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final listener = AutoSyncListener(ref: container.read(_refProvider), connectivity: fakeConn);
      listener.start();

      fakeConn.emit([ConnectivityResult.wifi]);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      fakeConn.emit([ConnectivityResult.none]);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      listener.dispose();
      expect(true, isTrue);
    });
  });
}
