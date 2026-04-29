# 00_infrastructure

This folder contains the foundational ETL infrastructure.

## Files

### 00_change_tracker.sql
Creates the ETL_SourceChangeTracker table, which stores:
- Source table names
- Schema + object names
- Last checksum
- Last change timestamp
- Last ETL run timestamp
- Active flag

### 01_checksum_function.sql
Creates or updates the checksum function:
- Uses CREATE OR ALTER FUNCTION
- No GO required
- Safe to re-run anytime
- Avoids SQL Server batch‑ordering issues

### 02_upsert_utility.sql
Creates the core utility procedure:
dailyData.usp_UpsertDailyTable

This procedure standardizes how ETL modules write their output tables:
- If the target table does not exist → `SELECT INTO`  
- If it exists → `TRUNCATE + INSERT`  
- Ensures consistent table creation  
- Handles schema drift automatically  

This utility is required by all module scripts in `/03_modules/`.

## Execution Order

1. 00_change_tracker.sql  
2. 01_checksum_function.sql
3. 02_upsert_utility.sql

These must be executed before any other ETL scripts.
