# Run from C:\my_apps\radar_labor while ONLINE, after copying this package's lib/, test/, docs/ over the project.
$ErrorActionPreference = 'Stop'
flutter --version   # must report 3.47.x (PRD §2)

flutter pub add material_ui flutter_riverpod drift sqlite3 supabase_flutter flutter_secure_storage uuid local_auth go_router cryptography intl
flutter pub add "connectivity_plus:>=7.0.0 <8.0.0"
flutter pub add flutter_localizations --sdk=flutter
flutter pub add dev:drift_dev dev:build_runner dev:mocktail

# Enable SQLite3MultipleCiphers (PRD §2)
if (-not (Select-String -Path pubspec.yaml -Pattern 'sqlite3mc' -Quiet)) {
  Add-Content pubspec.yaml "`nhooks:`n  user_defines:`n    sqlite3:`n      source: sqlite3mc"
}

# allowBackup=false
$manifest = 'android\app\src\main\AndroidManifest.xml'
$text = Get-Content $manifest -Raw
if ($text -notmatch 'allowBackup') {
  $text -replace '<application', '<application android:allowBackup="false"' | Set-Content $manifest
}

# flutter create's counter test imports material.dart and the old MyApp
Remove-Item test\widget_test.dart -ErrorAction SilentlyContinue

dart run build_runner build --delete-conflicting-outputs
dart format .
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
