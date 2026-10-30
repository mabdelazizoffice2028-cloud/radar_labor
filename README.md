🌐 [English](README.md) • 🇸🇦 [العربية](README.ar.md)

<div align="center">

# ⚡ Radar Labour

**Mission-Critical, Offline-First Field Operations & Workforce Attendance Management System**

[![Flutter](https://img.shields.io/badge/Flutter-%5E3.47.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%5E3.13.5-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2F%20Event--Ledger-orange?style=for-the-badge)](https://github.com)
[![Platform](https://img.shields.io/badge/Target-Android%20arm64--v8a-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://android.com)
[![Status](https://img.shields.io/badge/Build-Release%20Ready-brightgreen?style=for-the-badge)](outputs/)
[![License](https://img.shields.io/badge/License-Proprietary-red?style=for-the-badge)](LICENSE)

</div>

---

## 📋 Overview

**Radar Labour** is an enterprise-grade mobile application designed specifically for distributed workforce tracking, campus housing inspections, and dynamic site attendance across large-scale civil, industrial, and contracting operations. 

In harsh remote environments, cellular coverage is notoriously unstable or unavailable. Traditional cloud-dependent HR timeclocks or biometric systems often falter in the field, leading to operational blind spots, unaccounted personnel, compliance exposure, and untracked subcontracted labor costs.

Radar Labour resolves these field challenges through a **local-first, offline-resilient architecture**:
* **Autonomous Field Execution:** All records, validations, and roster inquiries run completely offline against an on-device encrypted SQLite database.
* **Append-Only Event Ledger:** Daily worker movements, attendance checkpoints, and housing verifications are stored as immutable event streams with cryptographic idempotency—preventing data tampering and phantom sync states.
* **Immediate Executive Transparency:** Automated conflict resolution, SLA breach warnings, and instant bilingual WhatsApp reports keep project managers, HR, and site supervisors aligned in real time without human data entry errors.

---

## 🚀 What's New (Latest Release Highlights)

* **🌙 Friday Overtime Exception & Zero-Absence Rule:** Guarantees zero absences on Fridays across the entire app; present workers are recorded as overtime with high-contrast amber banner, dedicated dashboard cards, and customized WhatsApp reports.
* **🧪 213 Automated Tests & Stress Benchmarks:** 100% test pass rate across 213 unit, integration, and stress tests, proving draft resilience against crashes, atomic rollback, and rapid processing (1,500 profiles in 40ms).
* **👥 "Default Crew" One-Tap Button:** Site supervisors can auto-select all regular crew members with a single tap, only unchecking absent workers for lightning-fast site attendance.
* **⚡ Auto-Attendance for Non-Labor Staff:** Engineers, safety officers, HR, PMs, and foremen are automatically treated as "Present on Site" every regular day, with quick absence toggling by Admin/HR.
* **🏖️ Flexible Leave Management (Retroactive & Future):** Assign past or future vacation leaves to any worker; workers on leave are immediately excluded from site check-ins, campus checks, and dashboard absences (Absent = 0).
* **📋 Comprehensive Worker History & Actions Sheet:** Tapping any worker displays 3 clean KPI metrics (Days Worked including justified, Unexcused Absences, Teams History breakdown), active leave management, and today's absence toggle.
* **🛡️ Role Renaming (HR -> Admin):** Standardized user-facing role label to "Admin" / "الإداري" across all app views.
* **🔔 Centralized Notification Center:** Replaced cluttered dashboard warning cards with an intelligent AppBar notification badge and slide-up sheet (`NotificationsSheet`) tracking pending outbox synchronization and unrecorded teams/camps in real time.
* **🪪 Proactive Iqama Expiry Management:** Built-in residency compliance monitoring alerting managers to worker documents expiring within 30 days or already expired, with detailed breakdown drawers.
* **📊 Automated Daily WhatsApp Report Compiler:** Generates formatted executive daily operational reports categorized by direct labor and rental suppliers, automatically enforcing Riyadh-time lockout rules.
* **🔄 Atomic Dual-Correction Engine (Auto-Fix):** Dynamically rectifies cross-facility discrepancies; logging a worker as "Present on Site" automatically and atomically clears any conflicting "Housing Absent" status recorded earlier that morning.
* **🔍 Instant Suffix Search:** Real-time roster filtering matching the last 4+ digits of a national residency (Iqama) number, boosting field verification speed tenfold.
* **🛡️ Zero-Tolerance Bulk Import:** Strict XLSX/CSV workforce ingestion with mandatory 10-digit validation, duplicate deduplication, and atomic transaction rollback upon single-record failure.
* **🧹 Administrative Dev Tools:** Secure, high-governance test ledger wiping tool allowing supervisors to safely reset trial entries and counters without affecting baseline rosters.
* **🌐 Seamless Multi-Language Switcher:** Instant English/Arabic (RTL) toggling available directly from the authentication gate with responsive keyboard auto-padding.

---

## ⚡ Core Features & Modules

### 👷 1. Workforce Roster & Compliance
* **Immutable Worker Profiles:** Comprehensive demographic tracking including bilingual names (Arabic/English), unique system identifiers, 10-digit Iqama numbers, trade designations, and supplier associations.
* **Residency (Iqama) Audit:** Automatic countdown tracking of document validity with amber alerts (expiring within 30 days) and red alerts (expired documents).
* **Strict Bulk Import Utility:** Support for `.xlsx` and `.csv` files up to 25MB with pre-import validation, format sanitization, and automatic transaction rollback.

### 📍 2. Dynamic Site Attendance
* **Crew & Team Deployment:** Seamless assignment of workers to specialized site crews and supervisors.
* **Multi-Trade Categorization:** Granular segregation between direct labor and specialized machinery operators.
* **Rapid Check-In & Guest Assignment:** One-tap attendance check-in with support for ad-hoc guest workers on-site.
* **Zero-Presence Safe Submission:** Enables supervisors to formally submit a validated "Zero Attendance" record when work is suspended without breaking reporting SLAs.

### 🏠 3. Campus Housing & Accommodation Review
* **Single-Tap Inspection:** Streamlined campus accommodation checks with a 3-state evaluation workflow (`Unreviewed`, `Reviewed Present`, `Absent`).
* **"No Absences Today" Quick Action:** Complete camp-wide verification in a single tap when all residents are present.
* **Categorized Absentee Reporting:** Distinct accounting for direct company staff versus third-party subcontracted labor.

### ⚡ 4. Enterprise Event Ledger & Offline Sync
* **Append-Only Ledger (`events`):** Every operational movement generates an immutable, monotonic event record with compensation inverses for undo operations (5-second undo grace window).
* **Deterministic Dual Correction:** Automatically cancels erroneous housing absences when a worker is confirmed present on-site.
* **Passive Background Sync:** Connectivity-aware outbox processor powered by `connectivity_plus` that uploads batches silently without blocking the field user.

### 🔒 5. Role-Based Security & Governance
* **Multi-Role Scoping (RBAC):** Strict operational boundaries for Project Manager, HR, Campus Supervisor, Site Supervisor, and Read-Only Viewer.
* **Cryptographic Local Security:** AES-256 database encryption with runtime key isolation via Android KeyStore / Secure Storage.
* **Password Policy:** Argon2id PIN hashing with mandatory first-login password rotation and brute-force attempt lockout.
* **Riyadh Business Hours Lockout:** Automated operational lockouts preventing retroactive editing after cutoff hours (20:00 for Housing, 23:00 for Site Attendance).

### 💬 6. Local WhatsApp Dispatch Engine
* **Branded Dispatch Layouts:** Locally formatted operational briefs ready for one-tap copy and WhatsApp transmission to management groups.
* **Zero Overhead:** No backend messaging gateways or recurring API charges; summary generation is entirely on-device.

---

## 🛠️ Tech Stack & Architecture

| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **Framework** | **Flutter 3.47.x / Dart 3.13.5** | High-performance cross-platform mobile engine |
| **State Management** | **Flutter Riverpod 3.4.3** | Declarative, reactive, compile-safe dependency injection & state |
| **Local Database & ORM** | **Drift 2.35.2 + SQLite3 3.7.1** | Strongly-typed, transactional SQLite abstraction with reactive streams |
| **Data Encryption** | **Cryptography 2.9.0 + Flutter Secure Storage 11.2.0** | Hardware-backed KeyStore key management and AES encryption |
| **Navigation & Routing** | **GoRouter 18.1.1** | Declarative route orchestration with role-based auth guards |
| **Cloud Gateway** | **Supabase Flutter 2.18.3** | Optional upstream cloud backup and multi-tenant synchronization |
| **Connectivity** | **Connectivity Plus 7.3.2** | Real-time network transition detection for auto-sync |
| **Document Processing** | **Excel 4.0.6** | High-throughput spreadsheet parsing for bulk workforce import |
| **Localization & UI** | **Material UI 1.8.0 + Intl 0.20.3** | Full Arabic RTL & English LTR layout support with bundled Cairo font |

---

## 🏛️ Project Structure

The project strictly follows **Clean Architecture & Feature-First Micro-Modularization** principles, enforcing a strict 80-line guideline per unit:

```text
lib/
├── app/                              # Application bootstrap, routing & global UI
│   ├── accounts/                     # User credential management & administrative wizards
│   ├── screens/                      # Primary scaffolds & top-level feature routing
│   └── widgets/                      # Shared global UI (NotificationBadge, BottomSheets, Login)
│
├── core/                             # Foundational cross-cutting infrastructure
│   ├── audit/                        # System audit logging & hardware device resolution
│   ├── auth/                         # Authentication repositories, RBAC & scope snapshots
│   ├── constants/                    # Application tokens, SLAs & timeout configurations
│   ├── database/                     # Drift database schema, migrations & encryption openers
│   │   ├── models/                   # Database data transfer objects
│   │   └── tables/                   # Schema definitions (Employees, Events, Teams, Scopes)
│   ├── l10n/                         # Bilingual localization strings (Arabic/English)
│   ├── status/                       # State evaluation & SLA breach calculation engine
│   ├── sync/                         # Background sync engine, outbox & Supabase adapters
│   └── ui/                           # Unified design tokens, AppSnackBar, & tactile haptics
│
└── features/                         # Independent functional domains
    ├── dashboard/                    # Real-time KPIs, Iqama compliance & daily reports
    │   ├── data/                     # Coverage repositories & daily report compiler
    │   ├── domain/                   # Metrics models & dashboard aggregations
    │   └── presentation/             # KPI cards, conflict resolution & action sheets
    │
    ├── operations/                   # Site attendance & camp inspection modules
    │   ├── data/                     # Site attendance, housing checkpoints & team repositories
    │   ├── domain/                   # Business rules, WhatsApp formatters & scope guards
    │   └── presentation/             # Field check screens, notifier states & wizard dialogs
    │
    └── roster/                       # Workforce directory & bulk onboarding
        ├── data/                     # Workforce import repository & file readers
        └── domain/                   # Ingestion validators & parsing models
```

---

## 📦 Production Release & Installation

The production-ready, lightweight Android package has been compiled specifically for modern 64-bit hardware architecture.

### Pre-Compiled APK Details
* **Direct Path:** `outputs/Radar Labour.apk`
* **Target Architecture:** `android-arm64` (ARM64-v8a)
* **Exact Size:** **24,948,248 bytes** (~23.79 MB)
* **Cryptographic SHA-256 Checksum:**
  ```text
  670C30206ADA9A4325D296998C00E371746C2E24D8B0598F6BB217F089E85DE1
  ```

### Device Installation via ADB
```bash
adb install -r "outputs/Radar Labour.apk"
```

---

## 💻 Developer Setup & Local Execution

### Prerequisites
* **Flutter SDK:** 3.47.x or compatible stable channel
* **Dart SDK:** 3.13.5+
* **Java Development Kit:** JDK 17
* **Android SDK:** Platform API 34+

### Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-org/radar_labor.git
   cd radar_labor
   ```

2. **Fetch dependencies (Offline cache preferred in production environments):**
   ```bash
   flutter pub get --offline
   ```

3. **Verify static analysis:**
   ```bash
   flutter analyze --no-pub
   ```
   *Expected outcome: `No issues found!`*

4. **Execute complete test suite (185+ unit, widget, and architecture tests):**
   ```bash
   flutter test --no-pub
   ```
   *Expected outcome: `All tests passed!`*

5. **Run in debug mode on connected device:**
   ```bash
   flutter run --no-pub
   ```

6. **Assemble modern release APK:**
   ```bash
   flutter build apk --target-platform android-arm64 --release --no-pub
   ```

---

## 📄 License & Confidentiality

Copyright © 2026 Radar Labour. All rights reserved.  
The source code, architecture, and associated assets are proprietary and confidential. The **Cairo Font Family** included in this repository is licensed under the [SIL Open Font License (OFL)](http://scripts.sil.org/OFL).
