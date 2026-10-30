import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/app/providers/app_core_providers.dart';
import 'package:radar_labor/core/sync/outbox_repository.dart';
import 'package:radar_labor/core/sync/remote_gateway.dart';
import 'package:radar_labor/core/sync/supabase_sync_gateway.dart';
import 'package:radar_labor/core/sync/sync_engine.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final outboxRepositoryProvider = Provider<OutboxRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final clock = ref.watch(clockProvider);
  return OutboxRepository(database: db, clock: clock);
});

final pendingOutboxCountProvider = StreamProvider<int>((ref) {
  final outbox = ref.watch(outboxRepositoryProvider);
  return outbox.watchPendingCount();
});

final remoteSyncGatewayProvider = Provider<RemoteSyncGateway>((ref) {
  try {
    final client = Supabase.instance.client;
    return SupabaseSyncGateway(client: client);
  } on Exception catch (error) {
    debugPrint('Supabase not available for sync: $error');
    return const OfflineRemoteSyncGateway();
  } catch (error) {
    debugPrint('Supabase uninitialized; using offline gateway (${error.runtimeType}).');
    return const OfflineRemoteSyncGateway();
  }
});

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final outbox = ref.watch(outboxRepositoryProvider);
  final gateway = ref.watch(remoteSyncGatewayProvider);
  return SyncEngine(database: db, outbox: outbox, gateway: gateway);
});
