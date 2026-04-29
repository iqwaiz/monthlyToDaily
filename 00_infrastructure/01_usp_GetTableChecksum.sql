/* ==========================================================================================================
   Procedure:      usp_GetTableChecksum
   Layer:          /00_infrastructure
   Purpose:        Returns a checksum for a given table using CHECKSUM_AGG(BINARY_CHECKSUM(*)).
                   Replaces the scalar function ufn_GetTableChecksum to avoid SQL Server function restrictions.

   Usage:
       DECLARE @checksum BIGINT;
       EXEC dailyData.usp_GetTableChecksum
            @table_name = 'Fact_Visits',
            @checksum   = @checksum OUTPUT;

   ========================================================================================================== */

CREATE OR ALTER PROCEDURE dailyData.usp_GetTableChecksum
(
    @table_name SYSNAME,
    @checksum   BIGINT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sql NVARCHAR(MAX);

    SET @sql = N'
        SELECT @checksum_out = CHECKSUM_AGG(BINARY_CHECKSUM(*))
        FROM dailyData.' + QUOTENAME(@table_name) + N';
    ';

    EXEC sp_executesql
        @sql,
        N'@checksum_out BIGINT OUTPUT',
        @checksum_out = @checksum OUTPUT;
END;
