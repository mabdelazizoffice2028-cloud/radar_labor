import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:drift/drift.dart' as drift;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/database_opener.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/dashboard/data/status_snapshot_repository.dart';
import 'package:radar_labor/features/operations/presentation/operations_screen.dart';
import 'package:radar_labor/features/operations/data/operations_repository.dart';
import 'package:uuid/uuid.dart';

class RadarLaborApp extends StatefulWidget {
  const RadarLaborApp({super.key});
  @override
  State<RadarLaborApp> createState() => _RadarLaborAppState();
}

class _RadarLaborAppState extends State<RadarLaborApp> {
  late Future<_AppSession> _startup;
  @override
  void initState() {
    super.initState();
    _startup = _open();
  }

  Future<_AppSession> _open() async {
    const secure = FlutterSecureStorage();
    var key = await secure.read(key: DatabaseConstants.keyStorageName);
    if (key == null) {
      final bytes = Uint8List.fromList(
        List.generate(32, (_) => Random.secure().nextInt(256)),
      );
      key = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      await secure.write(key: DatabaseConstants.keyStorageName, value: key);
    }
    final directory = await getApplicationSupportDirectory();
    final database = await openEncryptedDatabase(
      File(p.join(directory.path, DatabaseConstants.fileName)),
      key,
    );
    final settings = LocalSettingsRepository(database);
    await settings.seedDefaults(locale: 'ar');
    final deviceId = await settings.ensureDeviceId();
    return _AppSession(
      database,
      EventRepository(
        database: database,
        deviceId: deviceId,
        clock: const SystemClock(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff1d4ed8)),
      scaffoldBackgroundColor: const Color(0xfff3f7fe),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xff1d4ed8),
        foregroundColor: Colors.white,
      ),
    ),
    home: FutureBuilder<_AppSession>(
      future: _startup,
      builder: (context, state) {
        if (state.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const Text(
                      'تعذر بدء التطبيق / Could not start',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      state.error.toString(),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    FilledButton(
                      onPressed: () => setState(() => _startup = _open()),
                      child: const Text('Retry / إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (!state.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _Home(
          database: state.data!.database,
          events: state.data!.events,
        );
      },
    ),
  );
}

final class _AppSession {
  const _AppSession(this.database, this.events);
  final AppDatabase database;
  final EventRepository events;
}

class _Home extends StatefulWidget {
  const _Home({required this.database, required this.events});
  final AppDatabase database;
  final EventRepository events;
  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  int _tab = 0;
  String _locale = 'ar';
  bool get _ar => _locale == 'ar';
  String _t(String ar, String en) => _ar ? ar : en;
  late final _settings = LocalSettingsRepository(widget.database);
  late final _dashboard = StatusSnapshotRepository(
    database: widget.database,
    events: widget.events,
    clock: const SystemClock(),
  );
  late final _operations = OperationsRepository(
    database: widget.database,
    events: widget.events,
  );

  @override
  void initState() {
    super.initState();
    _settings.read('locale').then((value) {
      if (mounted && value != null) setState(() => _locale = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _Dashboard(repository: _dashboard, arabic: _ar),
      _Workers(database: widget.database, events: widget.events, arabic: _ar),
      _Entities(database: widget.database, arabic: _ar, teams: true),
      _Entities(database: widget.database, arabic: _ar, teams: false),
      OperationsScreen(repository: _operations, arabic: _ar),
      _Preferences(
        arabic: _ar,
        locale: _locale,
        onLocale: (value) async {
          await _settings.write('locale', value);
          setState(() => _locale = value);
        },
      ),
    ];
    final labels = [
      _t('الرئيسية', 'Home'),
      _t('العمال', 'Workers'),
      _t('الفرق', 'Teams'),
      _t('السكن', 'Housing'),
      _t('التسجيل اليومي', 'Daily check-in'),
      _t('الإعدادات', 'Settings'),
    ];
    const icons = [
      Icons.dashboard_outlined,
      Icons.people_alt_outlined,
      Icons.groups_2_outlined,
      Icons.apartment_outlined,
      Icons.fact_check_outlined,
      Icons.settings_outlined,
    ];
    return Directionality(
      textDirection: _ar ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_t('رادار ليبور', 'Radar Labor')),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Center(
                child: Text(businessDateFor(const SystemClock().nowUtc())),
              ),
            ),
          ],
        ),
        body: IndexedStack(index: _tab, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (value) => setState(() => _tab = value),
          destinations: List.generate(
            labels.length,
            (i) =>
                NavigationDestination(icon: Icon(icons[i]), label: labels[i]),
          ).take(labels.length).toList(),
        ),
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.repository, required this.arabic});
  final StatusSnapshotRepository repository;
  final bool arabic;

  String _label(WorkerStatus status) => switch (status) {
    WorkerStatus.onSite => arabic ? 'في الموقع' : 'On site',
    WorkerStatus.housingOnly => arabic ? 'في السكن فقط' : 'Housing only',
    WorkerStatus.unknown => arabic ? 'غير معلوم' : 'Unknown',
    WorkerStatus.justified => arabic ? 'مبرر' : 'Justified',
    WorkerStatus.notRecorded => arabic ? 'لم يسجل بعد' : 'Not recorded',
  };

  Color _color(WorkerStatus status, ColorScheme colors) => switch (status) {
    WorkerStatus.onSite => const Color(0xff15803d),
    WorkerStatus.housingOnly => const Color(0xffb45309),
    WorkerStatus.unknown => const Color(0xffb91c1c),
    WorkerStatus.justified => const Color(0xff0e7490),
    WorkerStatus.notRecorded => colors.outline,
  };

  IconData _icon(WorkerStatus status) => switch (status) {
    WorkerStatus.onSite => Icons.check_circle_outline,
    WorkerStatus.housingOnly => Icons.home_outlined,
    WorkerStatus.unknown => Icons.warning_amber_rounded,
    WorkerStatus.justified => Icons.verified_outlined,
    WorkerStatus.notRecorded => Icons.schedule_outlined,
  };

  @override
  Widget build(BuildContext context) => StreamBuilder<StatusSnapshot>(
    stream: repository.watch(arabic: arabic),
    builder: (context, state) {
      if (state.hasError) {
        return Center(
          child: Text(
            arabic
                ? 'تعذر تحميل لوحة الحالات'
                : 'Could not load status dashboard',
          ),
        );
      }
      if (!state.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final snapshot = state.data!;
      final active = snapshot.workers.where((row) => row.isEligible).toList();
      final unknown = active
          .where((row) => row.status == WorkerStatus.unknown)
          .toList();
      final conflictCount = active.where((row) => row.flags.isNotEmpty).length;
      const cards = [
        WorkerStatus.onSite,
        WorkerStatus.housingOnly,
        WorkerStatus.unknown,
        WorkerStatus.justified,
      ];
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    arabic ? 'متابعة العمال اليوم' : 'Today at a glance',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    arabic
                        ? 'محلي بالكامل • البيانات محفوظة على الجهاز'
                        : 'Fully local • data stays on this device',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    snapshot.businessDate,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.75,
            children: [
              for (final status in cards)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _icon(status),
                          color: _color(status, Theme.of(context).colorScheme),
                        ),
                        Text(
                          '${snapshot.count(status)}',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: _color(
                                  status,
                                  Theme.of(context).colorScheme,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          _label(status),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Card(
            child: ListTile(
              leading: Icon(
                _icon(WorkerStatus.notRecorded),
                color: _color(
                  WorkerStatus.notRecorded,
                  Theme.of(context).colorScheme,
                ),
              ),
              title: Text(_label(WorkerStatus.notRecorded)),
              trailing: Text(
                '${snapshot.count(WorkerStatus.notRecorded)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          if (conflictCount > 0)
            Card(
              color: const Color(0xfffff7ed),
              child: ListTile(
                leading: const Icon(
                  Icons.error_outline,
                  color: Color(0xffb45309),
                ),
                title: Text(
                  arabic ? 'تعارضات تحتاج مراجعة' : 'Conflicts to review',
                ),
                trailing: Text('$conflictCount'),
              ),
            ),
          if (unknown.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 16, bottom: 4),
              child: Text(
                arabic ? 'عمال غير معلومين' : 'Unknown workers',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            for (final result in unknown)
              Card(
                child: ListTile(
                  leading: Icon(
                    result.isSlaBreached
                        ? Icons.timer_off_outlined
                        : Icons.help_outline,
                    color: result.isSlaBreached
                        ? const Color(0xffb91c1c)
                        : const Color(0xffb45309),
                  ),
                  title: Text(
                    '${result.worker.fullName} • ${result.worker.code}',
                  ),
                  subtitle: Text(
                    result.isSlaBreached
                        ? (arabic ? 'تجاوز مهلة المتابعة' : 'SLA exceeded')
                        : (arabic
                              ? 'غياب سكن دون تبرير'
                              : 'Housing absence without justification'),
                  ),
                  trailing: result.flags.isEmpty
                      ? null
                      : const Icon(Icons.warning_amber_rounded),
                ),
              ),
          ],
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline, color: Color(0xff15803d)),
              title: Text(
                arabic
                    ? 'بيانات مشفرة ومحفوظة على الجهاز'
                    : 'Encrypted data stored on this device',
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _Workers extends StatefulWidget {
  const _Workers({
    required this.database,
    required this.events,
    required this.arabic,
  });
  final AppDatabase database;
  final EventRepository events;
  final bool arabic;
  @override
  State<_Workers> createState() => _WorkersState();
}

class _WorkersState extends State<_Workers> {
  String _query = '';
  Future<void> _add() async {
    final teams = await (widget.database.select(
      widget.database.teams,
    )..where((row) => row.isActive)).get();
    final housings = await (widget.database.select(
      widget.database.housings,
    )..where((row) => row.isActive)).get();
    if (!mounted) return;
    final code = TextEditingController(),
        arabicName = TextEditingController(),
        englishName = TextEditingController();
    String? selectedTeam;
    String? selectedHousing;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, updateDialog) => AlertDialog(
          title: Text(widget.arabic ? 'إضافة عامل' : 'Add worker'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: code,
                decoration: InputDecoration(
                  labelText: widget.arabic ? 'رقم العامل' : 'Worker code',
                ),
              ),
              TextField(
                controller: arabicName,
                decoration: InputDecoration(
                  labelText: widget.arabic ? 'الاسم بالعربية' : 'Arabic name',
                ),
              ),
              TextField(
                controller: englishName,
                decoration: InputDecoration(
                  labelText: widget.arabic
                      ? 'الاسم بالإنجليزية'
                      : 'English name',
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String?>(
                initialValue: selectedTeam,
                decoration: InputDecoration(
                  labelText: widget.arabic ? 'الفريق الحالي' : 'Current team',
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(widget.arabic ? 'بدون فريق' : 'No team'),
                  ),
                  ...teams.map(
                    (team) => DropdownMenuItem<String?>(
                      value: team.teamId,
                      child: Text(
                        widget.arabic
                            ? team.nameAr
                            : team.nameEn ?? team.nameAr,
                      ),
                    ),
                  ),
                ],
                onChanged: (value) => updateDialog(() => selectedTeam = value),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String?>(
                initialValue: selectedHousing,
                decoration: InputDecoration(
                  labelText: widget.arabic ? 'السكن الحالي' : 'Current housing',
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(widget.arabic ? 'بدون سكن' : 'No housing'),
                  ),
                  ...housings.map(
                    (housing) => DropdownMenuItem<String?>(
                      value: housing.housingId,
                      child: Text(
                        widget.arabic
                            ? housing.nameAr
                            : housing.nameEn ?? housing.nameAr,
                      ),
                    ),
                  ),
                ],
                onChanged: (value) =>
                    updateDialog(() => selectedHousing = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(widget.arabic ? 'إلغاء' : 'Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(widget.arabic ? 'حفظ' : 'Save'),
            ),
          ],
        ),
      ),
    );
    if (saved != true ||
        code.text.trim().isEmpty ||
        arabicName.text.trim().isEmpty) {
      return;
    }
    try {
      await widget.database
          .into(widget.database.employees)
          .insert(
            EmployeesCompanion.insert(
              employeeUid: const Uuid().v4(),
              employeeCode: code.text.trim(),
              fullNameAr: arabicName.text.trim(),
              fullNameEn: drift.Value(
                englishName.text.trim().isEmpty
                    ? null
                    : englishName.text.trim(),
              ),
              category: 'general',
              currentTeamId: drift.Value(selectedTeam),
              housingId: drift.Value(selectedHousing),
            ),
          );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.arabic
                  ? 'رقم العامل مستخدم بالفعل'
                  : 'Worker code already exists',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _add,
      icon: const Icon(Icons.person_add_alt_1),
      label: Text(widget.arabic ? 'إضافة عامل' : 'Add worker'),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: widget.arabic
                  ? 'بحث بالاسم أو الرقم'
                  : 'Search name or code',
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Employee>>(
            stream: widget.database.select(widget.database.employees).watch(),
            builder: (context, state) {
              final workers = (state.data ?? [])
                  .where(
                    (worker) =>
                        worker.fullNameAr.contains(_query) ||
                        worker.employeeCode.toLowerCase().contains(
                          _query.toLowerCase(),
                        ) ||
                        (worker.fullNameEn ?? '').toLowerCase().contains(
                          _query.toLowerCase(),
                        ),
                  )
                  .toList();
              if (workers.isEmpty) {
                return Center(
                  child: Text(
                    widget.arabic
                        ? 'لا يوجد عمال بعد — اضغط إضافة'
                        : 'No workers yet — tap Add',
                  ),
                );
              }
              return ListView(
                children: workers
                    .map(
                      (worker) => Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(
                            widget.arabic
                                ? worker.fullNameAr
                                : worker.fullNameEn ?? worker.fullNameAr,
                          ),
                          subtitle: Text(
                            '${widget.arabic ? 'رقم' : 'Code'} ${worker.employeeCode}',
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) => _record(worker, value),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'site',
                                child: Text(
                                  widget.arabic
                                      ? 'تسجيل بالموقع'
                                      : 'Mark on site',
                                ),
                              ),
                              PopupMenuItem(
                                value: 'absent',
                                child: Text(
                                  widget.arabic ? 'تسجيل غياب' : 'Mark absent',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
      ],
    ),
  );

  Future<void> _record(Employee worker, String action) async {
    if ((action == 'site' && worker.currentTeamId == null) ||
        (action == 'absent' && worker.housingId == null)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.arabic
                  ? 'عيّن العامل إلى فريق وسكن أولًا'
                  : 'Assign the worker to a team and housing first',
            ),
          ),
        );
      }
      return;
    }
    await widget.events.append(
      EventDraft(
        type: action == 'site'
            ? EventType.sitePresent
            : EventType.housingAbsent,
        action: EventAction.set,
        businessDate: businessDateFor(const SystemClock().nowUtc()),
        employeeUid: worker.employeeUid,
        teamId: action == 'site' ? worker.currentTeamId : null,
        housingId: action == 'absent' ? worker.housingId : null,
      ),
    );
  }
}

class _Entities extends StatefulWidget {
  const _Entities({
    required this.database,
    required this.arabic,
    required this.teams,
  });
  final AppDatabase database;
  final bool arabic, teams;
  @override
  State<_Entities> createState() => _EntitiesState();
}

class _EntitiesState extends State<_Entities> {
  Future<void> _add() async {
    final ar = TextEditingController(), en = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          widget.arabic
              ? (widget.teams ? 'إضافة فريق' : 'إضافة سكن')
              : (widget.teams ? 'Add team' : 'Add housing'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ar,
              decoration: InputDecoration(
                labelText: widget.arabic ? 'الاسم بالعربية' : 'Arabic name',
              ),
            ),
            TextField(
              controller: en,
              decoration: InputDecoration(
                labelText: widget.arabic ? 'الاسم بالإنجليزية' : 'English name',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(widget.arabic ? 'إلغاء' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(widget.arabic ? 'حفظ' : 'Save'),
          ),
        ],
      ),
    );
    if (saved != true || ar.text.trim().isEmpty) return;
    final id = const Uuid().v4();
    if (widget.teams) {
      await widget.database
          .into(widget.database.teams)
          .insert(
            TeamsCompanion.insert(
              teamId: id,
              nameAr: ar.text.trim(),
              nameEn: drift.Value(
                en.text.trim().isEmpty ? null : en.text.trim(),
              ),
            ),
          );
    } else {
      await widget.database
          .into(widget.database.housings)
          .insert(
            HousingsCompanion.insert(
              housingId: id,
              nameAr: ar.text.trim(),
              nameEn: drift.Value(
                en.text.trim().isEmpty ? null : en.text.trim(),
              ),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stream = widget.teams
        ? widget.database
              .select(widget.database.teams)
              .watch()
              .map(
                (rows) => rows
                    .map(
                      (row) =>
                          widget.arabic ? row.nameAr : row.nameEn ?? row.nameAr,
                    )
                    .toList(),
              )
        : widget.database
              .select(widget.database.housings)
              .watch()
              .map(
                (rows) => rows
                    .map(
                      (row) =>
                          widget.arabic ? row.nameAr : row.nameEn ?? row.nameAr,
                    )
                    .toList(),
              );
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: Text(widget.arabic ? 'إضافة' : 'Add'),
      ),
      body: StreamBuilder<List<String>>(
        stream: stream,
        builder: (context, state) {
          final rows = state.data ?? [];
          if (rows.isEmpty) {
            return Center(
              child: Text(
                widget.arabic
                    ? 'لا توجد بيانات بعد — اضغط إضافة'
                    : 'Nothing here yet — tap Add',
              ),
            );
          }
          return ListView(
            children: rows
                .map(
                  (name) => Card(
                    child: ListTile(
                      leading: Icon(
                        widget.teams ? Icons.groups_2 : Icons.apartment,
                      ),
                      title: Text(name),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class _Preferences extends StatelessWidget {
  const _Preferences({
    required this.arabic,
    required this.locale,
    required this.onLocale,
  });
  final bool arabic;
  final String locale;
  final ValueChanged<String> onLocale;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text(
        arabic ? 'الإعدادات' : 'Settings',
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      Card(
        child: ListTile(
          leading: const Icon(Icons.translate),
          title: Text(arabic ? 'اللغة' : 'Language'),
          trailing: DropdownButton<String>(
            value: locale,
            items: const [
              DropdownMenuItem(value: 'ar', child: Text('العربية')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (value) {
              if (value != null) onLocale(value);
            },
          ),
        ),
      ),
      Card(
        child: ListTile(
          leading: const Icon(Icons.lock_outline),
          title: Text(
            arabic ? 'قاعدة بيانات مشفرة محليًا' : 'Encrypted local database',
          ),
        ),
      ),
      Card(
        child: ListTile(
          leading: const Icon(Icons.wifi_off),
          title: Text(arabic ? 'يعمل دون إنترنت' : 'Works offline'),
        ),
      ),
    ],
  );
}
