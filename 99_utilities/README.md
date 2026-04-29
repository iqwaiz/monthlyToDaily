# 99_utilities

This folder contains optional but recommended operational utilities for the ETL system.

These utilities improve:
- Monitoring
- Debugging
- Reliability
- Error handling
- Observability

## Files

### 90_logging_tables.sql
Creates:
- ETL_Log (module execution history)
- ETL_ErrorLog (detailed error tracking)

### 91_logging_procedures.sql
Provides:
- usp_LogStart
- usp_LogSuccess
- usp_LogFailure

These procedures are used by retry wrappers or the controller.

### 92_retry_wrapper_template.sql
A template for wrapping any ETL module with:
- Retry logic
- Logging
- Error capture

Copy this template when building robust production modules.

## Execution Order

Run after:
1. 00_infrastructure
2. 01_sources
3. 02_metadata
4. 03_modules
5. 04_controller

These utilities are optional and do not affect ETL logic.
