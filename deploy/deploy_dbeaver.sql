/* ------------------------------------------------------------
   deploy_dbeaver.sql
   ------------------------------------------------------------
   Description:
     DBeaver does not support :r or multi-file execution.
     Run the scripts manually in this order:

     1. /00_infrastructure/00_change_tracker.sql
     2. /00_infrastructure/01_drop_checksum_function.sql
     3. /00_infrastructure/02_create_checksum_function.sql

     4. /01_sources/10_seed_true_sources.sql

     5. /02_metadata/20_modules_and_dependencies.sql

     6. /03_modules/*.sql  (in numeric order)

     7. /04_controller/40_check_source_change.sql
     8. /04_controller/41_run_change_driven_etl.sql
------------------------------------------------------------ */

SELECT 'Open README.md for instructions. This file is informational only.' AS Message;
