# Cleanup Phase 2 - Clean up subproject documentation
# Run: powershell -ExecutionPolicy Bypass -File cleanup_docs_phase2.ps1

$rootPath = "D:\Django Project\Asuransi Project"
$archivePath = "$rootPath\_archive"
$smilePath = "$rootPath\Smile Project"
$flutterPath = "$rootPath\phone_insurance_app"
$dashboardPath = "$rootPath\admin-dashboard"

Write-Host "Starting Phase 2 cleanup..." -ForegroundColor Green

# ============================================================================
# MOVE EMAIL_SETUP_GUIDE to root (IMPORTANT - KEEP)
# ============================================================================

Write-Host "`nMoving EMAIL_SETUP_GUIDE to root..." -ForegroundColor Yellow

$emailGuide = Join-Path $smilePath "EMAIL_SETUP_GUIDE.md"
if (Test-Path $emailGuide) {
    Copy-Item -Path $emailGuide -Destination $rootPath -Force
    Write-Host "  Copied EMAIL_SETUP_GUIDE.md to root" -ForegroundColor Green
}

# ============================================================================
# ARCHIVE SMILE PROJECT DOCS
# ============================================================================

Write-Host "`nArchiving Smile Project documentation..." -ForegroundColor Yellow

$smileDocsToArchive = @(
    "ADMIN_API_DOCS.md",
    "API_TESTING.md",
    "EMAIL_SETUP_GUIDE.md",
    "PERFORMANCE_TEST_RESULTS.md",
    "PROJECT_STATUS.md",
    "QUICK_START.md",
    "SECURITY_IMPLEMENTATION.md",
    "SECURITY_STATUS.md",
    "TESTING_GUIDE.md",
    "UNBLOCK_GUIDE.md"
)

foreach ($doc in $smileDocsToArchive) {
    $source = Join-Path $smilePath $doc
    if (Test-Path $source) {
        Move-Item -Path $source -Destination $archivePath -Force
        Write-Host "  Archived: $doc" -ForegroundColor Gray
    }
}

# ============================================================================
# DELETE DEFAULT READMEs
# ============================================================================

Write-Host "`nDeleting default template READMEs..." -ForegroundColor Yellow

# Flutter README
$flutterReadme = Join-Path $flutterPath "README.md"
if (Test-Path $flutterReadme) {
    Remove-Item $flutterReadme -Force
    Write-Host "  Deleted: phone_insurance_app/README.md" -ForegroundColor Gray
}

# Admin Dashboard README
$dashboardReadme = Join-Path $dashboardPath "README.md"
if (Test-Path $dashboardReadme) {
    Remove-Item $dashboardReadme -Force
    Write-Host "  Deleted: admin-dashboard/README.md" -ForegroundColor Gray
}

# Admin Dashboard Performance doc
$dashboardPerf = Join-Path $dashboardPath "PERFORMANCE_OPTIMIZATION.md"
if (Test-Path $dashboardPerf) {
    Move-Item -Path $dashboardPerf -Destination $archivePath -Force
    Write-Host "  Archived: admin-dashboard/PERFORMANCE_OPTIMIZATION.md" -ForegroundColor Gray
}

# ============================================================================
# CREATE SIMPLE READMEs WITH REDIRECT
# ============================================================================

Write-Host "`nCreating redirect READMEs..." -ForegroundColor Yellow

# Flutter README
$flutterReadmeContent = @"
# PhoneGuard Mobile App (Flutter)

## Documentation

For complete documentation, see the main project README:
- **Main README:** [../../README.md](../../README.md)
- **Master Documentation:** [../../MASTER_DOCUMENTATION.md](../../MASTER_DOCUMENTATION.md)

## Quick Start

``````bash
# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build release APK
flutter build apk --release
``````

## Important Files

- **lib/screens/** - UI screens
- **lib/services/api_service.dart** - API client
- **lib/models/** - Data models

## Test Credentials

See: [../../LOGIN_CREDENTIALS.md](../../LOGIN_CREDENTIALS.md)
"@

Set-Content -Path $flutterReadme -Value $flutterReadmeContent -Encoding UTF8
Write-Host "  Created: phone_insurance_app/README.md" -ForegroundColor Green

# Admin Dashboard README
$dashboardReadmeContent = @"
# PhoneGuard Admin Dashboard (React)

## Documentation

For complete documentation, see the main project README:
- **Main README:** [../README.md](../README.md)
- **Master Documentation:** [../MASTER_DOCUMENTATION.md](../MASTER_DOCUMENTATION.md)

## Quick Start

``````bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build
``````

## Important Files

- **src/pages/** - Dashboard pages
- **src/services/** - API services
- **src/components/** - Reusable components

## Admin Login

See: [../LOGIN_CREDENTIALS.md](../LOGIN_CREDENTIALS.md)
"@

Set-Content -Path $dashboardReadme -Value $dashboardReadmeContent -Encoding UTF8
Write-Host "  Created: admin-dashboard/README.md" -ForegroundColor Green

Write-Host "`nPhase 2 cleanup complete!" -ForegroundColor Green
Write-Host "Moved EMAIL_SETUP_GUIDE to root" -ForegroundColor Cyan
Write-Host "Archived 11 documentation files" -ForegroundColor Cyan
Write-Host "Replaced 2 default READMEs with redirects" -ForegroundColor Cyan
