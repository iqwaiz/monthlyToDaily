#!/bin/bash
# Bash Automation Script

FILES=(
  "../00_infrastructure/00_change_tracker.sql"
  "../00_infrastructure/01_drop_checksum_function.sql"
  "../00_infrastructure/02_create_checksum_function.sql"
  "../01_sources/10_seed_true_sources.sql"
  "../02_metadata/20_modules_and_dependencies.sql"
  "../03_modules/30_domestic_facts.sql"
  "../03_modules/31_inbound_facts.sql"
  "../03_modules/32_targets.sql"
  "../03_modules/33_domestic_estimates.sql"
  "../03_modules/34_inbound_estimates.sql"
  "../03_modules/35_domestic_predictions.sql"
  "../03_modules/36_inbound_predictions.sql"
  "../03_modules/37_border.sql"
  "../03_modules/38_all_daily_data.sql"
  "../04_controller/40_check_source_change.sql"
  "../04_controller/41_run_change_driven_etl.sql"
)

for f in "${FILES[@]}"; do
  echo "Running $f"
  sqlcmd -S localhost -d ibraheem_test -i "$f"
done
