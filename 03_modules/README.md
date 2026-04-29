# 03_modules

This folder contains all ETL modules.  
Execution order is controlled by metadata, but filenames follow the same order for clarity.

## Order of Modules

30_border.sql  
31_targets.sql  
32_domestic_facts.sql  
33_inbound_facts.sql  
34_domestic_estimates.sql  
35_inbound_estimates.sql  
36_domestic_predictions.sql  
37_inbound_predictions.sql  
38_all_daily_data.sql  

## Notes

- All modules use CREATE OR ALTER PROCEDURE
- No GO statements
- Safe to re-run
- Called automatically by the ETL controller
