# Metadata‑Driven Change‑Triggered ETL System

This repository contains a fully metadata‑driven, change‑triggered ETL engine for SQL Server.
It automatically detects upstream source changes, resolves dependent ETL modules, and executes them in the correct order.

The system is designed for:
- High maintainability
- Zero hard‑coded dependencies
- Easy extensibility
- Clean modular structure
- Compatibility with DBeaver, Azure Data Studio, SSMS, SQL Server, and Azure SQL

---------------------------------------------------------------------

FOLDER STRUCTURE (EXECUTION ORDER)

etl/
  00_infrastructure/     Core ETL infrastructure (tables + functions)
  01_sources/            TRUE upstream source registration
  02_metadata/           Module + dependency metadata
  03_modules/            Individual ETL modules (procedures)
  04_controller/         Change‑driven ETL engine
  99_utilities/          Logging, retry logic, helpers

Each folder contains its own README with details and instructions.

---------------------------------------------------------------------

DEPLOYMENT ORDER

Run the scripts in this order:

1. 00_infrastructure
2. 01_sources
3. 02_metadata
4. 03_modules
5. 04_controller

After deployment, schedule:

EXEC dailyData.usp_run_all_daily_ETL_change_driven;

This is the only procedure that needs to be scheduled.

---------------------------------------------------------------------

HOW THE SYSTEM WORKS

1. Source Registration
   All TRUE upstream source tables are registered in:
   ETL_SourceChangeTracker

2. Change Detection
   A checksum function computes:
   CHECKSUM_AGG(BINARY_CHECKSUM(*))
   If the checksum changes → the source changed.

3. Metadata‑Driven Dependencies
   Dependencies are defined in:
   ETL_Modules
   ETL_Dependencies
   No logic is hard‑coded in the controller.

4. ETL Controller
   The controller:
   - Detects changed sources
   - Resolves dependent modules
   - Executes modules in correct order
   - Rebuilds all_daily_data only when needed

This ensures minimal ETL runs and maximum efficiency.

---------------------------------------------------------------------

DEPLOYMENT SCRIPTS

PowerShell (Windows):
  deploy/deploy.ps1

Bash (Linux/macOS):
  deploy/deploy.sh

DBeaver Users:
  deploy/deploy_dbeaver.sql
  (DBeaver cannot run multiple files automatically; this file provides manual instructions.)

---------------------------------------------------------------------

VERSIONING STRATEGY

Each ETL module includes a header:

/* Module: domestic_facts
   Version: 1.3.0
   Last Updated: YYYY-MM-DD
*/

Versions are also stored in:
ETL_Modules.module_version

Optional: A version history table can be added for auditability.

---------------------------------------------------------------------

UTILITIES

The 99_utilities folder includes:
- Logging tables
- Logging procedures
- Retry wrapper templates
- Operational helpers

These are optional but recommended for production environments.

---------------------------------------------------------------------

LICENSE

Internal project — no external license.
