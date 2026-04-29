/*======================================================================================================================
  Stored Procedure : dailyData.usp_manually_run_all_daily_etl
  Purpose          : Manual full ETL runner — executes ALL ETL modules in metadata order, regardless of source changes.
                     Useful for QA, debugging, backfills, and forced full refreshes.

  Execution Flow   :
                     - Reads ETL_Modules metadata
                     - Executes each module in module_order
                     - Does NOT perform change detection
                     - Does NOT update change tracker timestamps

  Design Principles :
                     - Deterministic full rebuild
                     - Zero dependency on change detection
                     - Safe for repeated manual execution
                     - Mirrors the automated controller’s module ordering

  Author           : Ibraheem
  Owner            : Data Engineering — Daily Data Layer
  Created On       : <DATE>
  Last Updated     : <DATE>

  Version          : 1.0.0
  Change Log       :
                     - 1.0.0 : Initial creation of manual full ETL runner.

  Notes            :
                     - This procedure is NOT scheduled in SQL Agent.
                     - Use only for manual full refreshes or developer testing.
                     - Automated pipeline uses usp_run_all_daily_ETL_change_driven.

======================================================================================================================*/

--USE ibraheem_test;
--

CREATE OR ALTER PROCEDURE dailyData.usp_manually_run_all_daily_etl
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @module_name SYSNAME,
        @proc_name   SYSNAME,
        @sql         NVARCHAR(MAX);

    PRINT 'Starting FULL ETL rebuild (manual mode)...';

    DECLARE module_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT module_name, proc_name
        FROM dailyData.ETL_Modules
        WHERE is_active = 1
        ORDER BY module_order;

    OPEN module_cursor;
    FETCH NEXT FROM module_cursor INTO @module_name, @proc_name;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'Running module: ' + @module_name;

        SET @sql = N'EXEC dailyData.' + QUOTENAME(@proc_name) + N';';
        EXEC (@sql);

        FETCH NEXT FROM module_cursor INTO @module_name, @proc_name;
    END

    CLOSE module_cursor;
    DEALLOCATE module_cursor;

    PRINT 'FULL ETL rebuild completed successfully.';
END;
