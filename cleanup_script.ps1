# Cleanup Script - Move old docs and tests to archive
# Run: powershell -ExecutionPolicy Bypass -File cleanup_script.ps1

$rootPath = "D:\Django Project\Asuransi Project"
$archivePath = "$rootPath\_archive"
$smilePath = "$rootPath\Smile Project"
$oldTestsPath = "$smilePath\_old_tests"

Write-Host "Starting cleanup..." -ForegroundColor Green

# ============================================================================
# ARCHIVE OLD DOCUMENTATION
# ============================================================================

Write-Host "`nArchiving old documentation..." -ForegroundColor Yellow

$docsToArchive = @(
    "100_PERCENT_COMPLETION_REPORT.md",
    "ADMIN_DASHBOARD_DEDUCTION_REMOVAL.md",
    "ADMIN_DASHBOARD_UPDATE_REPORT.md",
    "AUTO_TOPUP_INTEGRATION_REPORT.md",
    "BESOK_TODO_LIST.md",
    "BESOK_TODO_LIST_v2.md",
    "BUG_FIX_REPORT.md",
    "CLAIM_CREATION_GUIDE.md",
    "CLAIM_SYSTEM_UPDATE_REPORT.md",
    "DASHBOARD_COMPLETE_REPORT.md",
    "DASHBOARD_STATS_FIX.md",
    "DATA_EXPORT_FEATURE_REPORT.md",
    "DATA_RESET_REPORT.md",
    "END_TO_END_TEST_REPORT.md",
    "FINAL_STATUS_REPORT.md",
    "FLUTTER_TESTING_GUIDE.md",
    "IMPLEMENTATION_COMPLETE.md",
    "IMPLEMENTATION_GUIDE.md",
    "KTP_FIELD_IMPLEMENTATION.md",
    "MANUAL_TOPUP_FIX_REPORT.md",
    "MOBILE_INTEGRATION_TEST.md",
    "MOBILE_TOPUP_DISABLED.md",
    "MOBILE_UI_UPDATE_REPORT.md",
    "NOTIFICATION_BELL_IMPLEMENTATION.md",
    "NOTIFICATION_BELL_QUICKSTART.md",
    "NO_DEDUCTION_UPDATE.md",
    "PASSWORD_RESET_REPORT.md",
    "POLICY_CREATION_GUIDE.md",
    "POLICY_SYSTEM_UPDATE_REPORT.md",
    "PRICING_UPDATE_REPORT.md",
    "PRICING_UPDATE_SUMMARY.md",
    "PROJECT_STRUCTURE_STATUS.md",
    "QUICK_START_NEXT_SESSION.md",
    "RESET_COMPLETE_SUMMARY.txt",
    "SESSION_2_SUCCESS_REPORT.md",
    "SESSION_COMPLETE_SUMMARY.md",
    "SESSION_COMPLETION_REPORT.md",
    "SESSION_SUMMARY_2025-11-24.md",
    "START_ADMIN_DASHBOARD.md",
    "SUCCESS_REPORT.md",
    "SYSTEM_CLEANUP_UPDATE_REPORT.md",
    "TODO_REMAINING_FEATURES.md",
    "WALLET_HISTORY_GUIDE.md"
)

foreach ($doc in $docsToArchive) {
    $source = Join-Path $rootPath $doc
    if (Test-Path $source) {
        Move-Item -Path $source -Destination $archivePath -Force
        Write-Host "  Archived: $doc" -ForegroundColor Gray
    }
}

# ============================================================================
# MOVE OLD TEST SCRIPTS
# ============================================================================

Write-Host "`nMoving old test scripts..." -ForegroundColor Yellow

$testsToMove = @(
    "check_claims.py",
    "clear_blocks.py",
    "create_test_claim.py",
    "ensure_wallets.py",
    "quick_dashboard_check.py",
    "reset_admin_password.py",
    "reset_all_data.py",
    "reset_all_data_confirm.py",
    "reset_passwords.py",
    "seed_large_data.py",
    "seed_quick.py",
    "test_admin_api.py",
    "test_admin_login.py",
    "test_api.py",
    "test_auto_topup_policy.py",
    "test_claims_api.py",
    "test_claim_actions.py",
    "test_complete_workflow.py",
    "test_create_notification.py",
    "test_dashboard_stats.py",
    "test_end_to_end.py",
    "test_export_api.py",
    "test_manual_policy.py",
    "test_manual_topup.py",
    "test_new_pricing.py",
    "test_notification_api.py",
    "test_performance.py",
    "test_policy_claim.py",
    "test_reset_login.py",
    "test_serializer_fields.py",
    "test_system_cleanup.py",
    "test_token.txt",
    "test_topup_fix.py",
    "update_policy_tiers.py",
    "update_tiers.py",
    "verify_pricing.py",
    "verify_reset.py",
    "verify_wallet_stats.py"
)

foreach ($test in $testsToMove) {
    $source = Join-Path $smilePath $test
    if (Test-Path $source) {
        Move-Item -Path $source -Destination $oldTestsPath -Force
        Write-Host "  Moved: $test" -ForegroundColor Gray
    }
}

# ============================================================================
# DELETE UNNECESSARY FILES
# ============================================================================

Write-Host "`nDeleting unnecessary files..." -ForegroundColor Yellow

# Delete image file
$imageFile = Join-Path $rootPath "WhatsApp Image 2025-11-24 at 21.50.28_51f9f458.jpg"
if (Test-Path $imageFile) {
    Remove-Item $imageFile -Force
    Write-Host "  Deleted: WhatsApp image" -ForegroundColor Gray
}

# Delete TSX files (React/TypeScript - not needed in Django project)
$tsxFiles = @(
    "insurance-api-docs.tsx",
    "insurance_api_docs.tsx",
    "phone_insurance_structure.tsx"
)

foreach ($tsx in $tsxFiles) {
    $source = Join-Path $smilePath $tsx
    if (Test-Path $source) {
        Remove-Item $source -Force
        Write-Host "  Deleted: $tsx" -ForegroundColor Gray
    }
}

# Delete server PID file
$pidFile = Join-Path $smilePath "server_pid.txt"
if (Test-Path $pidFile) {
    Remove-Item $pidFile -Force
    Write-Host "  Deleted: server_pid.txt" -ForegroundColor Gray
}

Write-Host "`nCleanup complete!" -ForegroundColor Green
Write-Host "Archived $($docsToArchive.Count) documentation files" -ForegroundColor Cyan
Write-Host "Moved $($testsToMove.Count) test scripts" -ForegroundColor Cyan
Write-Host "Deleted 5 unnecessary files" -ForegroundColor Cyan
