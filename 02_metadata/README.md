# 02_metadata

This folder defines the metadata that drives the entire ETL engine.

The ETL controller does not contain any hard‑coded logic.  
Instead, it reads from these metadata tables:

- ETL_Modules  
- ETL_Dependencies  

This allows:
- Adding new ETL modules without modifying the controller
- Changing dependencies without code changes
- Reordering modules by adjusting metadata
- Versioning modules independently

## Files

### 20_modules_and_dependencies.sql
- Drops and recreates ETL_Modules and ETL_Dependencies
- Registers all ETL modules
- Registers dependencies between sources and modules
- Includes module versioning support

## Execution Order

Run after:
1. 00_infrastructure
2. 01_sources

Then run:
3. 03_modules
4. 04_controller
