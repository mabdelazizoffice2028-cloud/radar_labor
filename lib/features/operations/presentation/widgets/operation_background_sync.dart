import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';

void triggerBackgroundSync(
  WidgetRef ref, {
  ActorContext? actor,
  ScopeSnapshot? scope,
}) {
  unawaited(() async {
    try {
      final s = ref.read(currentSessionProvider);
      final effActor = actor ??
          (s != null
              ? ActorContext(userId: s.id, role: s.role, name: s.displayName)
              : null);
      final effScope = scope ??
          (s != null
              ? ScopeSnapshot(
                  teamIds: s.teamIds.toSet(),
                  housingIds: s.housingIds.toSet(),
                )
              : null);
      if (effActor != null && effScope != null) {
        await ref
            .read(syncEngineProvider)
            .synchronize(actor: effActor, scope: effScope);
      }
    } on Object catch (error) {
      debugPrint('Background sync failed (${error.runtimeType}).');
    }
  }());
}
