# 04_controller

This folder contains the ETL controller logic.  
It includes both the automated change‑driven controller and an optional
manual full‑pipeline runner.

## Files

### 40_check_source_change.sql
Internal helper used by the change‑driven controller:
- Computes table checksums
- Detects upstream source changes
- Updates change timestamps

### 41_run_change_driven_etl.sql
Primary automated ETL controller:
- Detects changed sources
- Resolves dependent modules using metadata
- Executes only required modules
- Always rebuilds all_daily_data
- This is the ONLY procedure scheduled in SQL Agent

### 42_run_all_daily_ETL_manual.sql
Optional manual full ETL runner:
- Executes ALL modules in metadata order
- Ignores change detection
- Useful for:
  - QA
  - Backfills
  - Full rebuilds
  - Developer testing
  - Manual refreshes

### 42_run_all_daily_ETL_legacy.sql
Legacy full ETL runner:
- Executes all ETL modules in a fixed, hardcoded order
- Does not use metadata
- Does not use change detection
- Kept for backward compatibility and developer testing
- Not used by SQL Agent

## Scheduling

Only schedule:
EXEC dailyData.usp_run_all_daily_ETL_change_driven;


The manual runner is for on‑demand use only.