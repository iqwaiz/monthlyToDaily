/* ------------------------------------------------------------
   92_retry_wrapper_template
   ------------------------------------------------------------
   Description:
     Template for wrapping any ETL module with retry logic and logging.

   Instructions:
     Copy this template when creating robust production modules.
------------------------------------------------------------ */

--USE ibraheem_test;
--

CREATE OR ALTER PROCEDURE dailyData.usp_retry_wrapper_template
(
    @proc_name SYSNAME,
    @max_retries INT = 3
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @attempt INT = 1,
        @log_id INT,
        @error_message NVARCHAR(MAX);

    EXEC dailyData.usp_LogStart @module_name = @proc_name, @log_id = @log_id OUTPUT;

    WHILE @attempt <= @max_retries
    BEGIN
        BEGIN TRY
            DECLARE @sql NVARCHAR(MAX) = N'EXEC dailyData.' + QUOTENAME(@proc_name) + N';';
            EXEC (@sql);

            EXEC dailyData.usp_LogSuccess @log_id;
            RETURN;
        END TRY
        BEGIN CATCH
            SET @error_message = ERROR_MESSAGE();
            PRINT 'Attempt ' + CAST(@attempt AS VARCHAR) + ' failed: ' + @error_message;

            IF @attempt = @max_retries
            BEGIN
                EXEC dailyData.usp_LogFailure @log_id, @error_message;
                RETURN;
            END
        END CATCH;

        SET @attempt += 1;
        WAITFOR DELAY '00:00:05';  -- 5 seconds
    END
END;
