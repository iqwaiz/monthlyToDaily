/* ==========================================================================================================
   Procedure:      usp_CheckSourceChange
   Purpose:        Determines whether a source table has changed since the last ETL run.
                   Uses usp_GetTableChecksum instead of a scalar function.

   ========================================================================================================== */

CREATE OR ALTER PROCEDURE dailyData.usp_CheckSourceChange
(
    @source_name SYSNAME,
    @has_changed BIT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @checksum BIGINT;

    /* Get current checksum */
    EXEC dailyData.usp_GetTableChecksum
         @table_name = @source_name,
         @checksum   = @checksum OUTPUT;

    /* Get last stored checksum */
    DECLARE @last_checksum BIGINT =
    (
        SELECT last_checksum
        FROM dailyData.ETL_SourceChangeTracker
        WHERE source_name = @source_name
    );

    /* Compare */
    IF @checksum <> @last_checksum
    BEGIN
        SET @has_changed = 1;

        UPDATE dailyData.ETL_SourceChangeTracker
        SET last_checksum   = @checksum,
            last_change_time = GETDATE()
        WHERE source_name = @source_name;
    END
    ELSE
    BEGIN
        SET @has_changed = 0;
    END
END;
