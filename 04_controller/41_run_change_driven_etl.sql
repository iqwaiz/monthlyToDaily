/* ------------------------------------------------------------
   41_run_change_driven_etl
   ------------------------------------------------------------
   Description:
     Main ETL controller. Detects changed sources, resolves
     dependent modules, and executes them in correct order.

   Instructions:
     This is the ONLY procedure that should be scheduled.
------------------------------------------------------------ */

--USE ibraheem_test;
--

CREATE OR ALTER PROCEDURE dailyData.usp_run_all_daily_ETL_change_driven
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @source_name SYSNAME,
        @module_name SYSNAME,
        @proc_name   SYSNAME,
        @has_changed BIT;

    /* ------------------------------------------------------------
       1. Detect changed sources
    ------------------------------------------------------------ */

    DECLARE source_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT source_name
        FROM dailyData.ETL_SourceChangeTracker
        WHERE is_active = 1;

    OPEN source_cursor;
    FETCH NEXT FROM source_cursor INTO @source_name;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dailyData.usp_CheckSourceChange
            @source_name = @source_name,
            @has_changed = @has_changed OUTPUT;

        IF @has_changed = 1
        BEGIN
            PRINT 'Source changed: ' + @source_name;
        END

        FETCH NEXT FROM source_cursor INTO @source_name;
    END

    CLOSE source_cursor;
    DEALLOCATE source_cursor;

    /* ------------------------------------------------------------
       2. Identify modules that need to run
    ------------------------------------------------------------ */

    DECLARE @ModulesToRun TABLE (module_name SYSNAME PRIMARY KEY);

    INSERT INTO @ModulesToRun (module_name)
    SELECT DISTINCT d.module_name
    FROM dailyData.ETL_Dependencies d
    JOIN dailyData.ETL_SourceChangeTracker s
        ON d.source_name = s.source_name
    WHERE s.last_change_time IS NOT NULL
      AND s.last_change_time >= s.last_etl_run_time;

    /* Always rebuild all_daily_data */
    INSERT INTO @ModulesToRun (module_name)
    SELECT 'all_daily_data'
    WHERE NOT EXISTS (SELECT 1 FROM @ModulesToRun WHERE module_name = 'all_daily_data');

    /* ------------------------------------------------------------
       3. Execute modules in metadata order
    ------------------------------------------------------------ */

    DECLARE module_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT m.module_name, m.proc_name
        FROM dailyData.ETL_Modules m
        JOIN @ModulesToRun r
            ON m.module_name = r.module_name
        WHERE m.is_active = 1
        ORDER BY m.module_order;

    OPEN module_cursor;
    FETCH NEXT FROM module_cursor INTO @module_name, @proc_name;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'Running module: ' + @module_name;

        DECLARE @sql NVARCHAR(MAX) = N'EXEC dailyData.' + QUOTENAME(@proc_name) + N';';
        EXEC (@sql);

        /* Update ETL run timestamp */
        UPDATE dailyData.ETL_SourceChangeTracker
        SET last_etl_run_time = GETDATE()
        WHERE source_name IN (
            SELECT source_name
            FROM dailyData.ETL_Dependencies
            WHERE module_name = @module_name
        );

        FETCH NEXT FROM module_cursor INTO @module_name, @proc_name;
    END

    CLOSE module_cursor;
    DEALLOCATE module_cursor;

END;
