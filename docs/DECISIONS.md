# DECISIONS — Radar Labor V1

## Locked product decisions
- 2026-10-23 — Owner requests a complete, usable offline-local app for now. No
  network call, Supabase initialization, remote font/image/icon, or online-only
  first-run requirement may block product use. Cloud sync is deferred.
- 2026-10-23 — Owner requires Arabic and English UI, with bundled local fonts
  and assets. English is the default; Arabic is selectable with RTL.
- 2026-10-23 — Keep supervisor flows deliberately simple (open → mark → save),
  and generate copyable WhatsApp summaries for housing absences and site
  presence. Copy locally; never auto-send or require connectivity.
- 2026-10-23 — Keep attendance message formatting in the operations domain and
  its user-facing labels in `core/l10n/`; screens display the result and handle
  the copy interaction. Reason: keep business formatting out of widget code.
- 2026-10-23 — Keep operations persistence behind the `OperationsStore` domain
  contract and orchestrate daily workflows in `OperationsController`; screens
  do not import the data repository. Reason: preserve inward dependency flow and
  keep save/date rules out of widgets.
- 2026-10-23 — V1 local accounts are stored in the encrypted SQLite settings
  store; passwords use salted Argon2id hashes, never plaintext. Initial manager
  and HR passwords are temporary `123456` and must be changed on first login.
- 2026-10-23 — Import roster locally through Android Storage Access Framework.
  Store code, name, designation, and supplier; ignore ID No. completely, and
  reject duplicate codes before commit. Existing housing/team assignments are
  preserved when roster rows are updated.
- 2026-10-23 — Schema v3 adds nullable employee supplier and preserves existing
  v2 rows through a forward migration. Local account data stays in the encrypted
  database, so no credentials or personal data are committed.
- 2026-10-23 — Launcher display name is `Radar Labour`; retain the existing
  Android applicationId until an owner-approved production identity is chosen.
- 2026-10-23 — Explicit owner approval of `excel` package (local-only, offline
  XLSX parser). Reason: Required for local Storage Access Framework XLSX workforce
  import; contains no runtime network, telemetry, or cloud dependency.
- Still pending: final Android applicationId and any production signing identity.

## Agent decisions
- 2026-10-23 — Drift + SQLite3MultipleCiphers, not sqflite. Reason: PRD §2/§8
  (encryption, watch() streams, migrations). Owner's chat message mentioned sqflite; PRD wins.
- 2026-10-23 — Encryption is verified in every build mode, not only release.
  Reason: simpler, stricter, and tests catch a missing hook early.
- 2026-10-23 — DB file location is injected into `openEncryptedDatabase`.
  Reason: path_provider is not in PRD §2; adding it needs owner approval (CLAUDE.md §2 case 3).
- 2026-10-23 — Defaults used until owner decides: SLA 120 min, day cutoff 03:00 (PRD §5/§6).
- 2026-10-23 — Raw hex key via `PRAGMA key = '<hex>'`. Reason: matches drift docs; hex-only keeps interpolation safe.
- 2026-10-23 — Drift schema export stored in `lib/core/database/schemas/`. Reason: keep versioned schema history beside the database implementation.
- 2026-10-23 — Open Drift on a background isolate and normalize `DriftRemoteException` at the startup boundary. Reason: Drift 2.35 wraps setup exceptions; the UI must receive typed database failures.
- 2026-10-23 — Track the Gradle wrapper scripts and JAR. Reason: fresh clones need the pinned Gradle 9.3.1 launcher to build.
- 2026-10-23 — Replace cloud-dependent S2 with local persistence and local
  workflows for the current deliverable. Reason: the owner explicitly requested
  an app that is usable without internet now; sync can be designed later without
  weakening local data safety.
- 2026-10-23 — Use repository-owned docs/WORKLOG.md, docs/BUGS.md,
  docs/ROADMAP.md, and docs/NEXT_AGENT.md as the required multi-model handoff.
  Reason: the owner explicitly needs every model to leave a reliable checkpoint.

## ADR-001: حسم التعارض وتثبيت أسبقية الوثائق (Document Precedence & Scope Resolution)

- **Date:** 2026-10-23
- **Context:** وجود تعارض بين توجيه المالك الأحدث في مسودة العمل (`drafts.txt` بتاريخ 23 أكتوبر 2026) ووثيقة المتطلبات الأصلية (`docs/PRD.md` بتاريخ 9 أكتوبر 2026) حول البنية السحابية وإدارة الحسابات ونطاق المزامنة.
- **Decision (قرار الحسم المعماري والتنفيذي):**
  1. **أسبقية مسودة 23 أكتوبر على PRD في النطاق التشغيلي:**
     - **لا Supabase ولا مزامنة سحابية ولا اتصال شبكي:** التطبيق محلي بالكامل (Offline-first / Local-only). أعمدة وجداول المزامنة (`sync_status` و`server_seq`) تظل في مخطط قاعدة البيانات لضمان استقرار الهيكل دون بناء أي منطق مزامنة أو استدعاء شبكي عليها في V1.
     - **اللغة الافتراضية:** الإنجليزية هي الافتراضية عند التثبيت لأول مرة؛ العربية مدعومة بالكامل باتجاه RTL كخيار يمكن التبديل إليه وحفظه محلياً.
     - **الحسابات والجلسات:** الحسابات محلية ومحفوظة في قاعدة البيانات المشفرة (باستخدام Argon2id + salt). الجلسة مؤقتة (Ephemeral Session) ولا تُحفظ بين مرات إغلاق وتشغيل التطبيق (البند 7 في مسودة المالك يلغي بند القبول رقم 3).
     - **الاستيراد ومعرف العامل:** استيراد محلي لملفات XLSX/CSV عبر Android Storage Access Framework مع شاشة معاينة، ويعتمد عمود `S/O` ككود للموظف بعد فحص التكرار، مع تجاهل وحظر تخزين أرقام الهويات الوطنية.
  2. **بنود PRD التي تظل ملزمة بشكل صارم ودائم:**
     - سجل الأحداث المحلي غير القابل للتعديل (Immutable Append-only Event Log).
     - قواعد محرك الحالات (StatusEngine) وحسابات SLA.
     - الحد الأقصى الصارم لحجم الملفات (300 سطر لكل ملف كود `.dart`).
     - إدارة الحالة الحصرية عبر **Riverpod** مع واجهات غبية (Dumb Presentation).
     - توكنز التصميم والألوان والمسافات المشتقة حصرياً من `docs/DESIGN.md`.
     - ملف ترجمة وسلاسل نصية موحد (`l10n`).
     - حظر الاستيراد المباشر من `package:flutter/material.dart` داخل مكونات التطبيق.
     - أهداف اللمس (Touch targets) لا تقل عن 56dp للأزرار و64dp لصفوف القوائم.
     - مصفوفة الصلاحيات في ملحق PRD §1 (الإدارة = مدير المشروع ومسؤول HR بنفس الصلاحيات الإدارية الكاملة).
  3. **تعليق بنود الشبكة والسحابة:**
     - أي بند في PRD يخص الشبكة والسحابة (شريحة S2، قواعد RLS السحابية، دوال rpc، والنسخ الاحتياطي السحابي) يُعتبر **معلقاً رسمياً** وغير قابل للتنفيذ في إصدار V1 الحالي.
