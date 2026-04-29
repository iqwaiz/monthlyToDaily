/* ------------------------------------------------------------
   91_logging_procedures
   ------------------------------------------------------------
   Description:
     Provides helper procedures for logging ETL execution and errors.

   Instructions:
     Called internally by retry wrappers or controller.
------------------------------------------------------------ */

--USE ibraheem_test;
--

/* ------------------------------------------------------------
   Log start
------------------------------------------------------------ */
CREATE OR ALTER PROCEDURE dailyData.usp_LogStart
(
    @module_name SYSNAME,
    @log_id INT OUTPUT
)
AS
BEGIN
    INSERT INTO dailyData.ETL_Log (module_name, status)
    VALUES (@module_name, 'Started');

    SET @log_id = SCOPE_IDENTITY();
END;
GO

/* ------------------------------------------------------------
   Log success
------------------------------------------------------------ */
CREATE OR ALTER PROCEDURE dailyData.usp_LogSuccess
(
    @log_id INT
)
AS
BEGIN
    UPDATE dailyData.ETL_Log
    SET 
        end_time = GETDATE(),
        status = 'Success'
    WHERE log_id = @log_id;
END;
GO

/* ------------------------------------------------------------
   Log failure
------------------------------------------------------------ */
CREATE OR ALTER PROCEDURE dailyData.usp_LogFailure
(
    @log_id INT,
    @error_message NVARCHAR(MAX)
)
AS
BEGIN
    UPDATE dailyData.ETL_Log
    SET 
        end_time = GETDATE(),
        status = 'Failed',
        error_message = @error_message
    WHERE log_id = @log_id;

    INSERT INTO dailyData.ETL_ErrorLog (module_name, error_message, error_details)
    SELECT module_name, @error_message, @error_message
    FROM dailyData.ETL_Log
    WHERE log_id = @log_id;
END;
