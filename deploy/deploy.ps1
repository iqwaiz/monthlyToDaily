# PowerShell Automation Script

$root = Split-Path -Parent $MyInvocation.MyCommand.Path

$files = @(
    "$root/../00_infrastructure/00_change_tracker.sql",
    "$root/../00_infrastructure/01_drop_checksum_function.sql",
    "$root/../00_infrastructure/02_create_checksum_function.sql",
    "$root/../01_sources/10_seed_true_sources.sql",
    "$root/../02_metadata/20_modules_and_dependencies.sql",
    "$root/../03_modules/30_domestic_facts.sql",
    "$root/../03_modules/31_inbound_facts.sql",
    "$root/../03_modules/32_targets.sql",
    "$root/../03_modules/33_domestic_estimates.sql",
    "$root/../03_modules/34_inbound_estimates.sql",
    "$root/../03_modules/35_domestic_predictions.sql",
    "$root/../03_modules/36_inbound_predictions.sql",
    "$root/../03_modules/37_border.sql",
    "$root/../03_modules/38_all_daily_data.sql",
    "$root/../04_controller/40_check_source_change.sql",
    "$root/../04_controller/41_run_change_driven_etl.sql"
)

foreach ($file in $files) {
    Write-Host "Running $file"
    sqlcmd -S localhost -d ibraheem_test -i $file
}
